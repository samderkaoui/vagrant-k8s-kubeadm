#!/bin/bash

docker rm websrv && \
 docker build -t web . && \
 docker run --name websrv -p 8080:80 web