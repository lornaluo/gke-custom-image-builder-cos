#!/bin/bash
set -ex

echo "Copying driver files from /var/lib/nvidia to /home/kubernetes/bin/nvidia..."

# Ensure the target directory exists
sudo mkdir -p /home/kubernetes/bin/nvidia

# Copy all contents, including hidden files, preserving attributes.
if [ -d "/var/lib/nvidia" ]; then
  sudo cp -a /var/lib/nvidia/. /home/kubernetes/bin/nvidia/
  echo "Driver files copied to /home/kubernetes/bin/nvidia."
else
  echo "Error: /var/lib/nvidia source directory not found."
  exit 1
fi

# Optional: Clean up the temporary workspace
echo "Cleaning up /var/lib/nvidia..."
sudo rm -rf /var/lib/nvidia
echo "Temporary workspace cleaned."

# ---- NEW: Install systemd service for fast boot ----
echo "Creating gpu-driver-loader.service in /usr/lib/systemd/system..."

# Try to make /usr writable for this script if it isn t already
sudo mount -o remount,rw /usr || echo "Failed to remount /usr as rw, proceeding anyway..."

sudo mkdir -p /usr/lib/systemd/system
cat <<SERVICE_EOF | sudo tee /usr/lib/systemd/system/gpu-driver-loader.service
[Unit]
Description=Pre-load GPU Drivers Early
DefaultDependencies=no
After=local-fs.target
Before=kube-node-configuration.service kubelet.service

[Service]
Type=oneshot
RemainAfterExit=yes
# Load the driver using cos-extensions
ExecStart=/usr/bin/cos-extensions install gpu -- --version 580.126.09 --host-dir=/home/kubernetes/bin/nvidia

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo "Enabling gpu-driver-loader.service via direct symlink..."
sudo mkdir -p /usr/lib/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/gpu-driver-loader.service /usr/lib/systemd/system/multi-user.target.wants/gpu-driver-loader.service

# Also try enabling it via etc just in case there is some magic overlay
sudo mkdir -p /etc/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/gpu-driver-loader.service /etc/systemd/system/multi-user.target.wants/gpu-driver-loader.service

# ----------------------------------------------------

echo "copy_driver.sh execution complete."
