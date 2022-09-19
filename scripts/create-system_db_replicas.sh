#!/bin/bash
################################################################
#
# Usage:  this_command [options] anyhost replicahost forestname [forestname ...]
#
################################################################

USER=admin
PASS=password
AUTH_MODE=anyauth
SSL=true

check-response() {
  if [ "$1" == "201" -o "$1" == "204" ]
  then 
    shift
    echo $@ is gelukt
  else 
    shift
    echo $@ is NIET gelukt
  fi
}

#######################################################
# Parse the command line

OPTIND=1
while getopts ":a:p:u:s:" opt; do
  case "$opt" in
    a) AUTH_MODE=$OPTARG ;;
    p) PASS=$OPTARG ;;
    u) USER=$OPTARG ;;
    s) SSL=$OPTARG ;;
    \?) echo "./create-system_db_replicas.sh -u [user] -p [password] -s [true/false] [bootstrap-host] [replica-host] [forest-name]+
    Onbekende option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

PROTO=http
if [ $SSL == "true" ]
then
  PROTO=https
fi

if [ $# -ge 3 ]; then
  HOST=$1
  shift
else
  echo "ERROR: bootstrap-host, replica-host and forest-name are required." >&2
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
  # create replica forest
  response=$($AUTH_CURL -X POST -i -w "%{http_code}" -H "Content-type: application/json" -d '{ "forest-name":"'$FOREST'-R", "host": "'$REPLICAHOST'" }' $PROTO://$HOST:8002/manage/v2/forests)
  http_code=${response: -3}
  check-response $http_code "Create replicaforest $FOREST-R"

  # couple replica to master
  response=$($AUTH_CURL -X PUT -i -w "%{http_code}" -H "Content-type: application/json" -d '{ "forest-replica":[{"replica-name": "'$FOREST'-R", "host": "'$REPLICAHOST'"}] }' $PROTO://$HOST:8002/manage/v2/forests/$FOREST/properties)
  http_code=${response: -3}
  check-response $http_code "Couple replicaforest $FOREST-R to $FOREST" 
done
