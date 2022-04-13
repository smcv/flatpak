#!/bin/sh
set -eu

TMP=$(mktemp -d selinux-build-XXXXXX)
output="$1"
shift
cp -- "$@" "$TMP/"

make -C "$TMP" -f /usr/share/selinux/devel/Makefile flatpak.pp
bzip2 -9 "$TMP/flatpak.pp"
cp "$TMP/flatpak.pp.bz2" "$output"
rm -fr "$TMP"
