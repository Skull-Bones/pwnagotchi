bash
#!/usr/bin/env bash
# Fixes the AUTO-mode restart loop on ARMv6 boards (e.g. Raspberry Pi Zero W)
# caused by the websockets library's ARMv7-only compiled extension triggering
# an illegal instruction (SIGILL) when AUTO mode opens a websocket to bettercap.
# See: https://github.com/jayofelony/pwnagotchi/issues/650
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this with sudo: sudo bash fix-armv6-websockets.sh" >&2
  exit 1
fi

shopt -s nullglob
found=0
for f in /opt/.pwn/lib/python3*/site-packages/websockets/speedups*.so; do
  mv "$f" "$f.disabled"
  echo "Disabled: $f"
  found=1
done

if [ "$found" -eq 0 ]; then
  echo "No speedups*.so files found. Either already fixed, or this isn't an ARMv6 install."
  exit 0
fi

systemctl restart pwnagotchi
echo "Done. pwnagotchi restarted using the pure-Python websockets fallback."
