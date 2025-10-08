# Simple Kubernetes Infrastructure
**[NOT FOR PRODUCTION]**

This repository is intended to create a simple Kubernetes development infrastructure environment. It can become a starting point and adjust it by yourself. This cluster is using k3s kubernetes distribution.

This repository includes the following services:

1. Mailpit
2. Minio
3. MySql + PhpMyAdmin
4. PostgreSql + PgAdmin 4
5. Redis + Redis Commander
5. Mongodb + Mongodb Express

## Configure the cluster

1. Install k3s.
2. Copy `/etc/rancher/k3s/k3s.yaml` to `~/.kube/config and run sudo` `chown $(id -u):$(id -g) ~/.kube/config` to prevent using kubectl with sudo.
3. Copy `k3s/registries.yaml` to `/etc/rancher/k3s/registries.yaml`.
4. Restart k3s service `sudo systemctl restart k3s`.
5. Edit traefik deployment `kubectl -n kube-system edit deploy/traefik` and add `--providers.kubernetescrd.allowCrossNamespace=true` on `spec.template.spec.args`

## Setup the infra namespace

1. Setup the Kubernetes cluster.
2. Install cert manager `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml`.
3. Instal reflector, `kubectl -n kube-system apply -f https://github.com/emberstack/kubernetes-reflector/releases/latest/download/reflector.yaml`.
4. Run `kubectl apply -f services/org.yaml`.

## Build necessary images

This repository is using custom postgres image that install vector db extension. If you're not using the service, feel free to skip it

1. Install `nerdctl`.
2. Install `buildkit`.
3. Copy `buildkit/buildkitd.toml to /etc/buildkit/buildkitd.toml`.
4. Copy `buildkit/buildkit.service to /etc/systemd/system/buildkit.service`.
5. Run `sudo systemctl enable buildkit.service --now` to enable and start buildkit service.
6. Copy `docker/build-dirs.example` to `docker/build-dirs.txt`. To add another dir as build source, add a new line with the target directory. You can skip the build dir by commenting the line using hashtag (`#`).
7. Run `./docker/build.sh` to build all registered directories.
8. The images will be registered to local registry `registry.k3s.kube` and accessible via `registry.k3s.kube/{base-filename}:kube`. For example, `postgres17.6-vector.dockerfile` will be accessible via `registry.k3s.kube/postgres17.6-vector:kube`.
9. You can add `nerdctl` to NOPASSWD to skip password prompt.

## Setup the infra services

1. Run `kubectl apply -f services services/{service-dir}` to install each service.
2. Run `kubectl apply -f services --recursive` to install all services.

## Ingress Addresses

1. http://mailpit.kube
2. http://minio.kube
3. http://api.minio.kube
4. http://admin.mongodb.kube
5. http://admin.mysql.kube
6. http://admin.postgres.kube
7. http://admin.redis.kube

## Credentials

All services are using `root` as user and `password` as password except pgadmin that is using `root@locahost.com` as email.