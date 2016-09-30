#!/bin/bash

set -euo pipefail
set -x

NULL=
: "${ci_docker:=}"
: "${ci_parallel:=1}"
: "${ci_sudo:=}"
: "${ci_test:=yes}"
: "${ci_test_fatal:=yes}"

if [ -n "$ci_docker" ]; then
    exec docker run \
        --env=ci_docker="" \
        --env=ci_in_docker="yes" \
        --env=ci_parallel="${ci_parallel}" \
        --env=ci_sudo=yes \
        --env=ci_test="${ci_test}" \
        --env=ci_test_fatal="${ci_test_fatal}" \
        --privileged \
        flatpak-ci \
        tests/ci-build.sh \
        ${NULL}
fi

make="make -j${ci_parallel} V=1 VERBOSE=1"

mkdir deps

if ! pkg-config --exists "ostree-1 >= 2016.10" && [ "$ci_sudo" = yes ]; then
    git clone -b v2016.10 https://github.com/ostreedev/ostree deps/ostree
    ( cd deps/ostree && git submodule update --init --recursive )
    ( cd deps/ostree && ./autogen.sh --prefix="/usr" )
    $make -C deps/ostree
    sudo $make -C deps/ostree install
fi

NOCONFIGURE=1 ./autogen.sh

srcdir="$(pwd)"
mkdir ci-build
cd ci-build

../configure \
    --enable-always-build-tests \
    --enable-installed-tests \
    "$@"

${make}

maybe_fail_tests () {
    if [ "$ci_test_fatal" = yes ]; then
        exit 1
    fi
}

[ "$ci_test" != yes ] || ${make} check || maybe_fail_tests
[ "$ci_test" != yes ] || ${make} distcheck || maybe_fail_tests

${make} install DESTDIR=$(pwd)/DESTDIR

( cd DESTDIR && find . )

if [ "$ci_test" = yes ] && [ "$ci_sudo" = yes ]; then
    $sudo ${make} install

    export GI_TYPELIB_PATH=/usr/local/lib/girepository-1.0
    export LD_LIBRARY_PATH=/usr/local/lib

    ${make} installcheck || maybe_fail_tests
    gnome-desktop-testing-runner -d "/usr/local/share" Flatpak/ || maybe_fail_tests
fi

# vim:set sw=4 sts=4 et:
