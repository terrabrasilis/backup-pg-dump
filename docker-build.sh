#!/bin/bash

VERSION=$(cat ./PROJECT_VERSION | grep -oP '(?<="version": ")[^"]*')
export VERSION

# build all images
docker build -t terrabrasilis/backup-pg-dump:v$VERSION --build-arg VERSION=$VERSION -f Dockerfile ./src

# send to dockerhub
echo "The building was finished! Do you want sending this new image to Docker HUB? Type yes to continue." ; read SEND_TO_HUB
if [[ ! "$SEND_TO_HUB" = "yes" ]]; then
    echo "Ok, not send the image."
else
    echo "Nice, sending the image!"
    docker push terrabrasilis/backup-pg-dump:v$VERSION
fi