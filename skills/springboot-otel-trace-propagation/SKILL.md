---
name: springboot-otel-trace-propagation
description: 修复 Spring Boot + Spring AI 全链路 TraceId 断裂。当用户提到 "trace断裂", "多个TraceId", "链路串联", "trace propagation", "GlobalOpenTelemetry", "MCP trace", "线程饥饿", "Hikari starvation", 或在 langfuse 中看到 trace 不连续/多个根 TraceId 时触发。注意：如果用户只是想配置 Langfuse 集成（OTLP 端点、API Key、Docker Compose），应使用 spring-ai-langfuse3 skill。
---

# Spring Boot + Spring AI 全链路 TraceId 串联修复指南

## 问题现象

单次用户 RAG 对话（QueryRouter → QueryRewrite → 混合检索 → 评估 LLM → 生成回答）产生**大量独立 TraceId**，每一步 LLM 调用、异步检索、MCP 工具调用各自生成根 Span，全链路断裂。

典型日志特征：
```
ChatModelCompletionObservationHandler : ... [a1b2c3d4...]   ← TraceId 1
ChatModelCompletionObservationHandler : ... [e5f6a7b8...]   ← TraceId 2（应为同一 Trace！）
HikariPool-1 - Thread starvation detected (housekeeper delta=56s)
```

## 根因分析（4 层）

| 层 | 根因 | 表现 |
|---|---|---|
| **Observation** | Spring AI ChatModel 每次调用创建 Observation，无活跃 OTel Context 时新建根 Span | 每个 LLM 调用独立 TraceId |
| **异步线程** | `CompletableFuture.runAsync()` 默认使用 `ForkJoinPool.commonPool()`，无 Context 传播 | 异步任务丢失父 Trace |
| **MCP 子进程** | Stdio 子进程完全独立，无 traceparent 传递 | 子进程链路与主进程脱节 |
| **GlobalOpenTelemetry** | Spring Boot OTel AutoConfigure **不注册** GlobalOpenTelemetry（需 `otel.java.global-autoconfigure.enabled=true`） | `GlobalOpenTelemetry.getTracer()` 返回 NoOp |

## 修复方案（4 步）

### 步骤 1：OtelContextUtils 核心工具类

**关键踩坑**：`GlobalOpenTelemetry` ≠ Spring 管理的 `OpenTelemetry` Bean！Spring Boot OTel AutoConfigure 默认不注册全局实例，必须在 `@PostConstruct` 中手动调用 `GlobalOpenTelemetry.set(openTelemetry)`。

```java
package com.example.config.otel;

import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.SpanKind;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Context;
import io.opentelemetry.context.Scope;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ForkJoinPool;

@Component
public final class OtelContextUtils {

    private static final Object lock = new Object();
    private static volatile Tracer tracer;
    private static volatile Executor wrappedCommonPool;

    private final OpenTelemetry openTelemetry;

    public OtelContextUtils(OpenTelemetry openTelemetry) {
        this.openTelemetry = openTelemetry;
    }

    @PostConstruct
    public void init() {
        try {
            GlobalOpenTelemetry.set(openTelemetry);
        } catch (IllegalStateException e) {
            // 已被其他组件设置，忽略
        }
        tracer = openTelemetry.getTracer("your-app-name");
    }

    private static Tracer getTracer() {
        if (tracer == null) {
            synchronized (lock) {
                if (tracer == null) {
                    tracer = GlobalOpenTelemetry.getTracer("your-app-name");
                }
            }
        }
        return tracer;
    }

    /** 替代 ForkJoinPool.commonPool()，自动传播 Context */
    public static Executor commonPool() {
        if (wrappedCommonPool == null) {
            synchronized (OtelContextUtils.class) {
                if (wrappedCommonPool == null) {
                    wrappedCommonPool = wrap(ForkJoinPool.commonPool());
                }
            }
        }
        return wrappedCommonPool;
    }

    /** 包装 Executor */
    public static Executor wrap(Executor delegate) {
        return command -> delegate.execute(wrap(command));
    }

    /** 包装 ExecutorService */
    public static ExecutorService wrap(ExecutorService delegate) {
        return new ContextPropagatingExecutorService(delegate);
    }

    /** 包装 Runnable，捕获当前 Context，在异步线程自动恢复 */
    public static Runnable wrap(Runnable runnable) {
        Context captured = Context.current();
        return () -> {
            try (Scope ignored = captured.makeCurrent()) {
                runnable.run();
            }
        };
    }

    /** 包装 Callable */
    public static <T> Callable<T> wrap(Callable<T> callable) {
        Context captured = Context.current();
        return () -> {
            try (Scope ignored = captured.makeCurrent()) {
                return callable.call();
            }
        };
    }

    /** 提取 W3C traceparent */
    public static String buildTraceparent() {
        Map<String, String> carrier = new HashMap<>();
        GlobalOpenTelemetry.getPropagators().getTextMapPropagator()
                .inject(Context.current(), carrier, Map::put);
        return carrier.get("traceparent");
    }

    /** 创建子 Span（无返回值） */
    public static void withSpan(String spanName, Runnable runnable) {
        Span span = getTracer().spanBuilder(spanName)
                .setSpanKind(SpanKind.INTERNAL).startSpan();
        try (Scope ignored = span.makeCurrent()) {
            runnable.run();
        } catch (Exception e) {
            span.recordException(e);
            throw e;
        } finally {
            span.end();
        }
    }

    /** 创建子 Span（有返回值） */
    public static <T> T withSpan(String spanName, Callable<T> callable) {
        Span span = getTracer().spanBuilder(spanName)
                .setSpanKind(SpanKind.INTERNAL).startSpan();
        try (Scope ignored = span.makeCurrent()) {
            return callable.call();
        } catch (Exception e) {
            span.recordException(e);
            throw new RuntimeException(e);
        } finally {
            span.end();
        }
    }
}
```

