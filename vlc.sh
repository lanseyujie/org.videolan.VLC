#!/usr/bin/env bash
shopt -s nullglob

for f in /app/share/vlc/extra/*/*.sh; do
  source $f
done

exec /app/bin/vlc.bin $VLC_ARGS "$@"
