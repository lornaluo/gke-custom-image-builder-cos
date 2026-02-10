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
echo "Creating gpu-driver-loader.service..."
# Note: Using version 580.126.09 as specified in cloudbuild.yaml
cat <<SERVICE_EOF | sudo tee /etc/systemd/system/gpu-driver-loader.service
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

echo "Enabling gpu-driver-loader.service..."
sudo systemctl enable gpu-driver-loader.service
# ----------------------------------------------------

echo "copy_driver.sh execution complete."
