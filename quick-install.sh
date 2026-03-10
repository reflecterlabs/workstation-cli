#!/bin/bash
#
# Quick Install Script for Workstation CLI
# Uso: curl -fsSL https://openclaw.ai/workstation-install.sh | bash
#

set -euo pipefail

REPO="reflecterlabs/workstation-cli"
VERSION="${1:-latest}"
INSTALL_DIR="/usr/local/bin"

echo "Workstation CLI Quick Installer"
echo "==============================="
echo ""

# Detectar OS
OS=$(uname -s)
case "$OS" in
  Linux*)     PLATFORM="linux";;
  Darwin*)    PLATFORM="macos";;
  *)          echo "OS no soportado: $OS"; exit 1;;
esac

echo "Plataforma: $PLATFORM"
echo ""

# Verificar dependencias
echo "Verificando dependencias..."
if ! command -v jq &> /dev/null; then
    echo "❌ jq no está instalado"
    echo "Instala con: sudo apt-get install jq (Debian/Ubuntu) o brew install jq (macOS)"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "❌ git no está instalado"
    exit 1
fi

echo "✓ Dependencias OK"
echo ""

# Descargar
if [ "$VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/workstation-cli.tar.gz"
else
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${VERSION}/workstation-cli-${VERSION}.tar.gz"
fi

echo "Descargando Workstation CLI..."
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/workstation-cli.tar.gz"; then
    echo "❌ Error descargando"
    exit 1
fi

echo "✓ Descargado"
echo ""

# Extraer e instalar
echo "Instalando..."
tar -xzf "$TMP_DIR/workstation-cli.tar.gz" -C "$TMP_DIR"

CLI_DIR=$(find "$TMP_DIR" -name "workstation-cli-*" -type d | head -1)

if [[ -w "$INSTALL_DIR" ]]; then
    cp "${CLI_DIR}/bin/workstation" "$INSTALL_DIR/"
    chmod +x "${INSTALL_DIR}/workstation"
else
    echo "Se requieren privilegios de administrador..."
    sudo cp "${CLI_DIR}/bin/workstation" "$INSTALL_DIR/"
    sudo chmod +x "${INSTALL_DIR}/workstation"
fi

echo "✓ Instalado en $INSTALL_DIR"
echo ""

# Verificar
if workstation version; then
    echo ""
    echo "✓ Workstation CLI instalado correctamente!"
    echo ""
    echo "Primeros pasos:"
    echo "  1. workstation init MiOrganizacion"
    echo "  2. cd ~/Workstation/MiOrganizacion-SSOT"
    echo "  3. workstation seat create mi-agente --role desarrollo"
    echo ""
    echo "Documentación: workstation help"
else
    echo "❌ Error verificando instalación"
    exit 1
fi
