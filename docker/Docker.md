# Docker

## Basics

Start eines Docker images:

    docker run --name nexcloud01 -p 8080:80 -d nextcloud

docker start

docker stop

docker rmi

docker rm

Attach to a running docker session:

    docker exec -it CONTAINER_NAME /bin/bash

## Volumes

Ein volume anlegen:

    docker volume create VOLUME_NAME

Ein docker containter mit einem eingebundenen volume starten:

    docker run --name NAME_CONTAINER -p8080:80 --mount source=VOLUME_NAME,target=/usr/share/nginix//html -d nginx

Eine Datei in ein Docker volume kopieren:

docker cp FILE VOLUME_NAME:MOUNTPOINT

    docker cp index.html test-volume:/user/share/nginx/html
