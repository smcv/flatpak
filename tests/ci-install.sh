#!/bin/bash

set -euo pipefail
set -x

NULL=
: "${ci_docker:=}"
: "${ci_in_docker:=}"
: "${ci_parallel:=1}"
: "${ci_suite:=jessie}"

if [ $(id -u) = 0 ]; then
    sudo=
else
    sudo=sudo
fi

if [ -n "$ci_docker" ]; then
    sed \
        -e "s/@ci_distro@/${ci_distro}/" \
        -e "s/@ci_docker@/${ci_docker}/" \
        -e "s/@ci_suite@/${ci_suite}/" \
        < tests/ci-Dockerfile.in > Dockerfile
    exec docker build -t flatpak-ci .
fi

case "$ci_distro" in
    (debian)
        # Docker images use httpredir.debian.org but it seems to be
        # unreliable; use a CDN instead
        sed -i -e 's/httpredir\.debian\.org/deb.debian.org/g' /etc/apt/sources.list
        ;;
esac

case "$ci_distro" in
    (debian|ubuntu)
        # TODO: fetch this list from the Debian packaging git repository?
        # This is the complete build-dependencies for ostree,
        # bubblewrap and flatpak itself, because we build the embedded
        # copy of bubblewrap and we might also build ostree
        # from source.
        $sudo apt-get -y update
        $sudo apt-get -y install \
            attr \
            bison \
            ca-certificates \
            cpio \
            dbus \
            desktop-file-utils \
            dh-autoreconf \
            e2fslibs-dev \
            elfutils \
            fuse \
            git \
            gnome-desktop-testing \
            gobject-introspection \
            gtk-doc-tools \
            hicolor-icon-theme \
            libarchive-dev \
            libattr1-dev \
            libcap-dev \
            libdw-dev \
            libelf-dev \
            libfuse-dev \
            libgirepository1.0-dev \
            libglib2.0-dev \
            libgpgme11-dev \
            libjson-glib-dev \
            liblzma-dev \
            libmount-dev \
            libpolkit-gobject-1-dev \
            libseccomp-dev \
            libselinux1-dev \
            libsoup2.4-dev \
            libxau-dev \
            libxml2-utils \
            pkg-config \
            procps \
            shared-mime-info \
            xmlto \
            xsltproc \
            zlib1g-dev \
            ${NULL}
        # Use system copy if available, but don't insist on it
        $sudo apt-get -y install \
            libostree-dev \
            ${NULL} || :
        # Older releases don't have gtk-update-icon-cache as a separate
        # package
        $sudo apt-get -y install gtk-update-icon-cache || \
            $sudo apt-get -y install libgtk-3-bin

        if [ -n "$ci_in_docker" ]; then
            # Add the user that we will use to do the build inside the
            # Docker container, and let them use sudo
            adduser --disabled-password --gecos User,,, user </dev/null
            chown -R user:user /home/user
            apt-get -y install sudo systemd-sysv
            echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nopasswd
            chmod 0440 /etc/sudoers.d/nopasswd
        fi
        ;;

    (*)
        echo "Don't know how to set up ${ci_distro}" >&2
        exit 1
        ;;
esac

# vim:set sw=4 sts=4 et:
