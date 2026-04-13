#!/bin/sh
set -e

BINARY_NAME="pullminder"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
  rm "${INSTALL_DIR}/${BINARY_NAME}"
  echo "Removed ${BINARY_NAME} from ${INSTALL_DIR}"
else
  echo "${BINARY_NAME} not found in ${INSTALL_DIR}"
  echo "If you installed to a custom location, set INSTALL_DIR:"
  echo "  INSTALL_DIR=/custom/path curl -fsSL https://raw.githubusercontent.com/pullminder/cli/main/uninstall.sh | sh"
fi
