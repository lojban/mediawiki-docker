#!/bin/bash

exec 2>&1
set -e
set -x

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
UNUSED_USERID=999
if id $UNUSED_USERID >/dev/null 2>&1
then
	echo "userid $UNUSED_USERID is in use, but we need one that is not."
	exit 1
fi
UNUSED_GROUPID=999
if id -g $UNUSED_GROUPID >/dev/null 2>&1
then
	echo "userid $UNUSED_GROUPID is in use, but we need one that is not."
	exit 1
fi

# mediawiki version
MW_VERSION=1.29

echo
echo "Building website docker."
echo

sudo docker build --build-arg=MW_VERSION=$MW_VERSION \
	--build-arg=MW_USERID=$(id -u) --build-arg=MW_GROUPID=$(id -g) \
	--build-arg=UNUSED_USERID=$UNUSED_USERID \
	--build-arg=UNUSED_GROUPID=$UNUSED_GROUPID \
	-t lojban/mediawiki_web:$MW_VERSION-$ITERATION \
	-f Dockerfile.web .
