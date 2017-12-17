#!/bin/bash

# Copied mostly from https://gist.github.com/rumpelsepp/d646750910be19332753

# Check if pacaur is already installed
if type pacaur > /dev/null 2>&1; then
  echo "pacaur already installed"
  exit
fi

START=$(pwd)
BUILDROOT="$(mktemp -d)"

# Make sure we can even build packages on arch linux.
sudo pacman -S --needed --noconfirm base-devel git

mkdir -p "$BUILDROOT"
cd "$BUILDROOT" || exit 1

# Arch Linux ARM provides a cower package for the RPI!
# Let's either install 'cower' via pacman, or build it.
if [ "$(uname -n)" = 'alarmpi' ]; then
  pacman -S cower
else
  # Fetch Dave Reisner's key to be able to verify cower.
  gpg --keyserver hkp://pool.sks-keyservers.net \
      --recv-keys 487EACC08557AD082088DABA1EB2638FF56C0C53
  git clone "https://aur.archlinux.org/cower.git"
  cd "$BUILDROOT/cower" || exit 1
  makepkg --syncdeps --install --noconfirm
fi

cd $BUILDROOT || exit 1
git clone "https://aur.archlinux.org/pacaur.git"

cd "$BUILDROOT/pacaur" || exit 1
makepkg --syncdeps --install --noconfirm

cd "$START" || exit 1
rm -rf "$BUILDROOT"

if ! type pacaur > /dev/null 2>&1; then
  echo "pacaur installation failed"
  exit 1
fi
