# VLC 4 x86\_64 Flatpak

Run the complete reproducible build from this checkout:

```Shell
./build-vlc4-flatpak.sh
```

The script uses rootless Podman only. It builds the explicit
`localhost/vlc-flatpak-builder:fedora44` image from `Containerfile`, installs
the KDE 6.11 SDK/runtime into the checkout-local `.flatpak-home/`, and writes:

```text
dist/org.videolan.VLC4-x86_64.flatpak
```

The manifest is intentionally split into a cached `vlc-contrib` module and a
VLC module. The former runs the upstream VLC contrib bootstrap and makefiles;
it downloads, verifies and builds the dependency versions selected by the
fixed VLC commit. Downloaded contrib tarballs are retained in
`.cache/vlc-contrib-tarballs/`, so a clean Flatpak Builder retry does not fetch
them again.

The source is pinned to VLC commit `c52356f14ee57e3002066ef8834591d1cbfd479d`.
It identifies itself as `4.0.0-dev`, because VLC 4 has not been released as a
stable tarball. `libplacebo` is disabled: the KDE SDK's partial static glslang
link metadata cannot satisfy VLC's optional libplacebo Vulkan plugin without
hand-maintained linker-library lists. Core VLC 4, the Qt UI, upstream contrib
FFmpeg and the normal OpenGL/VAAPI paths remain enabled.

Two narrowly-scoped Qt compatibility patches are applied to that pinned
snapshot: one fixes Qt 6.11 `moc` include-directory generation, and the other
avoids a VLC RHI/OpenGL startup probe issuing a blocking Qt invocation to its
own GUI thread. The latter otherwise makes the Qt interface deadlock on
Linux/Wayland and VLC reports `no suitable interface module`.

`NO-MLKEM.pmod` is installed only in the build image as
`DEFAULT:NO-MLKEM`. It works around the observed TLS EOF failure while fetching
upstream sources; it does not change the host crypto policy or the finished
Flatpak runtime.

At the end of every build, the script verifies the exported OSTree ref,
installs the bundle in the checkout-local Flatpak installation, runs
`vlc.bin --version`, and prints the bundle SHA-256.

To replace a system-installed `master` build on the host, install the newly
generated bundle with:

```Shell
flatpak install --system --reinstall dist/org.videolan.VLC4-x86_64.flatpak
flatpak run --system org.videolan.VLC//master
```