### 步骤 2：ContextPropagatingExecutorService

```java
package com.example.config.otel;

import java.util.Collection;
import java.util.List;
import java.util.concurrent.*;
import java.util.stream.Collectors;

class ContextPropagatingExecutorService implements ExecutorService {
    private final ExecutorService delegate;

    ContextPropagatingExecutorService(ExecutorService delegate) {
        this.delegate = delegate;
    }

    @Override public void execute(Runnable c) { delegate.execute(OtelContextUtils.wrap(c)); }
    @Override public Future<?> submit(Runnable t) { return delegate.submit(OtelContextUtils.wrap(t)); }
    @Override public <T> Future<T> submit(Runnable t, T r) { return delegate.submit(OtelContextUtils.wrap(t), r); }
    @Override public <T> Future<T> submit(Callable<T> t) { return delegate.submit(OtelContextUtils.wrap(t)); }
    @Override public <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks) throws InterruptedException {
        return delegate.invokeAll(tasks.stream().map(OtelContextUtils::wrap).collect(Collectors.toList()));
    }
    @Override public <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks, long t, TimeUnit u) throws InterruptedException {
        return delegate.invokeAll(tasks.stream().map(OtelContextUtils::wrap).collect(Collectors.toList()), t, u);
    }
    @Override public <T> T invokeAny(Collection<? extends Callable<T>> tasks) throws InterruptedException, ExecutionException {
        return delegate.invokeAny(tasks.stream().map(OtelContextUtils::wrap).collect(Collectors.toList()));
    }
    @Override public <T> T invokeAny(Collection<? extends Callable<T>> tasks, long t, TimeUnit u) throws InterruptedException, ExecutionException, TimeoutException {
        return delegate.invokeAny(tasks.stream().map(OtelContextUtils::wrap).collect(Collectors.toList()), t, u);
    }
    @Override public void shutdown() { delegate.shutdown(); }
    @Override public List<Runnable> shutdownNow() { return delegate.shutdownNow(); }
    @Override public boolean isShutdown() { return delegate.isShutdown(); }
    @Override public boolean isTerminated() { return delegate.isTerminated(); }
    @Override public boolean awaitTermination(long t, TimeUnit u) throws InterruptedException { return delegate.awaitTermination(t, u); }
}
```

### 步骤 3：业务代码接入模式

**RAG 服务 — 创建父 Span 包裹整个流程：**
```java
public String query(String query, String chatId) {
    // Callable 版 withSpan，直接返回结果，无需 result[0] hack
    return OtelContextUtils.withSpan("agentic.rag.query", () -> doQuery(query, chatId));
}
```

**Controller — 异步任务传播 + 根 Span：**
```java
@GetMapping("/rag")
public SseEmitter rag(String message, String chatId) {
    SseEmitter sseEmitter = new SseEmitter(180000L);
    Context otelContext = Context.current();
    CompletableFuture.runAsync(() -> {
        try (Scope ignored = otelContext.makeCurrent()) {
            try {
                // withSpan 外必须有 try-catch，确保 SseEmitter 一定被关闭
                OtelContextUtils.withSpan("rag.chat." + chatId, () -> {
                    try {
                        String answer = agenticRagService.query(message, chatId);
                        sseEmitter.send(answer);
                        sseEmitter.complete();
                    } catch (Exception e) {
                        sseEmitter.completeWithError(e);
                    }
                });
            } catch (Exception e) {
                sseEmitter.completeWithError(e);
            }
        }
    }, OtelContextUtils.commonPool());  // 不用默认 ForkJoinPool！
    return sseEmitter;
}
```

