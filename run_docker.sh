#!/bin/bash

test=""
# Test mode
if [ "$1" = "-t" ]
then
	test="_test"
fi

if [ "$test" ]
then
	echo "Copying data to test folders."
	rsync -aHAX --delete /srv/lojban/mediawiki-docker/data/db/ /srv/lojban/mediawiki-docker/data/db$test/
	rsync -aHAX --delete /srv/lojban/mediawiki-docker/data/files/ /srv/lojban/mediawiki-docker/data/files$test/
	rsync -aHAX --delete /srv/lojban/mediawiki-docker/data/images/ /srv/lojban/mediawiki-docker/data/images$test/
fi

web_port=11080
if [ "$test" ]
then
	web_port=11081
fi
db_port=11336
if [ "$test" ]
then
	db_port=11337
fi

# our sub-version number; used to force rebuilds
ITERATION=1

#************
# Build database
#************
DB_VERSION=10.2
rm data/Dockerfile.db
./insert_password.sh mysql Dockerfile.db
sudo docker build -t lojban/mediawiki_db:$DB_VERSION-$ITERATION \
	--build-arg=DB_USERID=$(id -u) --build-arg=DB_GROUPID=$(id -g) \
	-f data/Dockerfile.db \
	--build-arg DB_VERSION=$DB_VERSION .
sudo docker kill lojban_mediawiki_db${test}
sudo docker rm lojban_mediawiki_db${test}
sudo docker rm /lojban_mediawiki_db${test}

echo
echo "Listening on db_port $db_port"
echo

sudo docker run --name lojban_mediawiki_db${test} -p $db_port:3306 \
	-v /srv/lojban/mediawiki-docker/data/db${test}:/var/lib/mysql \
	-d lojban/mediawiki_db:$DB_VERSION-$ITERATION

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

sudo docker build --build-arg=MW_VERSION=$MW_VERSION \
	--build-arg=MW_USERID=$(id -u) --build-arg=MW_GROUPID=$(id -g) \
	--build-arg=UNUSED_USERID=$UNUSED_USERID \
	--build-arg=UNUSED_GROUPID=$UNUSED_GROUPID \
	-t lojban/mediawiki_web:$MW_VERSION-$ITERATION \
	-f Dockerfile.web .
sudo docker kill lojban_mediawiki_web${test}
sudo docker rm lojban_mediawiki_web${test}
sudo docker rm /lojban_mediawiki_web${test}

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
echo "Listening on web_port $web_port"
echo

sudo docker run --name lojban_mediawiki_web${test} -p $web_port:80 \
	-v /srv/lojban/mediawiki-docker/data/LocalSettings$test.php:/var/www/mediawiki/LocalSettings.php \
	-v /srv/lojban/mediawiki-docker/data/images$test:/var/www/mediawiki/images \
	-v /srv/lojban/mediawiki-docker/data/files$test:/var/www/mediawiki/files  \
	--link lojban_mediawiki_db$test:mysql \
	-d lojban/mediawiki_web:$MW_VERSION-$ITERATION
sudo docker exec -it lojban_mediawiki_web${test} /script/update.sh
