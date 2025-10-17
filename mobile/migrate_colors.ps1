# PowerShell Script to Replace Orange with Purple Theme
# Run from mobile/lib directory

$files = Get-ChildItem -Recurse -Filter *.dart

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Replace Color(0xFFFF9800) with AppTheme.primary
    if ($content -match 'Color\(0xFFFF9800\)') {
        $content = $content -replace 'Color\(0xFFFF9800\)', 'AppTheme.primary'
        $modified = $true
    }
    
    # Replace Colors.orange with AppTheme.primary
    if ($content -match 'Colors\.orange(?!\[)') {
        $content = $content -replace 'Colors\.orange(?!\[)', 'AppTheme.primary'
        $modified = $true
    }
    
    # Replace Colors.orange[50] with AppTheme.primary.withValues(alpha: 0.1)
    if ($content -match 'Colors\.orange\[50\]') {
        $content = $content -replace 'Colors\.orange\[50\]', 'AppTheme.primary.withValues(alpha: 0.1)'
        $modified = $true
    }
    
    # Replace Colors.orange[700] with AppTheme.primaryDark
    if ($content -match 'Colors\.orange\[700\]') {
        $content = $content -replace 'Colors\.orange\[700\]', 'AppTheme.primaryDark'
        $modified = $true
    }
    
    # Replace Colors.orange[900] with AppTheme.primaryDark
    if ($content -match 'Colors\.orange\[900\]') {
        $content = $content -replace 'Colors\.orange\[900\]', 'AppTheme.primaryDark'
        $modified = $true
    }
    
    # Replace BitmapDescriptor.hueOrange with hue for purple (270)
    if ($content -match 'BitmapDescriptor\.hueOrange') {
        $content = $content -replace 'BitmapDescriptor\.hueOrange', '270.0'
        $modified = $true
    }
    
    # Replace marker hue 30.0 (orange) with 270.0 (purple)
    if ($content -match 'hue:\s*30\.0') {
        $content = $content -replace 'hue:\s*30\.0', 'hue: 270.0'
        $modified = $true
    }
    
    # Add import if modified and doesn't have it
    if ($modified -and $content -notmatch "import.*app_theme\.dart") {
        # Find the last import statement
        if ($content -match "(import\s+'package:flutter/material\.dart';)") {
            $content = $content -replace "(import\s+'package:flutter/material\.dart';)", "`$1`nimport '../../utils/app_theme.dart'; // Auto-added"
        }
    }
    
    if ($modified) {
        Set-Content $file.FullName -Value $content -NoNewline
        Write-Host "Updated: $($file.FullName)" -ForegroundColor Green
    }
}

Write-Host "`nColor migration complete!" -ForegroundColor Cyan
