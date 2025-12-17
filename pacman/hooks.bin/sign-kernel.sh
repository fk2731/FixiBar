#!/usr/bin/env bash

set -euo pipefail

KEY="/etc/refind.d/keys/refind_local.key"
CERT="/etc/refind.d/keys/refind_local.crt"

[ -f "$KEY" ] && [ -f "$CERT" ] || exit 0

for kernel in /boot/vmlinuz-linux*; do
  [[ "$kernel" == *.png ]] && continue
  echo "Signing $kernel"
  /usr/bin/sbsign \
    --key "$KEY" \
    --cert "$CERT" \
    --output "${kernel}.signed" \
    "$kernel" &&
  /usr/bin/mv "${kernel}.signed" "$kernel"
done
