#!/usr/bin/env bash
# Smoke test of a built .deb in a clean Ubuntu 24.04 container: runtime libraries, dpkg-deb -x
# (the postinst needs a desktop), then `Audiveris -version`. Argument: path to the .deb (default: newest in dn/build/).
set -euo pipefail
cd "$(dirname "$0")/.."
DEB=${1:-$(ls -t dn/build/Audiveris-*.deb | head -1)}
echo "== smoke test $DEB"
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
