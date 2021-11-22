#!/bin/bash

docker run --entrypoint htpasswd registry:2.7.0 -Bbn antx Qwe344Jklld09 >> auth/htpasswd