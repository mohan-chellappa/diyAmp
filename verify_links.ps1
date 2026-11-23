# ==============================================================================
# Link Integrity Validator: DIY Amp Documentation Suite
# Scans all Markdown (.md) and HTML (.html) files for local file references
# and validates that all target files exist on disk.
# ==============================================================================

$rootPath = $PSScriptRoot
if (-not $rootPath) { $rootPath = Get-Location }

$docFiles = Get-ChildItem -Path $rootPath -Include *.md, *.html -Recurse -File | 
            Where-Object { $_.FullName -notmatch '\\(\.git|\.agents|node_modules)\\' }

$totalLinks = 0
$brokenLinks = 0
$issues = @()

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  DIY Amp Documentation Suite - Link Integrity Validator   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Scanning directory: $rootPath" -ForegroundColor Gray
Write-Host "Found $($docFiles.Count) document files to analyze.`n" -ForegroundColor Gray

foreach ($file in $docFiles) {
    $relSource = $file.FullName.Replace("$rootPath\", "")
    $lines = Get-Content -LiteralPath $file.FullName
    $lineNum = 0

    foreach ($line in $lines) {
        $lineNum++

        # Match markdown links: [text](target)
        $mdMatches = [regex]::Matches($line, '\[([^\]]+)\]\(([^)]+)\)')
        foreach ($m in $mdMatches) {
            $rawTarget = $m.Groups[2].Value.Trim()
            # Ignore web links (http, https, mailto)
            if ($rawTarget -match '^(https?://|mailto:)') { continue }

            $totalLinks++
            $targetPath = $rawTarget

            # Remove anchor / hash (#section)
            if ($targetPath.Contains("#")) {
                $targetPath = $targetPath.Substring(0, $targetPath.IndexOf("#"))
            }
            if ([string]::IsNullOrWhiteSpace($targetPath)) { continue }

            # Decode URL encoding (e.g. %20 -> space)
            $decoded = [System.Uri]::UnescapeDataString($targetPath)

            # Handle file:/// protocol or absolute Windows paths
            if ($decoded -match '^file:///(.+)$') {
                $checkPath = $matches[1] -replace '/', '\'
            } elseif ($decoded -match '^[a-zA-Z]:[/\\]') {
                $checkPath = $decoded -replace '/', '\'
            } else {
                # Relative path from the source file's directory
                $checkPath = Join-Path -Path $file.DirectoryName -ChildPath ($decoded -replace '/', '\')
            }

            if (-not (Test-Path -LiteralPath $checkPath)) {
                $brokenLinks++
                $issues += [PSCustomObject]@{
                    Source = "$($relSource):$($lineNum)"
                    Target = $rawTarget
                    ResolvedPath = $checkPath
                    Type = "Markdown Link"
                }
            }
        }

        # Match HTML href and src attributes: href="..." / src="..."
        $htmlMatches = [regex]::Matches($line, '(?:href|src)=["'']([^"'']+)["'']')
        foreach ($m in $htmlMatches) {
            $rawTarget = $m.Groups[1].Value.Trim()
            if ($rawTarget -match '^(https?://|mailto:|javascript:|data:|#)') { continue }

            $totalLinks++
            $targetPath = $rawTarget
            if ($targetPath.Contains("#")) {
                $targetPath = $targetPath.Substring(0, $targetPath.IndexOf("#"))
            }
            if ([string]::IsNullOrWhiteSpace($targetPath)) { continue }

            $decoded = [System.Uri]::UnescapeDataString($targetPath)
            if ($decoded -match '^file:///(.+)$') {
                $checkPath = $matches[1] -replace '/', '\'
            } elseif ($decoded -match '^[a-zA-Z]:[/\\]') {
                $checkPath = $decoded -replace '/', '\'
            } else {
                $checkPath = Join-Path -Path $file.DirectoryName -ChildPath ($decoded -replace '/', '\')
            }

            if (-not (Test-Path -LiteralPath $checkPath)) {
                $brokenLinks++
                $issues += [PSCustomObject]@{
                    Source = "$($relSource):$($lineNum)"
                    Target = $rawTarget
                    ResolvedPath = $checkPath
                    Type = "HTML Attribute"
                }
            }
        }
    }
}

if ($brokenLinks -eq 0) {
    Write-Host "RESULT: ALL $totalLinks LINKS ARE HEALTHY AND VALID!" -ForegroundColor Green
    Write-Host "No broken links or orphaned files detected across all documents." -ForegroundColor Green
} else {
    Write-Host "RESULT: FOUND $brokenLinks BROKEN LINKS (out of $totalLinks checked):" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  [$($issue.Type)] $($issue.Source)" -ForegroundColor Yellow
        Write-Host "    Target:   $($issue.Target)" -ForegroundColor DarkGray
        Write-Host "    Missing:  $($issue.ResolvedPath)" -ForegroundColor Red
    }
}
Write-Host "==========================================================`n" -ForegroundColor Cyan
