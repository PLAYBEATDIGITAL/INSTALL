<# deploy_frontend.ps1 — Create Render static site, set build/output, and trigger deploy (PowerShell)
   Usage: set $env:RENDER_API_KEY and edit placeholders, then run in PowerShell.
#>

if (-not $env:RENDER_API_KEY) { Write-Error "Set RENDER_API_KEY as an environment variable or edit the script."; exit 1 }

$SiteName = 'playbeat-frontend'  # change if desired
$GitRepo = 'https://github.com/USER/FRONTEND_REPO.git'  # replace with your frontend repo
$Branch = 'main'
$Headers = @{ Authorization = "Bearer $($env:RENDER_API_KEY)"; 'Content-Type' = 'application/json' }

$body = @{ name = $SiteName; repo = $GitRepo; branch = $Branch; buildCommand = 'npm run build'; publishPath = 'build' } | ConvertTo-Json -Depth 6

Write-Host "Creating Render static site '$SiteName'..."
$resp = Invoke-RestMethod -Method Post -Uri 'https://api.render.com/v1/sites' -Headers $Headers -Body $body
$resp | ConvertTo-Json
$SiteId = $resp.id
if (-not $SiteId) { Write-Error "Site creation failed"; exit 1 }
Write-Host "Site created with ID: $SiteId"

Write-Host "To trigger a deploy via PowerShell, run:\nInvoke-RestMethod -Method Post -Uri 'https://api.render.com/v1/sites/$SiteId/deploys' -Headers $Headers -Body '{}'"