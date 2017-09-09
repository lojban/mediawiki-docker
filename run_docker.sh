#!/bin/bash

test=""
# Test mode
if [ "$1" = "-t" ]
then
	test="_test"
fi

port=11080
if [ "$test" ]
then
	port=11081
fi

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
# our sub-version number
ITERATION=1

sudo docker build --build-arg=MW_VERSION=$MW_VERSION --build-arg=MW_USERID=$(id -u) --build-arg=MW_GROUPID=$(id -g) --build-arg=UNUSED_USERID=$UNUSED_USERID --build-arg=UNUSED_GROUPID=$UNUSED_GROUPID -t lojban/mediawiki:$MW_VERSION-$ITERATION .
sudo docker kill lojban_mediawiki${test}
sudo docker rm lojban_mediawiki${test}
sudo docker rm /lojban_mediawiki${test}

./fix_selinux.sh
rm /srv/lojban/mediawiki-docker/data/LocalSettings.php
./insert_password.sh mysql
./insert_password.sh wgsecret
if [ "$test" ]
then
	./test_mode.sh
fi

echo
echo "Listening on port $port"
echo

sudo docker run --name lojban_mediawiki${test} -p $port:80 -v /srv/lojban/mediawiki-docker/data/LocalSettings.php:/var/www/mediawiki/LocalSettings.php -v /srv/lojban/mediawiki-docker/data/images:/var/www/mediawiki/images -v /srv/lojban/mediawiki-docker/data/files:/var/www/mediawiki/files  -d lojban/mediawiki:$MW_VERSION-$ITERATION
sudo docker exec -it lojban_mediawiki${test} /script/update.sh
