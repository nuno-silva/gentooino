#! /bin/bash

set -e

repo=nuno351/gentooino

GCC=${1:-~7.5.0}
ARDUINO=${2:-1.8.3}
DATE=`date +%+4Y%m%d`
DATE=${3:-$DATE}

tag="gcc-${GCC/[~]/}-arduino-${ARDUINO}"
tag="$tag-$DATE"

echo building tag $tag

DOCKER_BUILDKIT=1 docker build \
	--file Dockerfile \
	--build-arg gcc="${GCC}" \
	--build-arg ARDUINO="${ARDUINO}" \
	--build-arg DATE="${DATE}" \
	--progress plain \
	--tag $repo:$tag .

docker images $repo:$tag

echo "Done after $((SECONDS/60)) min $((SECONDS%60)) sec"
