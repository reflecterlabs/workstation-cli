#!/bin/bash
#
# Workstation CLI Installer v3.0
# Safe, verifiable installation
#

set -e

REPO="reflecterlabs/workstation-cli"
INSTALL_DIR="/usr/local/bin"
VERSION="${1:-latest}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

die() {
  log_error "$1"
  exit 1
}

echo "Workstation CLI Installer"
echo "========================="
echo ""

# Safety warning
echo "⚠️  SECURITY NOTICE"
echo "This script will install software to: $INSTALL_DIR"
echo "Review the source at: https://github.com/$REPO"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  die "Installation cancelled"
fi

# Detect OS
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
  Linux*)     PLATFORM="linux";;
  Darwin*)    PLATFORM="macos";;
  *)          die "Unsupported OS: $OS";;
esac

log_info "Detected: $PLATFORM ($ARCH)"
echo ""

# Check dependencies
echo "Checking dependencies..."

if ! command -v jq &> /dev/null; then
  log_warn "jq is required but not installed"
  echo "Install with:"
  case "$PLATFORM" in
    linux) echo "  sudo apt-get install jq  (Debian/Ubuntu)"
           echo "  sudo yum install jq      (RHEL/CentOS)"
           echo "  sudo pacman -S jq        (Arch)"
           ;;
    macos) echo "  brew install jq" ;;
  esac
  exit 1
fi

if ! command -v git &> /dev/null; then
  die "git is required but not installed"
fi

log_success "All dependencies satisfied"
echo ""

# Check if installing from local source
if [[ -f "$(dirname "$0")/../bin/workstation" ]]; then
  log_info "Installing from local source..."
  
  if [[ -w "$INSTALL_DIR" ]]; then
    cp "$(dirname "$0")/../bin/workstation" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/workstation"
  else
    sudo cp "$(dirname "$0")/../bin/workstation" "$INSTALL_DIR/"
    sudo chmod +x "$INSTALL_DIR/workstation"
  fi
else
  # Download from release
  log_info "Downloading Workstation CLI..."
  
  if [ "$VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/workstation-cli.tar.gz"
  else
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/workstation-cli-${VERSION}.tar.gz"
  fi
  
  TMP_DIR=$(mktemp -d)
  trap "rm -rf $TMP_DIR" EXIT
  
  if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/workstation-cli.tar.gz"; then
    die "Download failed. Check your internet connection."
  fi
  
  log_success "Downloaded"
  echo ""
  
  log_info "Extracting..."
  tar -xzf "$TMP_DIR/workstation-cli.tar.gz" -C "$TMP_DIR"
  log_success "Extracted"
  echo ""
  
  log_info "Installing to $INSTALL_DIR..."
  if [[ -w "$INSTALL_DIR" ]]; then
    cp "$TMP_DIR/bin/workstation" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/workstation"
  else
    sudo cp "$TMP_DIR/bin/workstation" "$INSTALL_DIR/"
    sudo chmod +x "$INSTALL_DIR/workstation"
  fi
fi

echo ""
log_success "Installed"
echo ""

# Verify
echo "Verifying installation..."
if workstation version; then
  echo ""
  log_success "Workstation CLI installed successfully!"
  echo ""
  echo "Next steps:"
  echo "  1. workstation init MyOrganization"
  echo "  2. cd ~/Workstation/MyOrganization-SSOT"
  echo "  3. workstation seat create my-agent --role developer"
  echo ""
  echo "Documentation: https://github.com/${REPO}"
else
  die "Installation verification failed"
fi
