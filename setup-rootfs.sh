#!/bin/bash
set -e

ROOTFS_DIR=/rootfs
ROOTFS_IMG=/kernel/rootfs.img
LTP_DIR=/kernel/ltp
IMG_SIZE_MB=4096

echo "=== Step 1: Create rootfs with debootstrap ==="
debootstrap --arch=arm64 jammy "$ROOTFS_DIR" http://ports.ubuntu.com/ubuntu-ports

echo "=== Step 2: Build and install LTP ==="
cd "$LTP_DIR"
make autotools
./configure
make -j$(nproc)
make install DESTDIR="$ROOTFS_DIR"

echo "=== Step 3: Install kirk into rootfs ==="
pip3 install kirk --target "$ROOTFS_DIR/usr/local/lib/python3/dist-packages"
cp "$(which kirk)" "$ROOTFS_DIR/usr/local/bin/kirk"

echo "=== Step 4: Configure kirk PATH in rootfs ==="
cat >> "$ROOTFS_DIR/etc/profile" << 'EOF'
export PATH=$PATH:/usr/local/lib/python3/dist-packages/bin
EOF

echo "=== Step 5: Package rootfs into image ==="
dd if=/dev/zero of="$ROOTFS_IMG" bs=1M count="$IMG_SIZE_MB"
mkfs.ext4 -d "$ROOTFS_DIR" "$ROOTFS_IMG"

echo "=== Done ==="
echo "rootfs image: $ROOTFS_IMG"
echo ""
echo "Boot with:"
echo "  qemu-system-aarch64 \\"
echo "    -M virt \\"
echo "    -cpu cortex-a57 \\"
echo "    -m 2G \\"
echo "    -kernel /kernel/linux/arch/arm64/boot/Image \\"
echo "    -append \"root=/dev/vda rw console=ttyAMA0 init=/bin/bash\" \\"
echo "    -drive file=$ROOTFS_IMG,format=raw,if=virtio \\"
echo "    -nographic"
