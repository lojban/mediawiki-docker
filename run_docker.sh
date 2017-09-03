#!/bin/bash

# mediawiki version
MW_VERSION=1.29
# our sub-version number
ITERATION=1

sudo docker build --build-arg=MW_VERSION=$MW_VERSION -t lojban/mediawiki:$MW_VERSION-$ITERATION .
sudo docker kill lojban_mediawiki
sudo docker rm lojban_mediawiki

rm /srv/lojban/mediawiki-docker/data/LocalSettings.php
insert_password.sh mysql

sudo docker run --name test-mw -p 11080:80 -p 11443:443 -p 11900:9000 -v /srv/lojban/mediawiki-docker/data/LocalSettings.php:/var/www/mediawiki/LocalSettings.php -it lojban/mediawiki:$MW_VERSION-$ITERATION /bin/bash
