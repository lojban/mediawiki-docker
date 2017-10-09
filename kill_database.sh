#!/bin/bash

exec 2>&1
set -x

test=""
# Test mode
if [ "$1" = "-t" ]
then
	test="_test"
fi

sudo docker stop --time=30 lojban_mediawiki_db${test}
sudo docker kill lojban_mediawiki_db${test}
sudo docker rm lojban_mediawiki_db${test}

exit 0
