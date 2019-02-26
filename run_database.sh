#!/bin/bash

exec 2>&1
set -e
set -x

CONTAINER_BIN=${CONTAINER_BIN:-$(which podman)}
CONTAINER_BIN=${CONTAINER_BIN:-$(which docker)}

./kill_database.sh "$@"

test=""
general_log=""
# Test mode
if [ "$1" = "-t" ]
then
	test="_test"
	general_log="--general-log"
fi

if [ "$test" ]
then
	echo "Copying db data to test folders."
	rsync -aHAX --delete /srv/lojban/mediawiki-container/data/db/ /srv/lojban/mediawiki-container/data/db$test/
fi

db_port=11336
if [ "$test" ]
then
	db_port=11337
fi

# This has nothing to do with this container, but the other container shares
# our networking stack, so...
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
# Build database
#************
echo
echo "Building db container."
echo

DB_VERSION=10.4
rm -f data/Dockerfile.db
erb db_version=$DB_VERSION \
    db_userid=$(id -u) db_groupid=$(id -g) \
    Dockerfile.db.erb >data/Dockerfile.db
chmod --reference=Dockerfile.db.erb data/Dockerfile.db

sudo $CONTAINER_BIN build -t lojban/mediawiki_db:$DB_VERSION-$ITERATION -f data/Dockerfile.db .

echo
echo "Running db container, which will listen on db_port $db_port ; the associated web container will listen on $web_port."
echo

sudo $CONTAINER_BIN run --name lojban_mediawiki_db${test} \
	-p $web_port:8080 \
	-v /srv/lojban/mediawiki-container/data/db${test}:/var/lib/mysql \
	-v /srv/lojban/mediawiki-container/data/backups${test}:/srv/backups \
	-i $hasterm lojban/mediawiki_db:$DB_VERSION-$ITERATION $general_log