**自定义 Executor — 直接包装：**
```java
// 字段初始化（捕获提交时的 Context）
private final ExecutorService executor = OtelContextUtils.wrap(
        Executors.newSingleThreadExecutor(r -> {
            Thread t = new Thread(r, "my-worker");
            t.setDaemon(true);
            return t;
        }));
```

### 步骤 4：MCP Stdio 跨进程 traceparent 注入

**原理**：MCP 子进程通过 Stdio stdin/stdout 通信，无法共享内存。每次工具调用时，将 traceparent 注入到工具输入 JSON 的 `_traceparent` 字段。

```java
// McpToolCallback 内部
private static final ObjectMapper MAPPER = new ObjectMapper();  // 静态复用！

@Override
public String call(String toolInput) {
    String enrichedInput = injectTraceparent(toolInput);
    try {
        return client.callTool(new CallToolRequest(tool.name(), enrichedInput));
    } catch (Exception e) {
        return "Error: " + e.getMessage();
    }
}

private String injectTraceparent(String toolInput) {
    try {
        String traceparent = OtelContextUtils.buildTraceparent();
        if (traceparent == null) return toolInput;
        JsonNode node = MAPPER.readTree(
                toolInput != null && !toolInput.isBlank() ? toolInput : "{}");
        if (!(node instanceof ObjectNode root)) return toolInput;  // 非 Object JSON 不注入
        root.put("_traceparent", traceparent);
        return MAPPER.writeValueAsString(root);
    } catch (Exception e) {
        return toolInput;  // 注入失败降级为原始输入
    }
}
```

**注意**：不要在子进程启动时通过环境变量注入 traceparent（环境变量在启动时固化，无法随每次调用更新）。

## Hikari 连接池优化

`ForkJoinPool.commonPool()` 被 MCP 注册等重操作耗尽时，Hikari housekeeper 线程无法调度，导致 Thread starvation 告警。修复 Executor 后问题消除。额外优化：

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 30
      minimum-idle: 10
      connection-timeout: 10000
      validation-timeout: 3000       # 快速剔除失效连接
      leak-detection-threshold: 30000
```

## Reactor Flux + Virtual Threads 上下文传播

### 问题现象

Spring Boot 中通过 `Flux.subscribeOn(自定义Scheduler)` 将 LLM 调用调度到虚拟线程执行时，单次 HTTP 请求在 Langfuse 中出现 **多个独立 TraceId**（每个 Agent 步骤的 LLM 调用各自新建根 Span），链路完全断裂。

```
ChatModelCompletionObservationHandler : ... [a1b2c3...]   ← TraceId 1（步骤3）
ChatModelCompletionObservationHandler : ... [d4e5f6...]   ← TraceId 2（步骤4，应为同一 Trace！）
```

### 根因

Reactor 的 `subscribeOn(Scheduler)` 将任务切换到目标线程池执行，但 OpenTelemetry 的 `Context.current()` 存储在 ThreadLocal 中，**跨线程边界不会自动传播**。

Spring Boot OTel AutoConfigure 内置了 `ObservationThreadLocalAccessor`，但需要 Reactor 层面的桥接才能将 Reactor Context ↔ ThreadLocal 双向同步。

### 修复方案

#### 步骤 1：开启 Reactor 自动上下文传播

在 `main()` 中调用 `Hooks.enableAutomaticContextPropagation()`：

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        Hooks.enableAutomaticContextPropagation();
        SpringApplication.run(Application.class, args);
    }
}
```

> 3.6+ 内置，无需额外依赖。自动将 Reactor Context 中注册了 `ThreadLocalAccessor` 的值（如 `Observation`）在 `subscribeOn` 切换线程时恢复到目标线程 ThreadLocal。

#### 步骤 2：虚拟线程 Scheduler

```java
private static final Scheduler VT_SCHEDULER =
        Schedulers.fromExecutor(Executors.newVirtualThreadPerTaskExecutor());
```

> **不要使用 `Schedulers.boundedElastic()`** — 其内部平台线程池不遵循 `spring.threads.virtual.enabled`。

#### 步骤 3：将 Observation 写入 Reactor Context

在 Service 中注入 `ObservationRegistry`，在构建 Flux 管道时捕获当前 Observation 并写入 Reactor Context：

