# Fix: AUTO mode restart loop on Raspberry Pi Zero W (ARMv6)

## The problem

On the original Raspberry Pi Zero W (and other ARMv6 boards), Pwnagotchi
boots and runs fine in MANU mode, but crash-loops as soon as it switches to
AUTO mode: the e-ink screen resets, uptime never climbs past a few seconds,
and the unit just keeps restarting.

The cause: the Python `websockets` library ships a compiled C extension
(`speedups*.so`) built for ARMv7. The Pi Zero W's CPU is ARMv6, which
doesn't support the instructions in that binary, so loading it triggers an
illegal instruction (SIGILL) and crashes the process. This only shows up in
AUTO mode because that's when the websocket connection to bettercap
actually gets used — MANU mode never touches it. See upstream issue
[#650](https://github.com/jayofelony/pwnagotchi/issues/650).

## The fix

Disable the broken compiled extension and let `websockets` fall back to its
pure-Python implementation, which works fine here (marginally slower, but
that doesn't matter for this use case).

SSH into your Pi (or use a keyboard/monitor) and run:

```bash
sudo bash -c '
for f in /opt/.pwn/lib/python3*/site-packages/websockets/speedups*.so; do
  mv "$f" "$f.disabled"
done
systemctl restart pwnagotchi
'
```

Or download and run the included script:

```bash
curl -sSL https://raw.githubusercontent.com/Skull-Bones/pwnagotchi/noai/scripts/fix-armv6-websockets.sh | sudo bash
```

This is a one-time rename on disk, not a runtime patch, so it survives
reboots — you only need to run it once after flashing.

## Tested on

- Raspberry Pi Zero W (v1.1, ARMv6)
- Waveshare 2.13" e-ink V4 HAT
- pwnagotchi 32-bit v2.9.5.5
