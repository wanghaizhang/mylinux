# MyLinux (MyServerOS)

A minimal embedded Linux server tree built on top of **Buildroot**
(`BR2_EXTERNAL` external tree).

The goal is a tiny, bootable Linux server for x86_64 that runs directly in
**VMware** or **VirtualBox** — no desktop, no systemd, just kernel +
BusyBox + SSH.

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
    VMware  VirtualBox
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
│       ├── busybox.config       # BusyBox config
│       ├── genimage.cfg         # Disk image layout
│       └── rootfs-overlay/      # /etc, init scripts, overlay files
│
├── configs/
│   └── mylinux_x86_64_defconfig # Full Buildroot defconfig
│
├── package/
│   └── myserver/                # Custom packages go here
│
├── external.desc                # External tree registration
├── external.mk                  # External tree makefile
└── README.md
```

## First version (v0.1)

| Item | Value |
| --- | --- |
| Architecture | x86_64 (generic PC / BIOS) |
| Kernel | 6.12 (generic defconfig, bzImage) |
| Init system | BusyBox init (no systemd) |
| Network | DHCP + ifconfig / ip |
| SSH | dropbear |
| Root filesystem | ext4 (256M) |
| Bootloader | Syslinux (MBR / BIOS) |
| Output | single bootable `.img` for VMware/VirtualBox |

## Build locally (optional)

Only needed if you want to build on a Linux machine instead of GitHub:

```bash
git clone https://gitlab.com/buildroot.org/buildroot.git
cd buildroot
make BR2_EXTERNAL=/path/to/mylinux O=build mylinux_x86_64_defconfig
make BR2_EXTERNAL=/path/to/mylinux O=build -j"$(nproc)"
genimage -c /path/to/mylinux/board/mylinux/genimage.cfg
```

## Test in VMware

1. Create a new VM: Linux / Other Linux 64-bit
2. CPU: 2–4 cores, RAM: 2–4 GB, Disk: 20 GB
3. Use the generated `myserveros.img` as a virtual disk
4. Boot → login as `root`
5. From Windows: `ssh root@<vm-ip>` → `MyServerOS #`

## Roadmap

- v0.1: x86_64 + kernel + BusyBox + ext4 + Syslinux + DHCP + dropbear
- v0.2: systemd
- v0.3: hardened dropbear / OpenSSH
- v0.4: custom services
- v0.5: add ARM64 build
- v0.6: automated CI smoke test (boot VM, check SSH)
