#!/usr/bin/env bash
set -e

# Idempotent devcontainer setup script for build tools and Qt6 dev packages.
# It will install cmake, ninja, pkg-config, git, curl, and Qt6 dev packages.

MARKER="/tmp/.devcontainer_qt_setup_done"

if [ -f "$MARKER" ]; then
  echo "Devcontainer setup already completed; skipping apt installs."
  exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "This script should be run as root. Re-run with sudo or from the devcontainer postCreateCommand."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "Updating package lists..."
apt-get update -y

echo "Installing build tools and Qt6 dev packages..."
apt-get install -y --no-install-recommends \
    cmake \
    ninja-build \
    pkg-config \
    git \
    curl \
    ca-certificates \
    gnupg

# Install Qt6 development packages. These names work for Ubuntu apt repositories that include Qt 6.
apt-get install -y --no-install-recommends \
    qt6-base-dev \
    qt6-base-dev-tools \
    libqt6core6 \
    libqt6network6 || true

# Mark as done to make the script idempotent
touch "$MARKER"

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Devcontainer setup completed."
