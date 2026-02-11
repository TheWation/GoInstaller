#!/usr/bin/env bash
# ============================================================
#  Go Language Installer (Linux / macOS)
#  Mirrors: github.com/TheWation/GoInstaller
#
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/TheWation/GoInstaller/main/install.sh | bash
#    wget -qO- https://raw.githubusercontent.com/TheWation/GoInstaller/main/install.sh | bash
# ============================================================

set -euo pipefail

# ── Configuration ────────────────────────────────────────────
GO_VERSION="${GO_VERSION:-1.26.0}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local}"
REPO_BASE_URL="https://raw.githubusercontent.com/TheWation/GoInstaller/main/releases"

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Detect OS ────────────────────────────────────────────────
detect_os() {
    local os
    os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    case "$os" in
        linux*)  echo "linux" ;;
        darwin*) echo "darwin" ;;
        *)       error "Unsupported operating system: $os" ;;
    esac
}

# ── Detect Architecture ─────────────────────────────────────
detect_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64)   echo "amd64" ;;
        aarch64|arm64)   echo "arm64" ;;
        armv6l|armv7l)   echo "armv6l" ;;
        i386|i686)       echo "386" ;;
        *)               error "Unsupported architecture: $arch" ;;
    esac
}

# ── Check if command exists ──────────────────────────────────
command_exists() {
    command -v "$1" &>/dev/null
}

# ── Download file ────────────────────────────────────────────
download() {
    local url="$1"
    local dest="$2"

    if command_exists curl; then
        curl -fsSL "$url" -o "$dest"
    elif command_exists wget; then
        wget -qO "$dest" "$url"
    else
        error "Neither 'curl' nor 'wget' found. Please install one of them."
    fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
    echo ""
    echo "=========================================="
    echo "   Go ${GO_VERSION} Installer"
    echo "   github.com/TheWation/GoInstaller"
    echo "=========================================="
    echo ""

    # Detect platform
    local os arch
    os="$(detect_os)"
    arch="$(detect_arch)"
    info "Detected OS: ${os}, Arch: ${arch}"

    # Build filename and URL
    local filename="go${GO_VERSION}.${os}-${arch}.tar.gz"
    local url="${REPO_BASE_URL}/${filename}"
    info "Download URL: ${url}"

    # Create temp directory
    local tmpdir
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    local tmpfile="${tmpdir}/${filename}"

    # Download
    info "Downloading ${filename}..."
    download "$url" "$tmpfile"
    success "Download complete."

    # Verify file was downloaded
    if [[ ! -s "$tmpfile" ]]; then
        error "Downloaded file is empty or does not exist."
    fi

    # Check for sudo
    local sudo_cmd=""
    if [[ "$EUID" -ne 0 ]]; then
        if command_exists sudo; then
            sudo_cmd="sudo"
            warn "Not running as root. Using sudo for installation."
        else
            error "This script requires root privileges. Please run as root or install sudo."
        fi
    fi

    # Remove old installation
    if [[ -d "${INSTALL_DIR}/go" ]]; then
        info "Removing previous Go installation at ${INSTALL_DIR}/go..."
        $sudo_cmd rm -rf "${INSTALL_DIR}/go"
    fi

    # Extract
    info "Installing Go ${GO_VERSION} to ${INSTALL_DIR}/go..."
    $sudo_cmd tar -C "$INSTALL_DIR" -xzf "$tmpfile"
    success "Go ${GO_VERSION} installed to ${INSTALL_DIR}/go"

    # Setup PATH
    local go_bin="${INSTALL_DIR}/go/bin"
    local shell_profile=""

    if [[ "$os" == "darwin" ]]; then
        shell_profile="$HOME/.zprofile"
    elif [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
        shell_profile="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_profile="$HOME/.bashrc"
    else
        shell_profile="$HOME/.profile"
    fi

    local path_line="export PATH=\$PATH:${go_bin}"

    # Check if PATH already configured
    if grep -qF "$go_bin" "$shell_profile" 2>/dev/null; then
        info "PATH already configured in ${shell_profile}"
    else
        info "Adding Go to PATH in ${shell_profile}..."
        echo "" >> "$shell_profile"
        echo "# Go Language" >> "$shell_profile"
        echo "$path_line" >> "$shell_profile"
        success "PATH updated in ${shell_profile}"
    fi

    # Add to current session
    export PATH="$PATH:${go_bin}"

    # Verify installation
    echo ""
    if command_exists go; then
        success "Installation complete!"
        echo ""
        info "Go version: $(go version)"
        info "Go root:    $(go env GOROOT)"
        echo ""
        warn "Run 'source ${shell_profile}' or open a new terminal to use Go."
    else
        error "Installation may have failed. 'go' command not found."
    fi

    echo ""
    echo "=========================================="
    echo "   Installation finished successfully!"
    echo "=========================================="
    echo ""
}

main "$@"