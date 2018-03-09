#!/bin/bash

name="$1"
version="$2"

ext_dir='/var/www/mediawiki/extensions/'
site='https://extdist.wmflabs.org/dist/extensions/'

if [ ! "$name" -o ! "$version" ]
then
    echo "Give extension name and version as arguments; example: WikiArticleFeeds 1.30"
    exit 1
fi

tarballname=$(curl -s "$site" | sed -r 's/.* href="([^"]*)".*/\1/' | grep "^$name-REL$version-")
if [ "$(echo "$tarballname" | wc -l)" -ne 1 ]
then
    echo "Bad results found: $tarballname"
    exit 1
fi

cd $ext_dir

wget "$site/$tarballname" -O "$tarballname"

tar -xf "$tarballname"
