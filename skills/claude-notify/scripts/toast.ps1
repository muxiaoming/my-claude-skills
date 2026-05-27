param([string]$Type)
Import-Module BurntToast -ErrorAction SilentlyContinue

$d = $env:CLAUDE_PROJECT_DIR
$n = Split-Path $d -Leaf
$m = $env:ANTHROPIC_MODEL
$t = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$b = ""
if ($d) { $b = (git -C $d branch --show-current 2>$null) }
if (-not $b) { $b = "no-git" }

switch ($Type) {
    "Notification" {
        $Title = "[$n] Claude Waiting"
        $Text  = "Dir: $d`nBranch: $b`nModel: $m"
    }
    "PermissionDenied" {
        $Title = "[$n] Permission Needed"
        $Text  = "Dir: $d`nBranch: $b`nModel: $m"
    }
    "Stop" {
        $Title = "[$n] Claude Done"
        $Text  = "Dir: $d`nBranch: $b`nModel: $m"
    }
    default { exit 0 }
}
New-BurntToastNotification -Text $Title, $Text
