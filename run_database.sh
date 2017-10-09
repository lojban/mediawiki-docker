#!/bin/bash

exec 2>&1
set -e
set -x

./kill_database.sh "$@"

test=""
# Test mode
if [ "$1" = "-t" ]
then
	test="_test"
fi

if [ "$test" ]
then
	echo "Copying db data to test folders."
	rsync -aHAX --delete /srv/lojban/mediawiki-docker/data/db/ /srv/lojban/mediawiki-docker/data/db$test/
fi

db_port=11336
if [ "$test" ]
then
	db_port=11337
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
# Build database
#************
echo
echo "Building db docker."
echo

DB_VERSION=10.2
rm data/Dockerfile.db
./insert_password.sh mysql Dockerfile.db
sudo docker build -t lojban/mediawiki_db:$DB_VERSION-$ITERATION \
	--build-arg=DB_USERID=$(id -u) --build-arg=DB_GROUPID=$(id -g) \
	-f data/Dockerfile.db \
	--build-arg DB_VERSION=$DB_VERSION .

echo
echo "Running db docker, which will listen on db_port $db_port"
echo

sudo docker run --name lojban_mediawiki_db${test} -p $db_port:3306 \
	-v /srv/lojban/mediawiki-docker/data/db${test}:/var/lib/mysql \
	-i $hasterm lojban/mediawiki_db:$DB_VERSION-$ITERATION
