#!/bin/bash
set -e

SUITE=${1:-sched}
KERNEL=arch/arm64/boot/Image

SCRIPT=$(mktemp /tmp/run-ltp-XXXXXX.sh)
cat > "$SCRIPT" << EOF
#!/bin/sh
kirk --workers 8 --run-suite $SUITE
EOF
chmod +x "$SCRIPT"

virtme-ng --run "$KERNEL" --exec "$SCRIPT" --verbose

rm -f "$SCRIPT"
