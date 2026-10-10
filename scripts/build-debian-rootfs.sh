
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${1:?Usage: build-debian-rootfs.sh ROOTFS_DIR}"
ROOT="$(realpath -m "$ROOT")"

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: this script must run as root" >&2
    exit 1
fi

apt-get update
apt-get install -y debootstrap ca-certificates

mkdir -p "$ROOT"

if [[ ! -f "$ROOT/etc/debian_version" ]]; then
    debootstrap \
        --arch=amd64 \
        --variant=minbase \
        trixie "$ROOT" https://deb.debian.org/debian
fi

install -d "$ROOT/etc/apt/sources.list.d"

cat > "$ROOT/etc/apt/sources.list.d/debian.sources" <<'EOF'
Types: deb
URIs: https://deb.debian.org/debian
Suites: trixie trixie-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://security.debian.org/debian-security
Suites: trixie-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

echo mylinux > "$ROOT/etc/hostname"

install -d "$ROOT/etc"

cat > "$ROOT/etc/hosts" <<'EOF'
127.0.0.1 localhost
127.0.1.1 mylinux
::1 localhost ip6-localhost ip6-loopback
EOF

cat > "$ROOT/etc/fstab" <<'EOF'
LABEL=MYLINUX_ROOT / ext4 defaults,noatime 0 1
EOF

# Make package downloads and DNS work inside chroot.
cp -L /etc/resolv.conf "$ROOT/etc/resolv.conf"

for d in dev dev/pts proc sys run; do
    mkdir -p "$ROOT/$d"
done

mount --rbind /dev "$ROOT/dev"
mount --make-rslave "$ROOT/dev"
mount -t proc proc "$ROOT/proc"
mount --rbind /sys "$ROOT/sys"
mount --make-rslave "$ROOT/sys"
mount --bind /run "$ROOT/run"

cleanup() {
    for d in run sys proc dev; do
        mountpoint -q "$ROOT/$d" && umount -R "$ROOT/$d" || true
    done
}
trap cleanup EXIT

chroot "$ROOT" /usr/bin/env DEBIAN_FRONTEND=noninteractive \
    apt-get update

chroot "$ROOT" /usr/bin/env DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    systemd systemd-sysv \
    apt ca-certificates \
    bash coreutils util-linux \
    iproute2 iputils-ping isc-dhcp-client \
    network-manager \
    openssh-server sudo \
    initramfs-tools \
    build-essential gcc g++ make \
    git curl wget \
    python3 python3-pip python3-venv \
    cmake ninja-build pkg-config \
    vim-tiny less file pciutils usbutils \
    grub-pc-bin grub2-common

# Enable services without starting them in the build container.
chroot "$ROOT" systemctl enable NetworkManager.service
chroot "$ROOT" systemctl enable ssh.service

chroot "$ROOT" apt-get clean
rm -rf "$ROOT/var/lib/apt/lists/"*

echo "Debian 13 rootfs prepared at: $ROOT"
