# Docker registry

## Deployment

Details could be found in official documentations https://docs.docker.com/registry/deploying/

To deploy a docker registry apply `docker-registry.yml`
Address of registry is specified in Ingress, by default it's `registry.anuitex-dev.xyz`

To test registry outside the cluster run following bash script:

```
REG_ADDRESS=registry.anuitex-dev.xyz
REG_USER=antx
REG_PWD=Qwe344Jklld09

docker login -u $REG_USER -p $REG_PWD $REG_ADDRESS

if [[ $? -ne 0 ]]
then
   exit 1
fi

docker pull nginx
docker image tag nginx $REG_ADDRESS/my-nginx
docker push $REG_ADDRESS/my-nginx
```

## Authorization

To create new registry user, edit and run `create-registry-user.sh`
By default, there is a user `antx` with password `Qwe344Jklld09`

# Proxy applications

Proxy applications are web apps running on another server but available under `xxx.anuitex-dev.xyz` subdomain.
The certificate and host are served by k8s

## List of available applications
 - https://tenders.anuitex-dev.xyz/
 - https://social-collab.anuitex-dev.xyz/

## How to deploy
- Copy one of proxy YAML (with `-proxy.yml` suffix)
- Change domain and address of proxied application
- Run `kubectl apply -f my-app-proxy`

# Postgres

There is an instance of the Postgres running on server (outside of k8s).
To create new database, run following commands:

- Open `psql` command line as `postgres` user:
  ```
  # Run in bash
  sudo -u postgres psql
  ```

- Create new user (run in `psql` command line):
  ```
  create user antxdev with encrypted password 'Ki87jjHYll';
  ```
- Create new database (run in `psql` CLI):
  ```
  create database antxpmt2maindev;
  ```
- Grant privileges to user (`psql`):
  ```
  grant all privileges on database antxpmt2maindev to antxdev;
  ```

# Mongo DB

Administrative user: `admin` pwd: `Ik_9923asd2344HN2sd`
Host to connect: `anuitex-dev.xyz`

# Updating SSL

* Run comand
 `~/.acme.sh/acme.sh  --renew -d *.anuitex-dev.xyz --yes-I-know-dns-manual-mode-enough-go-ahead-please`

* Add TXT record specified in output to DNS (DNS CP is here https://ap.www.namecheap.com/Domains/DomainControlPanel/anuitex-dev.xyz/advancedns)
* Run command above again. If everything is ok, the certificate will be printed.
* Update ssl/anuitex-dev.crt file with new content printed by command above
* Update secret in kubernetes

```
kubectl delete secret anuitex-dev-wildcard && \
kubectl create secret tls anuitex-dev-wildcard --key ssl/server.key --cert ssl/anuitex-dev.crt
```
* Copy new certificate `sudo cp ssl/anuitex-dev.crt /etc/ssl/certs/`
* Update certificates in system `sudo update-ca-certificates`