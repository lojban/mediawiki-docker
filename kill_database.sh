#!/bin/bash

exec 2>&1
set -x

./kill_web.sh "$@"

CONTAINER_BIN=${CONTAINER_BIN:-$(which podman)}
CONTAINER_BIN=${CONTAINER_BIN:-$(which docker)}

test=""
# Test mode
if [ "$1" = "-t" ]
then
	test="_test"
fi

$CONTAINER_BIN stop --time=30 lojban_mediawiki_db${test}
$CONTAINER_BIN kill lojban_mediawiki_db${test}
$CONTAINER_BIN rm lojban_mediawiki_db${test}

exit 0
