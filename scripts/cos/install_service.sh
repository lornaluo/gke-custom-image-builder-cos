#!/bin/bash
set -o errexit
set -o pipefail
set -x

echo "--- Mounting rootfs as read-write ---"
sudo mount -o rw,remount /

echo "--- Copying systemd service file ---"
# cos-customizer runs scripts from the root of the build context if not specified otherwise, 
# but usually it replicates the directory structure. 
# Based on the cloudbuild.yaml, the scripts are in scripts/cos/
sudo cp scripts/cos/gpu-driver-loader.service /usr/lib/systemd/system/

echo "--- Enabling the service ---"
# Create the symlink manually to ensure it persists in the image
sudo mkdir -p /usr/lib/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/gpu-driver-loader.service /usr/lib/systemd/system/multi-user.target.wants/gpu-driver-loader.service

echo "--- Remounting rootfs as read-only ---"
sudo mount -o ro,remount /

echo "--- Customization Complete ---"
