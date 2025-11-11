#!/usr/bin/env bash

# Pre-export preparation script for Ubuntu VM cloning.
# Run this before powering down and exporting the VM to produce a clean template.

set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

echo "[1/7] Cleaning cached package data..."
apt-get clean

echo "[2/7] Removing DHCP client leases..."
rm -f /var/lib/dhcp/* /var/lib/dhcp3/*

echo "[3/7] Resetting machine-id..."
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

echo "[4/7] Removing SSH host keys (they will rebuild on next boot)..."
rm -f /etc/ssh/ssh_host_*

if command -v cloud-init >/dev/null 2>&1; then
  echo "[5/7] Cleaning cloud-init state..."
  cloud-init clean --logs || cloud-init clean || true
else
  echo "[5/7] Skipping cloud-init cleanup (not installed)."
fi

echo "[6/7] Clearing shell history for root..."
history -c || true
cat /dev/null > /root/.bash_history || true

echo "[7/7] Syncing disks..."
sync

echo "Pre-export cleanup complete. Power off the VM and export the image."

