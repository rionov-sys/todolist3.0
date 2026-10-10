# KeepGrinding — jalankan di Android terhubung ke Supabase.
#
# Pakai (PowerShell, dari root project):
#   .\tool\run_android.ps1                       # baca kredensial dari env var
#   .\tool\run_android.ps1 -BuildApk             # build APK rilis (bukan hot-reload)
#
# Kredensial bisa diisi sekali lewat environment variable:
#   $env:SUPABASE_URL="https://xxxx.supabase.co"
#   $env:SUPABASE_ANON_KEY="eyJ..."
#   $env:GOOGLE_WEB_CLIENT_ID=""                 # opsional
#
# Kalau env var tidak ada, script akan tanya (prompt) secara aman.

param(
    [switch]$BuildApk
)

$ErrorActionPreference = 'Stop'

# --- Pastikan pakai JDK 17 (JBR bawaan Android Studio = Java 25, tidak cocok Gradle) ---
$Jdk = 'C:\tools\msjdk17\jdk-17.0.20.1+1'
if (-not (Test-Path "$Jdk\bin\java.exe")) {
    Write-Warning "JDK 17 tidak ditemukan di $Jdk. Set JAVA_HOME ke JDK 17 lalu ulangi."
    exit 1
}
$env:JAVA_HOME = $Jdk
$env:PATH = "$Jdk\bin;$env:PATH"

# --- Ambil kredensial ---
if (-not $env:SUPABASE_URL)     { $env:SUPABASE_URL     = Read-Host "Supabase URL (https://xxxx.supabase.co)" }
if (-not $env:SUPABASE_ANON_KEY){ $env:SUPABASE_ANON_KEY = Read-Host "Supabase anon key" -AsSecureString | `
    ConvertFrom-SecureString -AsPlainText }
if (-not (Test-Path env:GOOGLE_WEB_CLIENT_ID)) { $env:GOOGLE_WEB_CLIENT_ID = '' }

$flutter = "$env:USERPROFILE\flutter\bin\flutter.bat"
$defines = @(
    "--dart-define=SUPABASE_URL=$env:SUPABASE_URL",
    "--dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY",
    "--dart-define=GOOGLE_WEB_CLIENT_ID=$env:GOOGLE_WEB_CLIENT_ID"
)

if ($BuildApk) {
    Write-Host ">> Building release APK..." -ForegroundColor Cyan
    & $flutter build apk --release @defines
    Write-Host "`nAPK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
} else {
    Write-Host ">> Menjalankan app di device Android (hot reload aktif)..." -ForegroundColor Cyan
    & $flutter run @defines
}
