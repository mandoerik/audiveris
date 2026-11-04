#!/usr/bin/env bash
# Builds the fork as a .deb in Docker (Ubuntu 24.04 + Temurin JDK 25), with the same packaging as the
# upstream release workflow (jlink + jpackage). Output in dn/build/ (ignored by git).
#
#   dn/build-deb.sh                        # for the host architecture
#   PLATFORM=linux/amd64 dn/build-deb.sh   # forced amd64 (emulated on arm64 hosts – slow)
set -euo pipefail
cd "$(dirname "$0")/.."
TAG=$(git describe --tags --always --dirty 2>/dev/null || echo unknown)   # t.ex. 5.11.0-3-gabc1234
SUFFIX=$(cat dn/VERSION)                                                   # t.ex. dn1
IMAGE=eclipse-temurin:25-jdk-noble
PLAT=${PLATFORM:-}
mkdir -p dn/build
# Upstream's collectJars and customJre run only when packaging/build/jars resp. custom-jre are missing (onlyIf),
# so a second build in the same tree would pack the old jar and the old (possibly other-arch) runtime.
rm -rf packaging/build/jars packaging/build/dist packaging/build/custom-jre
echo "== building $TAG ($SUFFIX) in $IMAGE ${PLAT:+platform=$PLAT}"
docker run --rm ${PLAT:+--platform "$PLAT"} \
  -v "$PWD":/src -w /src \
  -v audiveris-dn-gradle:/root/.gradle \
  -e GRADLE_OPTS=-Dorg.gradle.daemon=false \
  "$IMAGE" bash -c '
    set -e
    apt-get update -qq && apt-get install -y -qq --no-install-recommends fakeroot binutils git lsb-release >/dev/null
    git config --global --add safe.directory /src
    ./gradlew --no-daemon -q :packaging:jpackage -PinstallerType=DEB
    find packaging/build -name "*.deb" -exec cp {} dn/build/ \;
  '
ARCH=$(docker run --rm ${PLAT:+--platform "$PLAT"} "$IMAGE" dpkg --print-architecture)
for f in dn/build/Audiveris-*.deb; do
  case "$f" in *-"$SUFFIX"-*) continue;; esac
  mv "$f" "dn/build/Audiveris-5.11.0-$SUFFIX-${TAG}-ubuntu24.04-${ARCH}.deb"
done
ls -la dn/build/
# check: the jar in the package is the one just built
cmp -s packaging/build/jars/audiveris.jar app/build/jar/audiveris.jar && echo "packaged jar = freshly built" || { echo "ERROR: packaged jar is not the one just built"; exit 1; }