```java
@Service
public class MyService {

    private final ObservationRegistry observationRegistry;

    public Flux<MyEvent> execute(Request request) {
        Observation currentObservation = observationRegistry.getCurrentObservation();

        Flux<MyEvent> pipeline = Flux.concat(
                step1(request),
                step2(request)
        );

        if (currentObservation != null) {
            pipeline = pipeline.contextWrite(ctx ->
                    ctx.put(Observation.class, currentObservation));
        }

        return pipeline;
    }

    private Flux<MyEvent> step1(Request request) {
        return Flux.defer(() -> Flux.concat(
                Mono.fromCallable(() -> blockingLlmCall(request))
                    .subscribeOn(VT_SCHEDULER)  // 切换线程时自动恢复 Observation
                    .flatMapMany(result -> ...)
        ));
    }
}
```

#### 步骤 4（可选）：步骤日志获取 MDC traceId

如果需要在 Agent 步骤日志中打印 traceId，使用 `deferContextual` 手动开 scope：

```java
return Flux.deferContextual(ctx -> {
    try (Observation.Scope ignored = ctx.<Observation>getOrEmpty(Observation.class)
            .map(Observation::openScope).orElse(null)) {
        log.info("Step {} 开始执行", stepNum);  // 此时 MDC 中有 traceId
    }
    // ... 后续逻辑
});
```

> 如果只关心 Langfuse 链路不分裂（不关心控制台 traceId），步骤 1-3 就够了。

### 避坑：ContextSnapshot 与 Reactor 冲突

**常见错误尝试**：

```java
// ❌ 不要这样做
Schedulers.fromExecutor(command -> {
    ContextSnapshot snapshot = ContextSnapshotFactory.builder().build().captureAll();
    Executors.newVirtualThreadPerTaskExecutor().execute(snapshot.wrap(command));
});
```

**冲突原因**：Reactor 的 `ContextOperator` 在 `command.run()` 内部执行时才恢复 Observation → 开 scope。外层 `ContextSnapshot.captureAll()` 捕获的是调度线程的上下文（**空的**），`snapshot.wrap(command)` 执行时 `snapshot.set(null)` 先跑 → 空上下文覆盖了 Reactor 刚刚恢复的 Observation scope → MDC/Langfuse 全部断裂。

**正确做法**：只依赖 `Hooks.enableAutomaticContextPropagation()` + `contextWrite`，不要在外层叠加任何手动上下文捕获。

## OTLP BatchSpanProcessor 优化

大 Span（含完整 prompt/completion）导出超时。通过 JVM 启动参数配置：

```
-Dotel.bsp.max.queue.size=4096
-Dotel.bsp.export.timeout=30000
-Dotel.exporter.otlp.timeout=30000
```

## 常见陷阱

| 陷阱 | 后果 | 修复 |
|------|------|------|
| `GlobalOpenTelemetry.getTracer()` 未 set | 返回 NoOp，withSpan 无效 | `@PostConstruct` 中调用 `GlobalOpenTelemetry.set(openTelemetry)` |
| `withSpan` 外无 try-catch | SseEmitter 永远不返回（卡 180s） | Controller 中 withSpan 必须被外层 try-catch 包裹 |
| `CompletableFuture.runAsync(task)` 不传 Executor | 占用 ForkJoinPool，Hikari 线程饥饿 | 使用 `OtelContextUtils.commonPool()` |
| `new ObjectMapper()` 每次调用 | GC 压力 | 改为 `static final MAPPER` |
| `injectTraceparent` 转 ObjectNode 不检查类型 | 数组 JSON 抛 ClassCastException | `instanceof ObjectNode` 检查 |
| 环境变量注入 traceparent | 子进程启动时固化，运行时失效 | 改用工具输入 JSON 的 `_traceparent` 字段 |
| `result[0]` 数组模式包装 withSpan | 异常时 result[0] 为 null | 使用 `withSpan(Callable<T>)` 直接返回 |
| `ContextSnapshot` 包裹 Reactor Scheduler | 空上下文覆盖 Reactor 恢复的 Observation scope，链路断裂 | 只用 `Hooks.enableAutomaticContextPropagation()` + `contextWrite` |

## 验证标准

1. **单次 RAG 查询**：所有 ChatModelCompletionObservationHandler 的 TraceId **完全相同**
2. **跨轮对话**：同一 chatId 内多次 query 共享根 TraceId（需在调用层创建根 Span）
3. **Hikari**：日志无 `Thread starvation or clock leap detected`
4. **MCP 子进程**：工具输入 JSON 包含 `_traceparent` 字段
5. **OTLP**：Langfuse 能看到完整 trace，无导出超时告警
