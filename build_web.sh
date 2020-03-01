#!/bin/bash

# The defaults for the various options come from this file:
. web_options.sh

# NB: IF YOU CHANGE THE ARGBASH STUFF, run:
#       argbash build_web.sh -o build_web.sh

# Created by argbash-init v2.8.1
# ARG_OPTIONAL_SINGLE([mw_version],[v],[mediawiki version, e.g. 1.34],[$DEFAULT_MW_VERSION])
# ARG_OPTIONAL_SINGLE([iteration],[i],[number which is used to force rebuilds even if you haven't changed anything],[$DEFAULT_ITERATION])
# ARG_OPTIONAL_BOOLEAN([test],[t],[Run in test mode (makes a separate instance that doesn't affect the running site at all).],[off])
# ARG_OPTIONAL_BOOLEAN([live],[l],[Run in "live" mode, which simply causes the site to have mw-live.lojban.org as its URL; used to avoid cloudflare caching.],[off])
# ARG_HELP([Runs the web container for the mediawiki])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}


begins_with_short_option()
{
	local first_option all_short_options='vitlh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_mw_version="$DEFAULT_MW_VERSION"
_arg_iteration="$DEFAULT_ITERATION"
_arg_test="off"
_arg_live="off"


print_help()
{
	printf '%s\n' "Runs the web container for the mediawiki"
	printf 'Usage: %s [-v|--mw_version <arg>] [-i|--iteration <arg>] [-t|--(no-)test] [-l|--(no-)live] [-h|--help]\n' "$0"
	printf '\t%s\n' "-v, --mw_version: mediawiki version, e.g. 1.34 (default: '$DEFAULT_MW_VERSION')"
	printf '\t%s\n' "-i, --iteration: number which is used to force rebuilds even if you haven't changed anything (default: '$DEFAULT_ITERATION')"
	printf '\t%s\n' "-t, --test, --no-test: Run in test mode (makes a separate instance that doesn't affect the running site at all). (off by default)"
	printf '\t%s\n' "-l, --live, --no-live: Run in \"live\" mode, which simply causes the site to have mw-live.lojban.org as its URL; used to avoid cloudflare caching. (off by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-v|--mw_version)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_mw_version="$2"
				shift
				;;
			--mw_version=*)
				_arg_mw_version="${_key##--mw_version=}"
				;;
			-v*)
				_arg_mw_version="${_key##-v}"
				;;
			-i|--iteration)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_iteration="$2"
				shift
				;;
			--iteration=*)
				_arg_iteration="${_key##--iteration=}"
				;;
			-i*)
				_arg_iteration="${_key##-i}"
				;;
			-t|--no-test|--test)
				_arg_test="on"
				test "${1:0:5}" = "--no-" && _arg_test="off"
				;;
			-t*)
				_arg_test="on"
				_next="${_key##-t}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-t" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-l|--no-live|--live)
				_arg_live="on"
				test "${1:0:5}" = "--no-" && _arg_live="off"
				;;
			-l*)
				_arg_live="on"
				_next="${_key##-l}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-l" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

exec 2>&1
set -e
set -o pipefail -o noclobber -o nounset
set -x

test=''
if [ "$_arg_test" == 'on' ]
then
            test="-test"
fi

# Note that the live option is completely ignored here; it has no effect at docker build time
live=''
if [ "$_arg_live" == 'on' ]
then
            live="-live"
fi

if [ "$live" -a "$test" ]
then
    echo "Pick only one of live or test please."
    exit 1
fi

CONTAINER_BIN=${CONTAINER_BIN:-$(which podman)}
CONTAINER_BIN=${CONTAINER_BIN:-$(which docker)}

#************
# Build website
#************

# Check for a non-privleged user
UNUSED_USERID=998
if id $UNUSED_USERID >/dev/null 2>&1
then
	echo "userid $UNUSED_USERID is in use, but we need one that is not."
	exit 1
fi
UNUSED_GROUPID=998
if id -g $UNUSED_GROUPID >/dev/null 2>&1
then
	echo "userid $UNUSED_GROUPID is in use, but we need one that is not."
	exit 1
fi

echo
echo "Building website container."
echo

rm -f data/Dockerfile.web$test
erb mw_version=$_arg_mw_version \
	mw_userid=$(id -u) mw_groupid=$(id -g) \
    unused_userid=$UNUSED_USERID unused_groupid=$UNUSED_GROUPID \
    Dockerfile.web$test.erb >data/Dockerfile.web$test
chmod --reference=Dockerfile.web$test.erb data/Dockerfile.web$test

$CONTAINER_BIN build -t lojban/mediawiki_web:$_arg_mw_version-$_arg_iteration -f data/Dockerfile.web$test .

# ] <-- needed because of Argbash
