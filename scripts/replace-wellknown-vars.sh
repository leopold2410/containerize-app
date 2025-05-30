#!/bin/sh
set -e

echo "VITE_API_URL: ${VITE_API_URL}"
echo "ASSET_DIR: ${ASSET_DIR}"

find ${ASSET_DIR} -type f \( -name '*.js' -o -name '*.css' \) -exec sed -i "s|__VITE_API_URL__|${VITE_API_URL}|g" '{}' +