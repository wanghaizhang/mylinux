#!/bin/sh

TARGET_DIR="${1}"

echo "Configuring MyLinux..."

# Ensure root home exists
mkdir -p "${TARGET_DIR}/root"

# Ensure hostname
echo "mylinux" > "${TARGET_DIR}/etc/hostname"

# Permissions
chmod 755 "${TARGET_DIR}/root"

exit 0