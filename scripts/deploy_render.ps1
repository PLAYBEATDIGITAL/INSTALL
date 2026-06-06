<# deploy_render.ps1 — Create Render service, set env vars, and trigger a deploy (PowerShell)
   Usage: edit placeholders or set $env:RENDER_API_KEY, then run in PowerShell.
#>

param()

if (-not $env:RENDER_API_KEY) {
    Write-Error "Set RENDER_API_KEY as an environment variable or edit the script."; exit 1
}

$ServiceName = 'playbeat-backend'  # change if desired
$GitRepo = 'https://github.com/USER/REPO.git'  # replace with your repo
$Branch = 'main'
$Region = 'oregon'
$Headers = @{ Authorization = "Bearer $($env:RENDER_API_KEY)"; 'Content-Type' = 'application/json' }

$body = @{ name = $ServiceName; repo = $GitRepo; branch = $Branch; service = @{ env = 'node'; region = $Region; plan = 'free'; buildCommand = 'npm install'; startCommand = 'npm start' } } | ConvertTo-Json -Depth 6

Write-Host "Creating Render service '$ServiceName'..."
$resp = Invoke-RestMethod -Method Post -Uri 'https://api.render.com/v1/services' -Headers $Headers -Body $body
$resp | ConvertTo-Json
$ServiceId = $resp.id
if (-not $ServiceId) { Write-Error "Service creation failed"; exit 1 }
Write-Host "Service created with ID: $ServiceId"

# Example: set MONGODB_URI (repeat for other vars)
$envBody = @{ key = 'MONGODB_URI'; value = 'mongodb+srv://USER:PASS@host/db'; secure = $true } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri "https://api.render.com/v1/services/$ServiceId/env-vars" -Headers $Headers -Body $envBody | ConvertTo-Json

Write-Host "See the script for next steps: replace placeholders and repeat for other env vars, then trigger a deploy via:\nInvoke-RestMethod -Method Post -Uri 'https://api.render.com/v1/services/$ServiceId/deploys' -Headers $Headers -Body '{}'"
