# NGINX Instance Manager - Docker image

## Description

This repo creates a docker image for NGINX Instance Manager (NIM, https://www.nginx.com/products/nginx-instance-manager/) so that it can be run on Kubernetes/Openshift.
The image can optionally be built with NGINX Instance Counter support (see https://github.com/fabriziofiorucci/NGINX-InstanceCounter)

## How to build

1. Clone this repo
2. Download NIM .deb installation file (ie. nginx-manager_1.0.3-362724380_amd64.deb) and copy it into nim-files/
3. Get a valid NIM license (nginx-manager.lic) and copy it into nim-files/
4. Edit the provided sample configuration file nim-files/nginx-manager.conf if needed
5. Build NIM Docker image using:

```
./scripts/buildNIM.sh [NIM_DEBFILE] [target Docker image name] [counter enabled (true|false)]

for instance:

./scripts/buildNIM.sh ./nim-files/nginx-manager_1.0.3-362724380_amd64.deb your.registry.tld/nginx-nim:tag true
```

this builds the image and pushes it to a private registry. The last parameter (to be set to either "true" or "false") specifies if NGINX Instance Counter (https://github.com/fabriziofiorucci/NGINX-InstanceCounter) shall be included in the image being built

6. Edit manifests/0.nginx-nim.yaml and specify the correct image by modifying the line

```
image: your.registry.tld/nginx-nim:tag
```

7. Start and stop using

```
./scripts/nimDockerStart.sh start
./scripts/nimDockerStart.sh stop
```

8. After starting NIM, it will be accessible at:

```
NIM GUI: http://nginx-nim.nginx.ff.lan
NIM gRPC port: nginx-nim.nginx.ff.lan:31100
Instance counter REST API (if enabled at build time): http://nginx-nim.nginx.ff.lan/instances (see the documentation at https://github.com/fabriziofiorucci/NGINX-InstanceCounter)
```

NGINX Instances can push their analytics/data to the containerized NIM instance by changing in /etc/nginx-agent/nginx-agent.conf the line:

```
server: nginx-nim.nginx.ff.lan:31100
```

## Tested NIM releases

This repo has been tested with NIM 1.0.3.

## Data persistence

If data persistence is needed across restarts, a persistentVolume for the /data directory can be used.

# Example

## Docker image build

```
$ ./scripts/buildNIM.sh ./nim-files/nginx-manager_1.0.3-362724380_amd64.deb registry.ff.lan:31005/nginx-nim:1.0 true
==> Building NIM docker image
Sending build context to Docker daemon  34.29MB
Step 1/10 : FROM ubuntu:latest
[...]
Successfully built 4d67793c117e
Successfully tagged registry.ff.lan:31005/nginx-nim:1.0
The push refers to repository [registry.ff.lan:31005/nginx-nim]
[...]
1.0: digest: sha256:3dbc6b1af0175149189009f812f134e63f1dafe569f16622c82f9b9eda541c38 size: 1999
```

## Starting NIM

```
$ ./scripts/nimDockerStart.sh start
==> Creating ConfigMaps
namespace/nginx-nim created
configmap/nim-config created
configmap/nim-license created
deployment.apps/nginx-nim created
service/nginx-nim created
service/nginx-nim-grpc created
ingress.networking.k8s.io/nginx-nim created
```
```
$ kubectl get pods -n nginx-nim -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
nginx-nim-78df44bdb-8vdr7   1/1     Running   0          20s   10.244.1.58   f5-node1   <none>           <none>
```

NIM GUI is now reachable at:
- Web GUI: http://nginx-nim.nginx.ff.lan
- gRPC: nginx-nim.nginx.ff.lan:31100
- Instance counter: http://nginx-nim.nginx.ff.lan/instances

## Stopping NIM

```
$ ./scripts/nimDockerStart.sh stop
namespace "nginx-nim" deleted
```
