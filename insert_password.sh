#!/bin/bash

prefix="$1"
if [ ! "$prefix" ]
then
	echo "Must give a prefix, like 'mysql', as first argument."
	exit 1
fi
file="DO_NOT_CHECK_IN/${prefix}_password.txt"
if [ ! -r $file ]
then
	echo "File $file doesn't exist or can't be read."
	exit 1
fi

if [ ! -f data/LocalSettings.php ]
then
	cp LocalSettings.php.in data/LocalSettings.php
fi

sed -i "s/--$prefix PASSWORD--/$(cat $file)/" data/LocalSettings.php
