#! /bin/bash

set -e

repo=${IMAGE_NAME:-nuno351/gentooino}

GCC=${1:-~9.5.0}
GCC_latest_major=11
ARDUINO=${2:-1.8.5}
DATE=$(date -u +%Y%m%d)
DATE=${3:-$DATE}

VERSION="$(git remote get-url origin && git describe --tags --always)" || VERSION=dev

def_MAKEOPTS="-j$(nproc --ignore=2)"
MAKEOPTS=${MAKEOPTS:-$def_MAKEOPTS}
echo "using MAKEOPTS=$MAKEOPTS"

tag="gcc-${GCC//[*~]/}-arduino-${ARDUINO}"
tag_date="$tag-$DATE"

echo building tag $tag

DOCKER_BUILDKIT=1 docker build \
	--file Dockerfile \
	--build-arg VERSION="${VERSION}" \
	--build-arg GCC="${GCC}" \
	--build-arg ARDUINO="${ARDUINO}" \
	--build-arg DATE="${DATE}" \
	--build-arg MAKEOPTS="${MAKEOPTS}" \
	--progress plain \
	--tag $repo:$tag_date .

echo
set -x
docker images $repo:$tag_date

docker tag $repo:$tag_date $repo:$tag
set +x
if [[ $GCC = *"${GCC_latest_major}."* ]]; then
	set -x
	docker tag $repo:$tag_date $repo
	set +x
fi
echo
echo "Done after $((SECONDS/60)) min $((SECONDS%60)) sec"

echo "To publish, run:"
echo
echo " docker push $repo:$tag_date"
echo
