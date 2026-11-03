#!/usr/bin/env bash
# Röktest av en byggd .deb på samma sätt som duly-noted/deploy/Dockerfile använder den:
# Ubuntu 24.04, samma runtime-bibliotek, dpkg-deb -x (postinst kraschar i container), sedan
# `Audiveris -version`. Argument: sökväg till .deb (standard: nyaste i dn/build/).
set -euo pipefail
cd "$(dirname "$0")/.."
DEB=${1:-$(ls -t dn/build/Audiveris-*.deb | head -1)}
echo "== röktest $DEB"
docker run --rm -v "$PWD/$DEB":/pkg/audiveris.deb:ro ubuntu:24.04 bash -c '
  set -e
  apt-get update -qq >/dev/null
  apt-get install -y -qq --no-install-recommends \
    libfreetype6 fontconfig fonts-dejavu-core libxi6 libxrender1 libxtst6 libxext6 libgl1 libglib2.0-0 \
    libasound2t64 libbsd0 libmd0 libx11-6 libxau6 libxcb1 libxdmcp6 zlib1g libgtk-3-0t64 >/dev/null
  dpkg-deb -x /pkg/audiveris.deb /
  ls /opt/audiveris/bin
  /opt/audiveris/bin/Audiveris -version 2>&1 | tail -3
'
