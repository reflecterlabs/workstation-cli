#!/bin/bash
#
# Workstation CLI Release Script
# Crea un tarball listo para distribución
#

set -euo pipefail

VERSION="${1:-3.0.0}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${REPO_DIR}/build"
RELEASE_DIR="${BUILD_DIR}/workstation-cli-${VERSION}"
TARBALL="${BUILD_DIR}/workstation-cli-${VERSION}.tar.gz"

echo "Building Workstation CLI v${VERSION}..."

# Limpiar y crear directorios
rm -rf "${BUILD_DIR}"
mkdir -p "${RELEASE_DIR}/bin" "${RELEASE_DIR}/templates/seat"

# Copiar archivos principales
cp "${REPO_DIR}/bin/workstation" "${RELEASE_DIR}/bin/"
cp "${REPO_DIR}/install.sh" "${RELEASE_DIR}/"
cp "${REPO_DIR}/Makefile" "${RELEASE_DIR}/"
cp "${REPO_DIR}/README.md" "${RELEASE_DIR}/"
cp "${REPO_DIR}/LICENSE" "${RELEASE_DIR}/" 2>/dev/null || echo "MIT License" > "${RELEASE_DIR}/LICENSE"

# Copiar templates
cp "${REPO_DIR}/templates/seat/"*.md "${RELEASE_DIR}/templates/seat/"

# Hacer ejecutables
chmod +x "${RELEASE_DIR}/bin/workstation"
chmod +x "${RELEASE_DIR}/install.sh"

# Crear tarball
cd "${BUILD_DIR}"
tar -czf "${TARBALL}" "workstation-cli-${VERSION}"

# Calcular checksums
cd "${REPO_DIR}"
sha256sum "${TARBALL}" > "${TARBALL}.sha256"

echo ""
echo "✓ Release built successfully!"
echo ""
echo "Archives:"
echo "  ${TARBALL}"
echo "  ${TARBALL}.sha256"
echo ""
echo "Instalación:"
echo "  tar -xzf workstation-cli-${VERSION}.tar.gz"
echo "  cd workstation-cli-${VERSION}"
echo "  make install"
echo ""
echo "O directamente:"
echo "  curl -fsSL https://github.com/reflecterlabs/workstation-cli/releases/download/v${VERSION}/workstation-cli-${VERSION}.tar.gz | tar -xz"
echo "  cd workstation-cli-${VERSION} && sudo make install"
