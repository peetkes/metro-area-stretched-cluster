#!/bin/bash
################################################################
#
# Usage:  this_command [options] anyhost groupname
#
################################################################

USER="admin"
PASS="password"
AUTH_MODE="anyauth"

#######################################################
# Parse the command line

OPTIND=1
while getopts ":a:p:u:" opt; do
  case "$opt" in
    a) AUTH_MODE=$OPTARG ;;
    p) PASS=$OPTARG ;;
    u) USER=$OPTARG ;;
    \?) echo "Unrecognized option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ $# -ge 2 ]; then
  HOST=$1
  shift
else
  echo "ERROR: hostname and groupname are required." >&2
  exit 1
fi
GROUPNAME=$1

# Suppress progress meter, but still show errors
CURL="curl -s -S"
# Add authentication related options, required once security is initialized
AUTH_CURL="${CURL} --${AUTH_MODE} --user ${USER}:${PASS}"

$AUTH_CURL -X POST -i -H "Content-type: application/json" -d '{"group-name":"'$GROUPNAME'"}' http://$HOST:8002/manage/v2/groups