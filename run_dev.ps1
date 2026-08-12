# Helper script to automatically run local Laravel backend and Flutter app
# Usage: .\run_dev.ps1

$OutputEncoding = [System.Text.Encoding]::UTF8

# Deteksi IP Address lokal IPv4 dari Wi-Fi atau Ethernet
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.InterfaceAlias -match "Wi-Fi|Ethernet|LAN" -and $_.IPAddress -notmatch "^169\.254|^127"
} | Select-Object -First 1).IPAddress

# Fallback jika tidak menemukan IP Network
if (-not $ipAddress) {
    $ipAddress = "10.0.2.2"
    Write-Warning "[WARNING] Tidak dapat mendeteksi IP Wi-Fi/Ethernet. Menggunakan default emulator: $ipAddress"
} else {
    Write-Host "[INFO] IP Lokal terdeteksi: $ipAddress" -ForegroundColor Green
}

$baseUrl = "http://${ipAddress}:8000"

# Path ke project Laravel backend
$backendPath = "d:\laragon\www\sejenak-web"

Write-Host "[RUN] Menjalankan Laravel Backend di Terminal Baru..." -ForegroundColor Yellow
# Buka PowerShell baru dan jalankan php artisan serve
Start-Process powershell -ArgumentList "-NoExit -Command `"cd '$backendPath'; Write-Host 'Menjalankan server Laravel di $baseUrl ...' -ForegroundColor Green; php artisan serve --host=0.0.0.0 --port=8000`""

Write-Host "[RUN] Menjalankan Flutter App (Local DB) dengan BASE_URL: $baseUrl" -ForegroundColor Cyan
# Jalankan flutter run dengan argumen BASE_URL
flutter run --dart-define=BASE_URL=$baseUrl @args
