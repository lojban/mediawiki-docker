#!/bin/bash

prefix="$1"
if [ ! "$prefix" ]
then
	echo "Must give a prefix, like 'mysql', as first argument."
	exit 1
fi
target="$2"
if [ ! "$target" ]
then
	echo "Must give a target file, like 'LocalSettings.php', as second argument."
	exit 1
fi
file="DO_NOT_CHECK_IN/${prefix}_password.txt"
if [ ! -r $file ]
then
	echo "File $file doesn't exist or can't be read."
	exit 1
fi

if [ ! -f data/$target ]
then
	cp $target.in data/$target
fi

sed -i "s/--$prefix PASSWORD--/$(cat $file)/" data/$target
