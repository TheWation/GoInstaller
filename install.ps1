# ============================================================
#  Go Language Installer (Windows - PowerShell)
#  Mirrors: github.com/TheWation/GoInstaller
#
#  Usage (Run as Administrator):
#    irm https://raw.githubusercontent.com/TheWation/GoInstaller/main/install.ps1 | iex
#
#  Or save and run:
#    .\install.ps1
#    .\install.ps1 -GoVersion "1.26.0"
# ============================================================

param (
    [string]$GoVersion = "1.26.0",
    [string]$InstallDir = "C:\Program Files"
)

$ErrorActionPreference = "Stop"

# ── Configuration ────────────────────────────────────────────
$RepoBaseUrl = "https://raw.githubusercontent.com/TheWation/GoInstaller/master/releases"

# ── Functions ────────────────────────────────────────────────
function Write-Info    { param($msg) Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err     { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-Arch {
    $arch = $env:PROCESSOR_ARCHITECTURE
    switch ($arch) {
        "AMD64"  { return "amd64" }
        "ARM64"  { return "arm64" }
        "x86"    { return "386" }
        default  { Write-Err "Unsupported architecture: $arch" }
    }
}

# ── Main ─────────────────────────────────────────────────────
function Main {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor White
    Write-Host "   Go $GoVersion Installer (Windows)"       -ForegroundColor White
    Write-Host "   github.com/TheWation/GoInstaller"        -ForegroundColor Gray
    Write-Host "==========================================" -ForegroundColor White
    Write-Host ""

    # Check Administrator privileges
    if (-not (Test-Admin)) {
        Write-Warn "Not running as Administrator. Some operations may fail."
        Write-Warn "Please run PowerShell as Administrator for system-wide installation."
        Write-Host ""
    }

    # Detect architecture
    $arch = Get-Arch
    Write-Info "Detected Architecture: $arch"

    # Build filename and URL
    $filename = "go${GoVersion}.windows-${arch}.zip"
    $url = "${RepoBaseUrl}/${filename}"
    Write-Info "Download URL: $url"

    # Create temp directory
    $tempDir = Join-Path $env:TEMP "go-installer-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    $tempFile = Join-Path $tempDir $filename

    try {
        # Download
        Write-Info "Downloading $filename..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $tempFile -UseBasicParsing
        Write-Success "Download complete."

        # Verify file
        if (-not (Test-Path $tempFile) -or (Get-Item $tempFile).Length -eq 0) {
            Write-Err "Downloaded file is empty or does not exist."
        }

        $goRoot = Join-Path $InstallDir "Go"

        # Remove old installation
        if (Test-Path $goRoot) {
            Write-Info "Removing previous Go installation at $goRoot..."
            Remove-Item -Recurse -Force $goRoot
        }

        # Extract
        Write-Info "Installing Go $GoVersion to $goRoot..."
        Expand-Archive -Path $tempFile -DestinationPath $InstallDir -Force
        Write-Success "Go $GoVersion extracted to $goRoot"

        # Rename folder if needed (archive extracts to "go" folder)
        $extractedDir = Join-Path $InstallDir "go"
        if ((Test-Path $extractedDir) -and ($extractedDir -ne $goRoot)) {
            if (Test-Path $goRoot) {
                Remove-Item -Recurse -Force $goRoot
            }
            Rename-Item -Path $extractedDir -NewName "Go"
        }

        # Setup PATH
        $goBin = Join-Path $goRoot "bin"

        # Check current Machine PATH
        $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($machinePath -notlike "*$goBin*") {
            Write-Info "Adding Go to system PATH..."
            try {
                [Environment]::SetEnvironmentVariable("Path", "$machinePath;$goBin", "Machine")
                Write-Success "System PATH updated."
            }
            catch {
                Write-Warn "Could not update system PATH (requires Administrator)."
                Write-Warn "Please manually add '$goBin' to your system PATH."
            }
        }
        else {
            Write-Info "Go is already in system PATH."
        }

        # Add to current session
        if ($env:Path -notlike "*$goBin*") {
            $env:Path += ";$goBin"
        }

        # Setup GOPATH
        $goPath = Join-Path $env:USERPROFILE "go"
        if (-not (Test-Path $goPath)) {
            New-Item -ItemType Directory -Path $goPath -Force | Out-Null
            Write-Info "Created GOPATH directory: $goPath"
        }

        # Verify installation
        Write-Host ""
        $goExe = Join-Path $goBin "go.exe"
        if (Test-Path $goExe) {
            $version = & $goExe version
            Write-Success "Installation complete!"
            Write-Host ""
            Write-Info "Go version: $version"
            Write-Info "GOROOT:     $goRoot"
            Write-Info "GOPATH:     $goPath"
        }
        else {
            Write-Err "Installation may have failed. go.exe not found at $goExe"
        }
    }
    finally {
        # Cleanup
        if (Test-Path $tempDir) {
            Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
        }
    }

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor White
    Write-Host "   Installation finished successfully!"     -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor White
    Write-Host ""
    Write-Warn "Open a NEW terminal to use the 'go' command."
    Write-Host ""
}

Main
