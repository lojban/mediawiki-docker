#!/bin/bash

set -e

name="$1"
version="$2"

site='https://extdist.wmflabs.org/dist/extensions/'

cd extensions/

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

wget "$site/$tarballname" -O "$tarballname"

tar -xf "$tarballname"
