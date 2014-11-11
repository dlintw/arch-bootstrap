#!/bin/sh
set -e -u -o pipefail

shared_dependencies() {
  local EXECUTABLE=$1
  for PACKAGE in $(ldd "$EXECUTABLE" | grep "=> /" | awk '{print $3}'); do
    LC_ALL=c pacman -Qo $PACKAGE
  done | awk '{print $5}'
}

pkgbuild_dependencies() {
  local PKGBUILD=$1
  local EXCLUDE=$2
  source "$PKGBUILD"
  for DEPEND in ${depends[@]}; do
    echo "$DEPEND" | sed "s/[>=<].*$//"
  done | grep -v "$EXCLUDE"
}
f=/var/abs/core/pacman/PKGBUILD
if [ ! -r $f ] ; then
  f=/var/abs/local/pacman/PKGBUILD
fi
if [ ! -r $f ] ; then
  echo "Err: missing pacman/PKGBUILD in /var/abs/core or /var/abs/local"
  exit 1
fi
# Main
{
  shared_dependencies "/usr/bin/pacman"
  pkgbuild_dependencies $f "bash"
} | sort -u | xargs
