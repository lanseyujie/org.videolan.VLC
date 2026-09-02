#!/usr/bin/env bash
set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly IMAGE="localhost/vlc-flatpak-builder:fedora44"
readonly RUNTIME_VERSION="6.11"
readonly FLATPAK_HOME="${ROOT_DIR}/.flatpak-home"
readonly XDG_DATA_HOME_IN_CONTAINER="/workspace/.flatpak-home/.local/share"

mkdir -p \
  "${ROOT_DIR}/.cache/vlc-contrib-tarballs" \
  "${ROOT_DIR}/.flatpak-home" \
  "${ROOT_DIR}/dist"

podman build \
  --tag "${IMAGE}" \
  --file "${ROOT_DIR}/Containerfile" \
  "${ROOT_DIR}"

podman run --rm \
  --privileged \
  --userns=keep-id \
  --security-opt label=disable \
  --env HOME=/workspace/.flatpak-home \
  --env XDG_DATA_HOME="${XDG_DATA_HOME_IN_CONTAINER}" \
  --volume "${ROOT_DIR}:/workspace" \
  --workdir /workspace \
  "${IMAGE}" \
  bash -euxo pipefail -c '
    flatpak remote-add --user --if-not-exists \
      flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    flatpak install --user --noninteractive --or-update flathub \
      "org.kde.Platform//6.11" \
      "org.kde.Sdk//6.11"

    flatpak-builder \
      --user \
      --arch=x86_64 \
      --ccache \
      --disable-rofiles-fuse \
      --force-clean \
      --install-deps-from=flathub \
      --repo=repo \
      build-dir org.videolan.VLC.yaml

    flatpak build-bundle \
      --arch=x86_64 \
      repo dist/org.videolan.VLC4-x86_64.flatpak \
      org.videolan.VLC master

    ostree refs --repo=repo
    flatpak install --user --noninteractive --reinstall \
      dist/org.videolan.VLC4-x86_64.flatpak
    flatpak run --user --command=vlc.bin org.videolan.VLC --version
    sha256sum dist/org.videolan.VLC4-x86_64.flatpak
  '
