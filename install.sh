#!/bin/sh
set -e

# Pick a SHA256 utility that exists on this host.
if command -v sha256sum >/dev/null 2>&1; then
  SHA_CMD="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  SHA_CMD="shasum -a 256"
else
  echo "Error: neither sha256sum nor shasum available; cannot verify download" >&2
  exit 1
fi

REPO="pullminder/cli"
BINARY_NAME="pullminder"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

# Detect OS
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$OS" in
  linux)  OS="linux" ;;
  darwin) OS="darwin" ;;
  *)      echo "Error: unsupported OS: $OS" >&2; exit 1 ;;
esac

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64)  ARCH="amd64" ;;
  aarch64|arm64)  ARCH="arm64" ;;
  *)              echo "Error: unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

# Determine download URL
if [ -n "$VERSION" ]; then
  TAG="v${VERSION}"
  DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${TAG}/${BINARY_NAME}-${OS}-${ARCH}"
else
  DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}-${OS}-${ARCH}"
fi

echo "Downloading ${BINARY_NAME} for ${OS}/${ARCH}..."

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

CHECKSUMS_URL="$(dirname "$DOWNLOAD_URL")/checksums.txt"

curl -fsSL "$DOWNLOAD_URL" -o "${TMPDIR}/${BINARY_NAME}"
curl -fsSL "$CHECKSUMS_URL" -o "${TMPDIR}/checksums.txt"

ARTIFACT_NAME="${BINARY_NAME}-${OS}-${ARCH}"
EXPECTED="$(grep " ${ARTIFACT_NAME}\$" "${TMPDIR}/checksums.txt" | awk '{print $1}')"
if [ -z "$EXPECTED" ]; then
  echo "Error: ${ARTIFACT_NAME} not listed in checksums.txt — refusing to install" >&2
  exit 1
fi

ACTUAL="$(${SHA_CMD} "${TMPDIR}/${BINARY_NAME}" | awk '{print $1}')"
if [ "$EXPECTED" != "$ACTUAL" ]; then
  echo "Error: SHA256 mismatch for ${ARTIFACT_NAME}" >&2
  echo "  expected: $EXPECTED" >&2
  echo "  actual:   $ACTUAL" >&2
  exit 1
fi

chmod +x "${TMPDIR}/${BINARY_NAME}"

# Ensure install directory exists
mkdir -p "$INSTALL_DIR"

echo "Installing to ${INSTALL_DIR}/${BINARY_NAME}..."
mv "${TMPDIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"

echo "Installed ${BINARY_NAME} to ${INSTALL_DIR}/${BINARY_NAME}"
"${INSTALL_DIR}/${BINARY_NAME}" version

# Check if INSTALL_DIR is in PATH
case ":$PATH:" in
  *":${INSTALL_DIR}:"*) ;;
  *)
    echo ""
    echo "NOTE: ${INSTALL_DIR} is not in your PATH."
    echo "Add it by running:"
    echo ""
    echo "  echo 'export PATH=\"${INSTALL_DIR}:\$PATH\"' >> ~/.zshrc   # zsh"
    echo "  echo 'export PATH=\"${INSTALL_DIR}:\$PATH\"' >> ~/.bashrc  # bash"
    echo ""
    echo "Then restart your shell or run: source ~/.zshrc"
    ;;
esac
