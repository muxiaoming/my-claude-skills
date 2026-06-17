---
name: spring-ai-langfuse3
description: 集成 Spring AI 与 Langfuse 3 可观测平台。当用户提到 "langfuse", "tracing", "可观测", "observability", "OTel", "OpenTelemetry" 与 Spring AI 项目时触发。
---

# Spring AI + Langfuse 3 集成指南

基于 [Langfuse 官方示例](https://github.com/langfuse/langfuse-examples/tree/main/applications/spring-ai-demo)。

## 整体链路

```
Spring AI 调用 LLM
    ↓
Micrometer Observation（采集指标）
    ↓
micrometer-tracing-bridge-otel（桥接到 OpenTelemetry）
    ↓
opentelemetry-exporter-otlp（OTLP 协议导出）
    ↓
Langfuse /api/public/otel（接收并展示 Trace）
```

## 1. pom.xml

### dependencyManagement

检查项目 `pom.xml` 的 `<dependencyManagement>` 中是否已有 `spring-ai-bom`。**没有才需要添加**（Spring Boot parent 不管理 Spring AI 版本）。

**BOM 顺序很重要**：`opentelemetry-instrumentation-bom` 必须放在最前面，避免被其他 BOM（如 `spring-ai-alibaba-bom`）的旧版本覆盖。

```xml
<dependencyManagement>
    <dependencies>
        <!-- OpenTelemetry BOM 必须放最前，版本与官方文档保持一致 -->
        <dependency>
            <groupId>io.opentelemetry.instrumentation</groupId>
            <artifactId>opentelemetry-instrumentation-bom</artifactId>
            <version>2.28.1</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.ai</groupId>
            <artifactId>spring-ai-bom</artifactId>
            <version>${spring-ai.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### 核心 4 依赖

```xml
<dependency>
    <groupId>io.opentelemetry.instrumentation</groupId>
    <artifactId>opentelemetry-spring-boot-starter</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-tracing-bridge-otel</artifactId>
</dependency>
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-exporter-otlp</artifactId>
</dependency>
```

> Spring AI 观测 jar（`chat-observation` / `embedding-observation`）通过 model starter 传递引入，**无需手动添加**。

## 2. JDBC + OTel 版本冲突（必踩坑）

**任何使用 JDBC 数据源的项目**（MySQL、PostgreSQL、H2 等）都会遇到此问题，不仅限于 PGVector。

### 报错

```
The following method did not exist:
'setCaptureQueryParameters(boolean)'
io.opentelemetry.instrumentation.jdbc.internal.JdbcInstrumenterFactory
```

### 根因

`micrometer-tracing-bridge-otel`（Spring Boot 管理版本）传递依赖了旧版 `opentelemetry-instrumentation-api-incubator:2.9.0-alpha`，而 `opentelemetry-jdbc`（来自 `opentelemetry-spring-boot-starter`）需要更新的版本。

Maven 传递依赖优先级高于 BOM，仅调 BOM 顺序无法解决。**官方示例不含 JDBC 依赖所以未暴露此问题，实际业务项目加数据库后必现。**

### 解决方案

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-tracing-bridge-otel</artifactId>
    <exclusions>
        <exclusion>
            <groupId>io.opentelemetry.instrumentation</groupId>
            <artifactId>opentelemetry-instrumentation-api-incubator</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<!-- 版本由 dependencyManagement 中的 opentelemetry-instrumentation-bom 管理，无需显式声明 -->
```

## 3. application.yaml

```yaml
spring:
  ai:
    chat:
      observations:
        log-prompt: true
        log-completion: true

management:
  tracing:
    sampling:
      probability: 1.0
  observations:
    annotations:
      enabled: true

otel:
  logs:
    exporter: none         # Langfuse 不接收 logs
  metrics:
    exporter: none         # Langfuse 不接收 metrics
  exporter:
    otlp:
      endpoint: http://localhost:3000/api/public/otel  # 不含 /v1/traces
      headers:
        Authorization: "Basic <base64 pk:sk>"
```

### 可选：禁用 favicon.ico 500 错误（推荐）

浏览器会自动请求 `/favicon.ico`，Spring Boot 默认处理可能返回 500 错误，在 Langfuse Trace 中产生噪音。

在 `application.yaml` 的 `spring:` 下添加：

```yaml
spring:
  mvc:
    favicon:
      enabled: false       # 禁用 favicon.ico 请求，避免 500 错误噪音
```

## 4. Base64 生成

```bash
echo -n "pk-lf-xxx:sk-lf-xxx" | base64        # Git Bash
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("pk-lf-xxx:sk-lf-xxx"))  # PowerShell
```

## 5. 自动探针（starter 内置）

| 探针 | 内置 |
|------|------|
| HTTP (WebMVC/WebFlux) | ✅ |
| JDBC | ✅（需注意版本冲突，见第 2 节） |
| Kafka | ✅ |
| MongoDB | ✅ |
| Logback MDC | ✅ |
| Redis (Lettuce) | ❌ 需添加 `opentelemetry-lettuce-5.1-library` |

## 6. ChatModelCompletionContentObservationFilter

添加此过滤器可在 Langfuse Trace 中显示完整的 prompt 和 completion 内容（`gen_ai.prompt` / `gen_ai.completion` 属性）。来自 Langfuse 官方示例。

```java
package com.example.observability.filter;

import io.micrometer.common.KeyValue;
import io.micrometer.observation.Observation;
import io.micrometer.observation.ObservationFilter;
import org.springframework.ai.chat.observation.ChatModelObservationContext;
import org.springframework.ai.content.Content;
import org.springframework.ai.observation.ObservabilityHelper;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import java.util.List;

@Component
public class ChatModelCompletionContentObservationFilter implements ObservationFilter {

    @Override
    public Observation.Context map(Observation.Context context) {
        if (!(context instanceof ChatModelObservationContext ctx)) return context;

        var prompts = ctx.getRequest().getInstructions() == null ? List.of()
                : ctx.getRequest().getInstructions().stream().map(Content::getText).toList();

        var completions = (ctx.getResponse() != null && ctx.getResponse().getResults() != null
                && !ctx.getResponse().getResults().isEmpty())
                ? ctx.getResponse().getResults().stream()
                    .filter(g -> g.getOutput() != null && StringUtils.hasText(g.getOutput().getText()))
                    .map(g -> g.getOutput().getText()).toList()
                : List.of();

        ctx.addHighCardinalityKeyValue(new KeyValue() {
            public String getKey() { return "gen_ai.prompt"; }
            public String getValue() { return ObservabilityHelper.concatenateStrings(prompts); }
        });
        ctx.addHighCardinalityKeyValue(new KeyValue() {
            public String getKey() { return "gen_ai.completion"; }
            public String getValue() { return ObservabilityHelper.concatenateStrings(completions); }
        });
        return ctx;
    }
}
```

## 7. 验证

```bash
# API Key 有效
curl -s -H "Authorization: Basic <base64>" "http://localhost:3000/api/public/traces?limit=1"
# 期望：HTTP 200

# OTLP 端点可达
curl -s -X POST "http://localhost:3000/api/public/otel/v1/traces" \
  -H "Authorization: Basic <base64>" -H "Content-Type: application/x-protobuf" -d "" -w "\nHTTP: %{http_code}"
# 期望：HTTP 200
```

## 8. Docker Compose（本地 Langfuse 3）

```bash
docker compose -f docker/docker-compose-langfuse.yml up -d
# 访问 http://localhost:3000 → 注册 → 创建项目 → 获取 API Keys
```

6 个服务：`langfuse-web`(3000)、`langfuse-worker`、`langfuse-db`(Postgres 16)、`langfuse-clickhouse`、`langfuse-redis`、`langfuse-minio`

版本要求：Langfuse **>= v3.22.0** 才支持 OTEL 端点。

## 9. 常见问题

| 问题 | 解决 |
|------|------|
| `setCaptureQueryParameters(boolean)` 方法不存在 | JDBC + OTel 版本冲突，见第 2 节 |
| `Failed to export logs` 404 | 加 `otel.logs.exporter: none` + `otel.metrics.exporter: none` |
| Trace 无 HTTP attributes | 不要禁用 `http.server.requests` 和 `otel.instrumentation.spring-webmvc` |
| Trace 看不到 Prompt 明文 | 加 `spring.ai.chat.observations.log-prompt: true` |
| `OTLP endpoint must not have a path` | 用 YAML 配置，不用 `OTEL_EXPORTER_OTLP_ENDPOINT` 环境变量 |
| `Connection refused: localhost:4318` | `otel.exporter.otlp.endpoint` 指向 3000 |
| 阿里云镜像缺 OTel 制品 | `<repository><id>central</id><url>https://repo1.maven.org/maven2</url></repository>` |
| `ClassNotFoundException: Tracer` | 保留 `micrometer-tracing-bridge-otel` 依赖 |
| `/favicon.ico` 500 | `spring.mvc.favicon.enabled: false` |
| 多 BOM 项目版本冲突 | OTel BOM 放最前面 + 见第 2 节 exclusion 方案 |
