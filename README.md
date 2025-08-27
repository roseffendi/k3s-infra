# Simple Minikube Infra

**[NOT FOR PRODUCTION]**

This repository is intended to create a simple Minikube development infrastructure environment. It can become a starting point and adjust it by yourself

This repository includes the following services:

1. Mailpit
2. Minio
3. MySql + PhpMyAdmin
4. PostgreSql + PgAdmin 4
5. Redis + Redis Commander

## Setup
1. Setup the Minikube cluster
2. Enable ingress addon `minikube addons enable ingress`
3. Run `kubectl apply -f cluster.yaml`
4. Run `kubectl apply -f services --recursive`

## Known Issues

1. On MacOs Apple sillicon, and using docker driver, `minikube tunnel` is needed and the domain should be registered on `/etc/hosts`