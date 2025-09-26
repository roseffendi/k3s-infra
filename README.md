# Simple Kubernetes Infra

**[NOT FOR PRODUCTION]**

This cluster is using k3s as kubernetes cluster and traefik as ingress controller.

This repository is intended to create a simple Kubernetes development infrastructure environment. It can become a starting point and adjust it by yourself.

This repository includes the following services:

1. Mailpit
2. Minio
3. MySql + PhpMyAdmin
4. PostgreSql + PgAdmin 4
5. Redis + Redis Commander

## Setup
1. Setup the Kubernetes cluster
3. Run `kubectl apply -f cluster.yaml`
4. Run `kubectl apply -f services --recursive`