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

$CONTAINER_BIN build -t lojban/mediawiki_db:$DB_VERSION-$ITERATION -f data/Dockerfile.db .

$CONTAINER_BIN pod rm -f lojban_mediawiki || true
$CONTAINER_BIN pod create --share=net,uts,ipc -n lojban_mediawiki -p $web_port:8080

echo
echo "Running db container; the associated web container will listen on $web_port."
echo

$CONTAINER_BIN run --pod lojban_mediawiki --user $(id -u):$(id -g) --name lojban_mediawiki_db${test} \
	-v /srv/lojban/mediawiki-container/data/db${test}:/var/lib/mysql \
	-v /srv/lojban/mediawiki-container/data/backups${test}:/srv/backups \
	-i $hasterm lojban/mediawiki_db:$DB_VERSION-$ITERATION $general_log
