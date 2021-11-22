#!/bin/bash

ENV=k8s-1
REG_ADDRESS=docker-registry.a-dev.com
REG_USER=antx
REG_PWD=Qwe344Jklld09


# Logins to docker registry and creates docker credentials secret
# in each namespace of specified cluster

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export KUBECONFIG="${DIR}/../kubeconfig_${ENV}"

kubectl get namespaces | awk 'NR!=1 { print $1 }' | grep -v kube | while read -r ns ; do

    kubectl create secret docker-registry docker-private-reg \
        --namespace ${ns} \
        --docker-server=https://${REG_ADDRESS}/v1/ \
        --docker-username=${REG_USER} \
        --docker-password=${REG_PWD}

done