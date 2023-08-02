#!/usr/bin/env bash

# Enable debug
# set -x

CONFIG=
DOCKER_NAME=
DOCKER_TAG=

while getopts c:n:t: flag
do
    case "${flag}" in
        c ) CONFIG=${OPTARG};;
        n ) DOCKER_NAME=${OPTARG};;
        t ) DOCKER_TAG=${OPTARG};;
    esac
done

if [[ -z "$CONFIG" ]]; then
    echo "-c (config) parameter is missing"
    exit 1
fi

if [[ -z "$DOCKER_NAME" ]]; then
    echo "-n (docker name) parameter is missing"
    exit 1
fi

if [[ -z "$CONFIG" ]]; then
    echo "-t (docker tag) parameter is missing"
    exit 1
fi

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

echo "Reading properties from $CONFIG"

if [[ ! -f "$CONFIG" ]]; then
    echo "File $CONFIG is not there, aborting."
    exit 1
fi

function prop {
    grep "${1}" $CONFIG | cut -d'=' -f2
}

rm -rf pluginpath && mkdir pluginpath
rm -rf classpath && mkdir classpath

declare -a PP=($(prop "kafka\.connect\.pluginpath="))
for s in "${PP[@]}"
do
    item=$(prop "kafka\.connect\.pluginpath\.$s=")
    wget -q $item -P ./pluginpath

    if [[ $name == *zip ]]; then
        unzip ./pluginpath/$item
    fi
done

declare -a CP=($(prop "kafka\.connect\.classpath="))
for s in "${CP[@]}"
do
    item=$(prop "kafka\.connect\.classpath\.$s=")
    wget -q $item -P ./classpath

    if [[ $name == *zip ]]; then
        unzip ./classpath/$item
    fi
done

echo .
echo "Building the docker image"
set -x
docker build -t "$DOCKER_NAME:$DOCKER_TAG" .
