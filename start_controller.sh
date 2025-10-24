#!/bin/bash

docker build -t controller .

docker run -it --rm \
    --hostname controller \
    -e TF_VAR_hcloud_token=$TF_VAR_hcloud_token \
    -v .:/app \
    controller