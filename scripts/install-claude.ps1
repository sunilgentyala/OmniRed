# OmniRed — Claude Code Skills Installer
# Installs OmniRed skills into your Claude Code user configuration
# Author: Sunil Gentyala, Independent Researcher

param(
    [string]$Category = "all",
    [string]$RepoPath = $PSScriptRoot + "\..",
    [string]$ClaudeSkillsPath = "$env:USERPROFILE\.claude\skills"
)

Write-Host "OmniRed Claude Skills Installer" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Resolve repo path
$RepoPath = Resolve-Path $RepoPath

# Create skills directory if needed
if (-not (Test-Path $ClaudeSkillsPath)) {
    New-Item -ItemType Directory -Path $ClaudeSkillsPath -Force | Out-Null
    Write-Host "Created $ClaudeSkillsPath" -ForegroundColor Green
}

$SkillsSource = Join-Path $RepoPath "skills"

# Determine which categories to install
$AllCategories = @("ai-native", "mcp", "llm-pipeline", "web", "auth",
                   "active-directory", "cloud", "infrastructure",
                   "recon", "supply-chain", "utility")

if ($Category -eq "all") {
    $ToInstall = $AllCategories
} elseif ($Category -in $AllCategories) {
    $ToInstall = @($Category)
} else {
    Write-Host "Unknown category: $Category" -ForegroundColor Red
    Write-Host "Valid categories: $($AllCategories -join ', ')" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Installing categories: $($ToInstall -join ', ')" -ForegroundColor Yellow
Write-Host ""

$Installed = 0
$Skipped = 0

foreach ($cat in $ToInstall) {
    $catSource = Join-Path $SkillsSource $cat
    $catDest = Join-Path $ClaudeSkillsPath $cat

    if (-not (Test-Path $catSource)) {
        Write-Host "  [SKIP] $cat — not found in repo" -ForegroundColor Gray
        $Skipped++
        continue
    }

    # Copy category
    Copy-Item -Path $catSource -Destination $catDest -Recurse -Force

    $skillCount = (Get-ChildItem "$catDest\*\SKILL.md" -Recurse).Count
    Write-Host "  [OK] $cat ($skillCount skills)" -ForegroundColor Green
    $Installed++
}

Write-Host ""
Write-Host "Installation complete." -ForegroundColor Cyan
Write-Host "  Categories installed: $Installed" -ForegroundColor White
Write-Host "  Categories skipped:   $Skipped" -ForegroundColor White
Write-Host "  Skills location:      $ClaudeSkillsPath" -ForegroundColor White
Write-Host ""
Write-Host "Restart Claude Code to load the new skills." -ForegroundColor Yellow
