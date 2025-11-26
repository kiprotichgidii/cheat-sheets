#!/bin/bash
set -euo pipefail

# ============================================================
#  Build Podman (manual build) on Amazon Linux 2023
#  Tested on t2.xlarge / AL2023
# ============================================================

# Change these versions as needed
PODMAN_VERSION="v5.7"
CONMON_VERSION="main"
CRUN_VERSION="main"
LIBSLIRP_VERSION="stable-4.2"
SLIRP4NETNS_VERSION="release/0.4"
FEDORA_VERSION="41"
CONTAINERS_COMMON_VERSION="0.64.2-1.fc41"
AMZN_CONMON_VERSION="${CONTAINERS_COMMON_VERSION%%.fc*}"
PROTOC_VERSION="30.2"

# ============================================================
#  Directory Setup
# ============================================================
TOPDIR="${HOME}/work"
mkdir -p "$TOPDIR"

echo "=> Build directory: $TOPDIR"

# Ensure /usr/local/bin is in PATH (Podman installs here)
export PATH="/usr/local/bin:${PATH}"

# ============================================================
#  Install Build Dependencies
# ============================================================
echo "=> Installing prerequisite packages ..."
sudo dnf install -y \
  git golang autoconf automake libtool meson ninja-build \
  libseccomp-devel gpgme-devel libcap-devel systemd-devel \
  yajl yajl-devel cni-plugins iptables-nft rpm-build \
  golang-github-cpuguy83-md2man.x86_64 \
  pkgconf-pkg-config gcc make

# ============================================================
#  Build Podman
# ============================================================
echo "=> Clonning Podman Github Repository..."
cd "$TOPDIR"
if [ ! -d podman ]; then
  git clone https://github.com/containers/podman
fi

echo "=> Building podman ($PODMAN_VERSION)..."
cd podman
git fetch --all --tags
git switch "$PODMAN_VERSION"

make
sudo make install

# ============================================================
#  Build conmon (Podman container monitor)
# ============================================================
echo "=> Clonning Podman Container Monitor Repo..."
cd "$TOPDIR"
if [ ! -d conmon ]; then
  git clone https://github.com/containers/conmon
fi

echo "=> Building conmon ($CONMON_VERSION)..."
cd conmon
git fetch
git checkout "$CONMON_VERSION"

make -j"$(nproc)"
sudo make install

# ============================================================
#  Build crun (OCI runtime)
# ============================================================
echo "=> Clonning OCI Runtime Repo..."
cd "$TOPDIR"
if [ ! -d crun ]; then
  git clone https://github.com/containers/crun
fi

echo "=> Building crun ($CRUN_VERSION)..."
cd crun
git fetch
git checkout "$CRUN_VERSION"

./autogen.sh
./configure --prefix=/usr/local
make -j"$(nproc)"
sudo make install

# ============================================================
#  Build libslirp (networking backend)
# ============================================================
echo "=> Clonning libslirp Repo..."
cd "$TOPDIR"
if [ ! -d libslirp ]; then
  git clone https://gitlab.freedesktop.org/slirp/libslirp.git
fi

echo "=> Building libslirp ($LIBSLIRP_VERSION)..."
cd libslirp
git fetch --all --tags
git switch "$LIBSLIRP_VERSION"

meson build
ninja -C build
sudo ninja -C build install

# ============================================================
#  Build slirp4netns (rootless networking)
# ============================================================
echo "=> Clonning slirp4netns Repo..."
cd "$TOPDIR"
if [ ! -d slirp4netns ]; then
  git clone https://github.com/rootless-containers/slirp4netns.git
fi

echo "=> Building slirp4netns ($SLIRP4NETNS_VERSION)..."
cd slirp4netns
git fetch
git checkout "$SLIRP4NETNS_VERSION"

./autogen.sh
./configure --prefix=/usr/local
make -j"$(nproc)"
sudo make install

# ============================================================
# Build netavark (for Podman 4.8+/5.x)
# ============================================================
echo "=> Building netavark..."
# Download Protoc zip file
PB_REL="https://github.com/protocolbuffers/protobuf/releases"
curl -LO $PB_REL/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
# Unzip the folder to a directory in your $PATH
unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local

cd ${TOPDIR}
if [ ! -d netavark ]; then
  git clone https://github.com/containers/netavark.git
fi

cd netavark

# Checkout a stable version (optionally)
# git checkout v1.7.0

# Netavark is written in Rust → install Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Build netavark
make build

# Install binary
sudo install -D -m755 bin/netavark /usr/local/bin/netavark

# ============================================================
# Build Aardvark-DNS (needed by netavark)
# ============================================================
echo "=> Building aardvark-dns..."
cd ${TOPDIR}
if [ ! -d aardvark-dns ]; then
  git clone https://github.com/containers/aardvark-dns.git
fi

cd aardvark-dns

# Optional: checkout a known stable release
# git checkout v1.7.0
make
sudo install -D -m755 target/release/aardvark-dns /usr/local/bin/aardvark-dns

# ============================================================
#  Build containers-common (configs + storage setup)
# ============================================================
DOWNLOADS="${TOPDIR}/Downloads"
mkdir -p "$DOWNLOADS"
cd "$DOWNLOADS"

SRC_RPM="containers-common-${CONTAINERS_COMMON_VERSION}.src.rpm"

if [ ! -f "$SRC_RPM" ]; then
  echo "=> Downloading containers-common source package ..."
  curl -LO "https://download.fedoraproject.org/pub/fedora/linux/updates/41/Everything/source/tree/Packages/c/${SRC_RPM}"
fi

echo "=> Installing and building containers-common ..."
rpm -ivh "$SRC_RPM"

cd "${HOME}/rpmbuild"
rpmbuild -bb SPECS/containers-common.spec

sudo dnf install -y "RPMS/noarch/containers-common-${AMZN_CONMON_VERSION}.amzn2023.noarch.rpm"

# ============================================================
#  Test Podman
# ============================================================
echo "=> Testing Podman ..."
podman --version
podman info

echo "=> Running hello-world ..."
podman run --rm hello-world

echo "=> Podman built and installed successfully! 🎉"
