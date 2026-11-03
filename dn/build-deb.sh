#!/usr/bin/env bash
# Bygger Audiveris-forken till en .deb i Docker (Ubuntu 24.04 + Temurin JDK 25), samma paketering
# som uppströms release-arbetsflöde (jlink + jpackage). Resultatet hamnar i dn/out/.
#
#   dn/build-deb.sh                  # bygger för värdens arkitektur (arm64 på Mac, amd64 på VM 103/one)
#   PLATFORM=linux/amd64 dn/build-deb.sh   # tvingad amd64 (emulerat på Apple Silicon – långsamt)
#
# Servern (one.com, VM 103) är x86_64: prod-paketet byggs där, Mac-bygget är bara kompileringskontroll.
set -euo pipefail
cd "$(dirname "$0")/.."
TAG=$(git describe --tags --always --dirty 2>/dev/null || echo unknown)   # t.ex. 5.11.0-3-gabc1234
SUFFIX=$(cat dn/VERSION)                                                   # t.ex. dn1
IMAGE=eclipse-temurin:25-jdk-noble
PLAT=${PLATFORM:-}
mkdir -p dn/out
echo "== bygger $TAG ($SUFFIX) i $IMAGE ${PLAT:+platform=$PLAT}"
docker run --rm ${PLAT:+--platform "$PLAT"} \
  -v "$PWD":/src -w /src \
  -v audiveris-dn-gradle:/root/.gradle \
  -e GRADLE_OPTS=-Dorg.gradle.daemon=false \
  "$IMAGE" bash -c '
    set -e
    apt-get update -qq && apt-get install -y -qq --no-install-recommends fakeroot binutils git >/dev/null
    git config --global --add safe.directory /src
    ./gradlew --no-daemon -q :packaging:jpackage -PinstallerType=DEB
    find packaging/build -name "*.deb" -exec cp {} dn/out/ \;
  '
ARCH=$(docker run --rm ${PLAT:+--platform "$PLAT"} "$IMAGE" dpkg --print-architecture)
for f in dn/out/Audiveris-*.deb; do
  case "$f" in *-"$SUFFIX"-*) continue;; esac
  mv "$f" "dn/out/Audiveris-5.11.0-$SUFFIX-${TAG}-ubuntu24.04-${ARCH}.deb"
done
ls -la dn/out/
