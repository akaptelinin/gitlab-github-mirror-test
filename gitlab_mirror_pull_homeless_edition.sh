# GitLab mirror pull option для бедных(
# раз в 60 секунд

param(
    [string]$RemoteRepo = "https://<GitHub token with Content: Read and Write>@github.com/akaptelinin/gitlab-github-mirror-test.git",
    [string]$GitlabRepo = "http://localhost:8929/root/gitlab-github-mirror-test.git",
    [string]$GitlabUser = "root",
    [string]$GitlabPass = "<GitLAb token or password>",
    [int]$IntervalSec = 60
)

Add-Type -AssemblyName System.Web

function Write-Err($msg) {
    Write-Host $msg -ForegroundColor Red
}
function Write-Ok($msg) {
    Write-Host $msg -ForegroundColor Green
}

while ($true) {
    $startTime = Get-Date -Format "HH:mm:ss"
    Write-Host ""
    Write-Host "----- MIRROR START ($startTime) -----"

    $tempDir = "$env:TEMP\repo-mirror-tmp"

    try {
        # Remove old temp folder if it exists
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction Stop
        }

        # Clone remote repo as a bare mirror
        git clone --mirror $RemoteRepo $tempDir
        if (-not (Test-Path "$tempDir\config")) {
            Write-Err "Error: failed to clone $RemoteRepo"
            continue
        }

        Set-Location $tempDir

        # Encode password for URL
        $EncodedPass = [System.Web.HttpUtility]::UrlEncode($GitlabPass)
        $pushUrl = "http://$GitlabUser`:$EncodedPass@$($GitlabRepo -replace '^https?://')"

        # Set push remote to local GitLab
        git remote set-url --push origin $pushUrl
        if ($LASTEXITCODE -ne 0) {
            Write-Err "Error: failed to set GitLab remote"
            Set-Location $PSScriptRoot
            continue
        }

        # Fetch latest changes
        git fetch -p origin
        if ($LASTEXITCODE -ne 0) {
            Write-Err "Error: fetch failed"
            Set-Location $PSScriptRoot
            continue
        }

        # Mirror push to GitLab
        git push --mirror
        if ($LASTEXITCODE -ne 0) {
            Write-Err "Error: push failed"
            Set-Location $PSScriptRoot
            continue
        }

        Set-Location $PSScriptRoot
        Write-Ok "Mirror sync completed successfully"
    }
    catch {
        Write-Err "Fatal error: $_"
        Set-Location $PSScriptRoot
    }
    finally {
        # Cleanup temp folder
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force
        }
    }

    Write-Host "Waiting $IntervalSec seconds..."
    Start-Sleep -Seconds $IntervalSec
}
