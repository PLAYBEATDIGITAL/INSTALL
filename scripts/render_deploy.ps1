<#
Render deploy helper (PowerShell)
Usage: set the environment variables or run with -RenderApiKey, -ServiceName, -GitRepo
Requires: PowerShell 7+ for `Invoke-RestMethod` behavior
#>
param(
    [string]$RenderApiKey = $env:RENDER_API_KEY,
    [string]$ServiceName = $env:SERVICE_NAME,
    [string]$GitRepo = $env:GIT_REPO,
    [string]$Branch = $(if ($env:BRANCH) { $env:BRANCH } else { 'main' }),
    [string]$Region = $(if ($env:REGION) { $env:REGION } else { 'oregon' })
)

if (-not $RenderApiKey) { Write-Error 'RENDER_API_KEY is required'; exit 1 }
if (-not $ServiceName) { Write-Error 'SERVICE_NAME is required'; exit 1 }
if (-not $GitRepo) { Write-Error 'GIT_REPO is required'; exit 1 }

$body = @{
    name    = $ServiceName
    repo    = $GitRepo
    branch  = $Branch
    service = @{ env = 'node'; region = $Region; plan = 'free'; buildCommand = 'npm install'; startCommand = 'npm start' }
} | ConvertTo-Json -Depth 6

$headers = @{ Authorization = "Bearer $RenderApiKey"; 'Content-Type' = 'application/json' }

Write-Host "Creating Render service '$ServiceName'..."
$resp = Invoke-RestMethod -Method Post -Uri 'https://api.render.com/v1/services' -Headers $headers -Body $body
$resp | ConvertTo-Json -Depth 6
$serviceId = $resp.id
if (-not $serviceId) { Write-Error 'Failed to create service'; exit 1 }
Write-Host "Service ID: $serviceId"

function Set-EnvVar($key, $value, $secure) {
    if (-not $value) { Write-Host "Skipping $key (no value)"; return }
    $envBody = @{ key = $key; value = $value; secure = $secure } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "https://api.render.com/v1/services/$serviceId/env-vars" -Headers $headers -Body $envBody
}

Set-EnvVar -key 'MONGODB_URI' -value $env:MONGODB_URI -secure $true
Set-EnvVar -key 'JWT_SECRET' -value $env:JWT_SECRET -secure $true
Set-EnvVar -key 'EMAIL_HOST' -value $env:EMAIL_HOST -secure $true
Set-EnvVar -key 'EMAIL_PORT' -value $env:EMAIL_PORT -secure $false
Set-EnvVar -key 'EMAIL_USER' -value $env:EMAIL_USER -secure $true
Set-EnvVar -key 'EMAIL_PASS' -value $env:EMAIL_PASS -secure $true
Set-EnvVar -key 'EMAIL_FROM' -value $env:EMAIL_FROM -secure $false

Write-Host 'Triggering deploy...'
Invoke-RestMethod -Method Post -Uri "https://api.render.com/v1/services/$serviceId/deploys" -Headers $headers -Body '{}' | ConvertTo-Json -Depth 6

Write-Host 'Fetching recent logs (non-streaming)'
Invoke-RestMethod -Method Get -Uri "https://api.render.com/v1/services/$serviceId/logs?limit=200" -Headers $headers | ConvertTo-Json -Depth 6
