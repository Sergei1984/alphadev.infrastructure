#!/bin/bash

ENV=k8s-1
DOMAIN=a-dev.com
ACCOUNT=seregat1984@gmail.com
SECRET_NAME=tls

# Refreshes Lets Encrypt certificate and creates TLS secret with name tls-default
# in each namespace of k8s cluster

# Prerequisites
## https://github.com/acmesh-official/acme.sh
## Acme: curl https://get.acme.sh | sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

~/.acme.sh/acme.sh  --register-account  -m myemail@example.com --server zerossl
~/.acme.sh/acme.sh --list | grep ${DOMAIN}

if [[ $? == "1" ]]
then
    echo "Certificate not issued, issue..."
    ~/.acme.sh/acme.sh  --issue -d *.${DOMAIN} --dns --yes-I-know-dns-manual-mode-enough-go-ahead-please
fi

~/.acme.sh/acme.sh  --renew -d *.${DOMAIN} --yes-I-know-dns-manual-mode-enough-go-ahead-please

read -p "Update DNS, wait for 5 min and Press enter..."

~/.acme.sh/acme.sh  --renew -d *.${DOMAIN} --yes-I-know-dns-manual-mode-enough-go-ahead-please

CERT=~/.acme.sh/*.${DOMAIN}/*.${DOMAIN}.cer
CERT_KEY=~/.acme.sh/*.${DOMAIN}/*.${DOMAIN}.key

export KUBECONFIG="${DIR}/../kubeconfig_${ENV}"

# kubectl create secret tls ${SECRET_NAME} \
#     --key ${CERT_KEY} \
#     --cert ${CERT}

kubectl get namespaces | awk 'NR!=1 { print $1 }' | grep -v kube | while read -r ns ; do
    kubectl create secret tls ${SECRET_NAME} --key ${CERT_KEY} --cert ${CERT} -n ${ns}
done