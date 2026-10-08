# MyLinux (MyServerOS)

A minimal embedded Linux server tree built on top of **Buildroot**
(`BR2_EXTERNAL` external tree).

The goal is a tiny, bootable Linux server for x86_64 that runs directly in
**VirtualBox** — systemd + SSH.

## Architecture

```
Windows (developer)
   ├── Write code / edit config
   ├── Git commit
   ├── Git push
   └── Manage GitHub
           │
           ▼
      GitHub Actions (Linux runner)
           ├── Download Buildroot
           ├── Read MyLinux external tree config
           ├── Compile kernel + toolchain
           ├── Build rootfs + packages
           └── Generate disk image
                  │
                  ▼
           GitHub Release / Artifact
                  │
                  ▼
        Windows: download image
           │
        ┌──┴────┐
        ▼       ▼
     VirtualBox
```

Windows only needs VS Code + Git + GitHub. All compilation happens on
GitHub Actions.

## Directory layout

```
mylinux/
├── .github/
│   └── workflows/
│       └── build.yml            # GitHub Actions build pipeline
│
├── board/
│   └── mylinux/
│       ├── linux.config         # Kernel config (generic x86_64)
│       ├── genimage-bios.cfg    # Disk image layout
│       └── rootfs-overlay/      # /etc, init scripts, overlay files
│
├── configs/
│   └── mylinux_x86_64_defconfig # Full Buildroot defconfig
│
├── external.desc                # External tree registration
├── external.mk                  # External tree makefile
└── README.md
```

## v0.2: systemd

| Item | Value |
| --- | --- |
| Architecture | x86_64 (generic PC / BIOS) |
| Kernel | 6.1.24 (custom config) |
| Init system | systemd |
| Network | systemd-networkd (DHCP eth0) |
| SSH | OpenSSH |
| Root filesystem | ext4 (8G) |
| Bootloader | GRUB2 (BIOS) |
| Output | bootable `.img` for VirtualBox |

## Build locally (optional)

Only needed if you want to build on a Linux machine instead of GitHub:

```bash
git clone https://gitlab.com/buildroot.org/buildroot.git
cd buildroot
make BR2_EXTERNAL=/path/to/mylinux O=build mylinux_x86_64_defconfig
make BR2_EXTERNAL=/path/to/mylinux O=build -j"$(nproc)"
genimage -c /path/to/mylinux/board/mylinux/genimage-bios.cfg
```

## Test in VirtualBox

1. Create a new VM: Linux / Other Linux 64-bit
2. CPU: 2–4 cores, RAM: 2–4 GB, Disk: 20 GB
3. Use the generated `disk.img` as a virtual disk
4. Boot → login as `root` (password: root)
5. From host: `ssh root@<vm-ip> -p 2222` (with port forwarding)