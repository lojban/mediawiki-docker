#!/bin/bash

exec 2>&1
set -x

CONTAINER_BIN=${CONTAINER_BIN:-$(which podman)}
CONTAINER_BIN=${CONTAINER_BIN:-$(which docker)}

test=""
# Test mode
if [ "$1" = "-t" ]
then
	test="-test"
fi

$CONTAINER_BIN stop --time=30 lojban_mediawiki_web${test}
$CONTAINER_BIN kill lojban_mediawiki_web${test}
$CONTAINER_BIN rm lojban_mediawiki_web${test}

exit 0
