#!/bin/bash
ROOTDIR=$(pwd)
echo $ROOTDIR
if [ ! -e "$ROOTDIR/build" ]; then
    echo "Please run from root / no build dir"
    exit 1
fi

cd "$ROOTDIR/build"

cp -R openwrt-fresh-24.10 openwrt

# freeze revision to
# 24.10.0
REV_TAG="v24.10.0"
REV_HASH="$(git rev-parse ${REV_TAG})"
echo $REV_TAG
echo $REV_HASH

#REV_HASH="1fad1b4965dc6f4e5f4ba7b9605987f443a4c276"
cd openwrt
git reset --hard ${REV_HASH}
REV_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

echo "Current OpenWRT commit"
git log -1
git describe

# install feeds
# cd openwrt
# ./scripts/feeds update -a && ./scripts/feeds install -a

