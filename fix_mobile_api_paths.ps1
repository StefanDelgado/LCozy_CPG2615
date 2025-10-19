# PowerShell Script to Fix All Mobile API Paths
# Date: October 19, 2025

$rootPath = "C:\xampp\htdocs\WebDesign_BSITA-2\2nd sem\Joshan_System\LCozy_CPG2615\Main\modules\mobile-api"

Write-Host "🔧 Fixing Mobile API Paths..." -ForegroundColor Cyan
Write-Host ""

# Define folders and their correct paths relative to their location
$folders = @{
    "owner" = @{
        "config" = "/../../../config.php"
        "cors" = "/../shared/cors.php"
    }
    "student" = @{
        "config" = "/../../../config.php"
        "cors" = "/../shared/cors.php"
    }
    "rooms" = @{
        "config" = "/../../../config.php"
        "cors" = "/../shared/cors.php"
    }
    "messaging" = @{
        "config" = "/../../../config.php"
        "cors" = "/../shared/cors.php"
    }
    "payments" = @{
        "config" = "/../../../config.php"
        "cors" = "/../shared/cors.php"
    }
    "bookings" = @{
        "config" = "/../../../config.php"
        "cors" = "/../shared/cors.php"
    }
    "dorms" = @{
        "config" = "/../../../config.php"
        "cors" = "/../shared/cors.php"
    }
    "auth" = @{
        # Already fixed (login-api.php)
    }
}

$fixedCount = 0
$skippedCount = 0

foreach ($folder in $folders.Keys) {
    $folderPath = Join-Path $rootPath $folder
    
    if (-not (Test-Path $folderPath)) {
        Write-Host "⚠️  Folder not found: $folder" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "📁 Processing folder: $folder" -ForegroundColor Green
    
    $phpFiles = Get-ChildItem -Path $folderPath -Filter "*.php"
    
    foreach ($file in $phpFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        $modified = $false
        
        # Skip if already has correct paths
        if ($content -match "require_once __DIR__ \. '/\.\./\.\./\.\./config\.php';" -and 
            $content -match "require_once __DIR__ \. '/\.\./shared/cors\.php';") {
            Write-Host "  ✅ $($file.Name) - Already correct" -ForegroundColor Gray
            $skippedCount++
            continue
        }
        
        # Fix config.php path - handle various wrong patterns
        $wrongConfigPatterns = @(
            "require_once __DIR__ \. '/\.\./config\.php';",
            "require_once __DIR__ \. '/\.\./\.\./config\.php';",
            "require_once __DIR__\s*\.\s*'/\.\./config\.php';",
            "require_once __DIR__\s*\.\s*'/\.\./\.\./config\.php';"
        )
        
        foreach ($pattern in $wrongConfigPatterns) {
            if ($content -match $pattern) {
                $content = $content -replace $pattern, "require_once __DIR__ . '/../../../config.php';"
                $modified = $true
                break
            }
        }
        
        # Fix cors.php path - handle various wrong patterns
        $wrongCorsPatterns = @(
            "require_once __DIR__ \. '/cors\.php';",
            "require_once __DIR__\s*\.\s*'/cors\.php';",
            "require_once __DIR__ \. 'cors\.php';"
        )
        
        foreach ($pattern in $wrongCorsPatterns) {
            if ($content -match $pattern) {
                $content = $content -replace $pattern, "require_once __DIR__ . '/../shared/cors.php';"
                $modified = $true
                break
            }
        }
        
        # Special case: Fix geocoding_helper path for dorms folder
        if ($folder -eq "dorms" -and $content -match "require_once __DIR__ \. '/geocoding_helper\.php';") {
            $content = $content -replace "require_once __DIR__ \. '/geocoding_helper\.php';", "require_once __DIR__ . '/../shared/geocoding_helper.php';"
            $modified = $true
        }
        
        if ($modified) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "  ✅ Fixed: $($file.Name)" -ForegroundColor Green
            $fixedCount++
        } else {
            Write-Host "  ⏭️  Skipped: $($file.Name) (no changes needed)" -ForegroundColor Gray
            $skippedCount++
        }
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ Fixed: $fixedCount files" -ForegroundColor Green
Write-Host "⏭️  Skipped: $skippedCount files" -ForegroundColor Gray
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 All mobile API paths have been fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Correct path structure:" -ForegroundColor Yellow
Write-Host "   config.php:  __DIR__ . '/../../../config.php'" -ForegroundColor White
Write-Host "   cors.php:    __DIR__ . '/../shared/cors.php'" -ForegroundColor White
Write-Host ""
