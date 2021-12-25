#! /bin/bash

set -e

repo=${IMAGE_NAME:-nuno351/gentooino}

GCC=${1:-~8.5.0}
ARDUINO=${2:-1.8.3}
DATE=$(date -u +%Y%m%d)
DATE=${3:-$DATE}

def_MAKEOPTS="-j$(nproc --ignore=2)"
MAKEOPTS=${MAKEOPTS:-$def_MAKEOPTS}
echo "using MAKEOPTS=$MAKEOPTS"

tag="gcc-${GCC/[~]/}-arduino-${ARDUINO}"
tag="$tag-$DATE"

echo building tag $tag

DOCKER_BUILDKIT=1 docker build \
	--file Dockerfile \
	--build-arg GCC="${GCC}" \
	--build-arg ARDUINO="${ARDUINO}" \
	--build-arg DATE="${DATE}" \
	--build-arg MAKEOPTS="${MAKEOPTS}" \
	--progress plain \
	--tag $repo:$tag .

echo
docker images $repo:$tag

echo
echo "Done after $((SECONDS/60)) min $((SECONDS%60)) sec"

echo "To publish, run:"
echo
echo " docker push $repo:$tag"
echo
