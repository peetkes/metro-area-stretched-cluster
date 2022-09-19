#!/bin/bash
################################################################
#
# Usage:  this_command [options] anyhost groupname
#
################################################################

USER=admin
PASS=password
AUTH_MODE=anyauth
SSL=true

#######################################################
# Parse the command line

OPTIND=1
while getopts ":a:p:u:s:" opt; do
  case "$opt" in
    a) AUTH_MODE=$OPTARG ;;
    p) PASS=$OPTARG ;;
    u) USER=$OPTARG ;;
    s) SSL=$OPTARG ;;
    \?) echo "./create_group.sh -u [user] -p [password] -s [true/false] [bootstrap-host] [votergroep]
    Onbekende option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

PROTO=http
if [ $SSL == "true" ]
then
  PROTO=https
fi

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

response=$($AUTH_CURL -X POST -i -w "%{http_code}" -H "Content-type: application/json" -d '{"group-name":"'$GROUPNAME'"}' $PROTO://$HOST:8002/manage/v2/groups)
http_code=${response: -3}
if [ "$http_code" == "201" -o "$http_code" == "204" ]
then 
  echo Aanmaken groep $GROUPNAME is gelukt
else 
  echo  Aanmaken groep $GROUPNAME is NIET gelukt
fi