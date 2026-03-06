#!/bin/bash
#
# Workstation CLI Installer
# https://github.com/reflecterlabs/workstation-cli
#

set -e

REPO="reflecterlabs/workstation-cli"
INSTALL_DIR="/usr/local/bin"
VERSION="${1:-latest}"

echo "Workstation CLI Installer"
echo "========================="
echo ""

# Detect OS
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
  Linux*)     PLATFORM="linux";;
  Darwin*)    PLATFORM="macos";;
  CYGWIN*|MINGW*|MSYS*) PLATFORM="windows";;
  *)          echo "Unsupported OS: $OS"; exit 1;;
esac

echo "Detected: $PLATFORM ($ARCH)"
echo ""

# Check dependencies
echo "Checking dependencies..."

if ! command -v jq &> /dev/null; then
  echo "⚠️  jq is required but not installed."
  case "$PLATFORM" in
    linux)
      echo "   Install with: sudo apt-get install jq (Debian/Ubuntu)"
      echo "                 sudo yum install jq (RHEL/CentOS)"
      ;;
    macos)
      echo "   Install with: brew install jq"
      ;;
  esac
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "⚠️  git is required but not installed."
  exit 1
fi

echo "✓ All dependencies satisfied"
echo ""

# Download
echo "Downloading Workstation CLI..."

if [ "$VERSION" = "latest" ]; then
  DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/workstation-cli.tar.gz"
else
  DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/workstation-cli-${VERSION}.tar.gz"
fi

TMP_DIR=$(mktemp -d)
curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/workstation-cli.tar.gz"

echo "✓ Downloaded"
echo ""

# Extract
echo "Extracting..."
tar -xzf "$TMP_DIR/workstation-cli.tar.gz" -C "$TMP_DIR"
echo "✓ Extracted"
echo ""

# Install
echo "Installing to $INSTALL_DIR..."

if [ -w "$INSTALL_DIR" ]; then
  cp "$TMP_DIR/bin/workstation" "$INSTALL_DIR/"
  chmod +x "$INSTALL_DIR/workstation"
else
  echo "Need sudo permission to install to $INSTALL_DIR"
  sudo cp "$TMP_DIR/bin/workstation" "$INSTALL_DIR/"
  sudo chmod +x "$INSTALL_DIR/workstation"
fi

rm -rf "$TMP_DIR"

echo "✓ Installed"
echo ""

# Verify
echo "Verifying installation..."
if workstation version; then
  echo ""
  echo "✓ Workstation CLI installed successfully!"
  echo ""
  echo "Next steps:"
  echo "  1. workstation init MyOrganization"
  echo "  2. cd ~/Workstation/MyOrganization-SSOT"
  echo "  3. workstation seat create my-agent --role developer"
  echo ""
  echo "Documentation: https://github.com/${REPO}"
else
  echo "✗ Installation verification failed"
  exit 1
fi
