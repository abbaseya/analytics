#!/bin/bash

VERSION=1.0

usage()
{
cat << EOF
usage: $0 [command]

Plausible helper tools v$VERSION

COMMANDS:
up            Run containers
serve         Start Plausible
down          Stop containers

OPTIONS:
-h|--help     Usage guide

EOF
}

CMD=$1

while [ ! $# -eq 0 ]
do
    case "$1" in
        -h | --help)
            usage
            exit
            ;;
    esac
    shift
done

up()
{
    make postgres
    make clickhouse
    make pgadmin
    docker inspect plausible_db | grep IPAddress
}

serve()
{
    make server &> plausible.log &
}

down()
{
    SERVE_PID=$(ps ax | grep "phx.server" | grep -v grep | awk '{print $1}')
    if [ -n "$SERVE_PID" ]
    then
        kill -9 $SERVE_PID
    fi
    PLAUSIBLE_PID=$(ps ax | grep "plausible" | grep -v grep | awk '{print $1}')
    if [ -n "$PLAUSIBLE_PID" ]
    then
        kill -9 $PLAUSIBLE_PID
    fi
    if [[ "$( docker container inspect -f '{{.State.Status}}' plausible_db )" == "running" ]]
    then
        make postgres-stop
    fi
    if [[ "$( docker container inspect -f '{{.State.Status}}' plausible_clickhouse )" == "running" ]]
    then
        make clickhouse-stop
    fi
    if [[ "$( docker container inspect -f '{{.State.Status}}' plausible_dbadmin )" == "running" ]]
    then
        make pgadmin-stop
    fi
    > plausible.log
}

case $CMD in
    up)
        up
        ;;
    serve)
        serve
        ;;
    down)
        down
        ;;
    *)
        echo -e "${RED}Invalid command!${NC}"
        exit
        ;;
esac
