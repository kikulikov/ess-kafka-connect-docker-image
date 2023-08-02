#!/usr/bin/env bash

CONFIG=
DEBUG=FALSE

for i in "$@"; do
    case $i in
        --config=*)
        CONFIG="${i#*=}"
        shift
        ;;
        --debug)
        DEBUG=TRUE
        shift
        ;;
        -*|--*)
        echo "Unknown option $i"
        exit 1
        ;;
        *)
        ;;
    esac
done

if [[ -z "$CONFIG" ]]; then
    echo "--config parameter is missing"
    exit 1
fi

if [[ "$DEBUG" == "TRUE" ]]; then
    echo "Debug mode enabled $DEBUG"
    set -x
fi

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

echo "Reading properties from $CONFIG"

function prop {
    grep "${1}" $CONFIG | cut -d'=' -f2
}

declare -a BUCKETS=($(prop 'kafka\.connect\.images'))

rm -rf pluginpath && mkdir pluginpath
rm -rf classpath && mkdir classpath
rm -rf Dockerfile && touch Dockerfile
echo "FROM confluentinc/cp-server-connect:7.3.4" > Dockerfile

for i in "${BUCKETS[@]}"
do
    declare -a PP=($(prop "kafka\.connect\.$i\.pluginpath="))
    for s in "${PP[@]}"
    do
        item=$(prop "kafka\.connect\.$i\.pluginpath\.$s=")
        wget -q $item -P ./pluginpath

        if [[ $name == *zip ]]; then
            unzip ./pluginpath/$item
        fi
    done

    # declare -a CP=($(prop "kafka.connect.$i.classpath"))
    # echo "$CP"
done

# while getopts u:a:f: flag
# do
#     case "${flag}" in
#         u) username=${OPTARG};;
#         a) age=${OPTARG};;
#         f) fullname=${OPTARG};;
#     esac
# done
# echo "Username: $username";
# echo "Age: $age";
# echo "Full Name: $fullname";
