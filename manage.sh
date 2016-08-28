#!/bin/bash

CONTAINER=pbertera/pelican
LOCAL_PORT=8000
SSH_KEY=.ssh/id_dsa

case $1 in
    deploy)
        docker run -it -v ${PWD}:/site -p ${LOCAL_PORT}:${LOCAL_PORT} -v ${HOME}/${SSH_KEY}:/root/${SSH_KEY} $CONTAINER github
        ;;
    update)
        docker run -it -v ${PWD}:/site $CONTAINER html && docker run -it -v ${PWD}:/site -p ${LOCAL_PORT}:${LOCAL_PORT} $CONTAINER serve 
        ;;
    build)
        docker build -t ${CONTAINER} .
        ;;
    *)
        docker run -it -v ${PWD}:/site -p ${LOCAL_PORT}:${LOCAL_PORT} -v ${HOME}/${SSH_KEY}:/root/${SSH_KEY} $CONTAINER $1
        ;; 
esac
