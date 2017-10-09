#!/bin/bash

exec 2>&1
set -e
set -x

./kill_web.sh "$@"

test=""
# Test mode
if [ "$1" = "-t" ]
then
	test="_test"
fi

if [ "$test" ]
then
	echo "Copying web data to test folders."
	rsync -aHAX --delete /srv/lojban/mediawiki-docker/data/files/ /srv/lojban/mediawiki-docker/data/files$test/
	rsync -aHAX --delete /srv/lojban/mediawiki-docker/data/images/ /srv/lojban/mediawiki-docker/data/images$test/
fi

web_port=11080
if [ "$test" ]
then
	web_port=11081
fi

# our sub-version number; used to force rebuilds
ITERATION=1

# Ask for a tty if that makes sense
hasterm=''
if tty -s
then
	hasterm='-t'
fi

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

echo
echo "Setting up config files and the like."
echo

./fix_selinux.sh
rm data/LocalSettings$test.php
cp LocalSettings.php.in data/LocalSettings$test.php
./insert_password.sh mysql LocalSettings$test.php
./insert_password.sh wgsecret LocalSettings$test.php
sed -i "s/--TEST--/$test/g" data/LocalSettings$test.php
if [ "$test" ]
then
	sed -i 's;mw.lojban.org;test-mw.lojban.org;' data/LocalSettings$test.php
	sed -i 's;https://test-mw.lojban.org;http://test-mw.lojban.org;' data/LocalSettings$test.php
fi

echo
echo "Launching website docker, which will listen on web_port $web_port"
echo

sudo docker run --name lojban_mediawiki_web${test} -p $web_port:80 \
	--log-driver syslog --log-opt tag=lojban_mw_web \
	-v /srv/lojban/mediawiki-docker/data/LocalSettings$test.php:/var/www/mediawiki/LocalSettings.php \
	-v /srv/lojban/mediawiki-docker/data/images$test:/var/www/mediawiki/images \
	-v /srv/lojban/mediawiki-docker/data/files$test:/var/www/mediawiki/files  \
	--link lojban_mediawiki_db$test:mysql \
	-i $hasterm lojban/mediawiki_web:$MW_VERSION-$ITERATION
