#!/usr/bin/env sh

_catch() {
    echo "Killing process..."
    [ -z $(jobs -p) ] || kill $(jobs -p)
    exit #$
}

trap _catch INT TERM

if [ ! -e /var/run/docker.sock ]; then
    echo "You must mount the host docker socket as a volume to /var/run/docker.sock"
    exit 1
fi;

if [ -z "$AWS_REGION" ]; then
    AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
fi

while true; do
    logincmd=$(AWS_DEFAULT_REGION=$AWS_REGION aws ecr get-login --no-include-email)

    if [ $? -ne 0 ]; then
        echo "There was an error with ecr get-login."
        exit 1
    fi

    eval "$logincmd"
    if [ $? -ne 0 ]; then
        echo "There was an error with docker login."
        exit 1
    fi

    echo "Updating services."
    services=$(docker service ls --format "{{.Name}} {{.Image}}" | grep "dkr.ecr" | awk '{print $1;}')
    for service in ${services}; do
        docker service update --with-registry-auth --detach=true "$service"
    done;

    echo "Updates complete, sleeping..."
    sleep 4h &
    wait
done;
