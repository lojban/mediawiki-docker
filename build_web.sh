#!/bin/bash

exec 2>&1
set -e
set -x

CONTAINER_BIN=${CONTAINER_BIN:-$(which podman)}
CONTAINER_BIN=${CONTAINER_BIN:-$(which docker)}

test=""
# Test mode
if [ "$1" = "-t" ]
then
	test="_test"
fi

# our sub-version number; used to force rebuilds
ITERATION=1

#************
# Build website
#************

# Check for a non-privleged user
UNUSED_USERID=998
if id $UNUSED_USERID >/dev/null 2>&1
then
	echo "userid $UNUSED_USERID is in use, but we need one that is not."
	exit 1
fi
UNUSED_GROUPID=998
if id -g $UNUSED_GROUPID >/dev/null 2>&1
then
	echo "userid $UNUSED_GROUPID is in use, but we need one that is not."
	exit 1
fi

# mediawiki version
MW_VERSION=1.30

echo
echo "Building website container."
echo

rm -f data/Dockerfile.web
erb mw_version=$MW_VERSION \
    mw_userid=$(id -u) mw_groupid=$(id -g) \
    unused_userid=$UNUSED_USERID unused_groupid=$UNUSED_GROUPID \
    Dockerfile.web.erb >data/Dockerfile.web
chmod --reference=Dockerfile.web.erb data/Dockerfile.web

$CONTAINER_BIN build -t lojban/mediawiki_web:$MW_VERSION-$ITERATION -f data/Dockerfile.web .
