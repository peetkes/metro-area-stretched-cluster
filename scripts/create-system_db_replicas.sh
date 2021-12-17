#!/bin/bash
################################################################
#
# Usage:  this_command [options] anyhost replicahost forestname [forestname ...]
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

if [ $# -ge 3 ]; then
  HOST=$1
  shift
else
  echo "ERROR: hostname, replicahost and forestname are required." >&2
  exit 1
fi
REPLICAHOST=$1
shift
FORESTS=$@


# Suppress progress meter, but still show errors
CURL="curl -s -S"
# Add authentication related options, required once security is initialized
AUTH_CURL="${CURL} --${AUTH_MODE} --user ${USER}:${PASS}"
for FOREST in $FORESTS;
do

  $AUTH_CURL -X POST -i -H "Content-type: application/json" -d '{ "forest-name":"'$FOREST'-R", "host": "'$REPLICAHOST'" }' http://$HOST:8002/manage/v2/forests
  # couple replica to master
  $AUTH_CURL -X PUT -i -H "Content-type: application/json" -d '{ "forest-replica":[{"replica-name": "'$FOREST'-R", "host": "'$REPLICAHOST'"}] }' http://$HOST:8002/manage/v2/forests/$FOREST/properties
done
