#!/bin/bash

exec 2>&1
set -e
set -x

./kill_web.sh "$@"

./build_web.sh "$@"

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
# MUST change this both here and in build_web.sh
ITERATION=1

# mediawiki version
# MUST change this both here and in build_web.sh
MW_VERSION=1.30

# Ask for a tty if that makes sense
hasterm=''
if tty -s
then
	hasterm='-t'
fi

echo
echo "Setting up config files and the like."
echo

./fix_selinux.sh
rm -f data/LocalSettings$test.php
erb test=$test LocalSettings.php.erb >data/LocalSettings$test.php
chmod --reference=LocalSettings.php.erb data/LocalSettings$test.php
if [ "$test" ]
then
	sed -i 's;mw.lojban.org;test-mw.lojban.org;' data/LocalSettings$test.php
	sed -i 's;https://test-mw.lojban.org;http://test-mw.lojban.org;' data/LocalSettings$test.php
fi

echo
echo "Launching website docker, which will listen on web_port $web_port"
echo

sudo docker run --name lojban_mediawiki_web${test} -p $web_port:8080 \
	-v /srv/lojban/mediawiki-docker/data/LocalSettings$test.php:/var/www/mediawiki/LocalSettings.php \
	-v /srv/lojban/mediawiki-docker/data/images$test:/var/www/mediawiki/images \
	-v /srv/lojban/mediawiki-docker/data/files$test:/var/www/mediawiki/files  \
	--link lojban_mediawiki_db$test:mysql \
	-i $hasterm lojban/mediawiki_web:$MW_VERSION-$ITERATION
