#!/bin/bash

exec 2>&1
set -e
set -x

CONTAINER_BIN=${CONTAINER_BIN:-$(which podman)}
CONTAINER_BIN=${CONTAINER_BIN:-$(which docker)}

cd /home/sampre_mw/mediawiki
rm -f data/mysql_backup.sh
erb mysql_backup.sh.erb >data/mysql_backup.sh
chmod --reference=mysql_backup.sh.erb data/mysql_backup.sh
$CONTAINER_BIN cp data/mysql_backup.sh lojban_mediawiki_db:/tmp/
$CONTAINER_BIN exec -t lojban_mediawiki_db /tmp/mysql_backup.sh
