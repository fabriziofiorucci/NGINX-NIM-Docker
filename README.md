# NGINX Instance Manager - Docker image

This repository is archived. NGINX Instance Manager 1.x is outdated by 2.x releases, please use https://github.com/fabriziofiorucci/NGINX-NIM2-Docker instead

## Description

This repo creates a docker image for NGINX Instance Manager 1.x (NIM, https://docs.nginx.com/nginx-instance-manager/) so that it can be run on Kubernetes/Openshift.
The image can optionally be built with F5 Telemetry Tracker support (see https://github.com/fabriziofiorucci/F5-Telemetry-Tracker)

## How to build

1. Clone this repo
2. Download NIM 1.x .deb installation file (ie. nginx-manager_1.0.4-415830014_amd64.deb) and copy it into nim-files/
3. Get a valid NIM license (nginx-manager.lic) and copy it into nim-files/
4. Edit the provided sample configuration file nim-files/nginx-manager.conf if needed
5. Build NIM Docker image using:

```
./scripts/buildNIM.sh [NIM_DEBFILE] [target Docker image name] [F5 Telemetry Tracker enabled (true|false)]

for instance:

./scripts/buildNIM.sh ./nim-files/nginx-manager_1.0.4-415830014_amd64.deb your.registry.tld/nginx-nim:tag true
```

this builds the image and pushes it to a private registry. The last parameter (to be set to either "true" or "false") specifies if F5 Telemetry Tracker (https://github.com/fabriziofiorucci/F5-Telemetry-Tracker) shall be included in the image being built

6. Edit manifests/0.nginx-nim.yaml and specify the correct image by modifying the "image" line. Additionally modify the "env:" section if you need F5 Telemetry Tracker to push instances data to a remote collector

```
image: your.registry.tld/nginx-nim:tag
```

```
        env:
          ### F5 Telemetry Tracker Push mode
          - name: STATS_PUSH_ENABLE
            #value: "true"
            value: "false"
          - name: STATS_PUSH_MODE
            value: CUSTOM
            #value: PUSHGATEWAY
          - name: STATS_PUSH_URL
            value: "http://192.168.1.5/callHome"
            #value: "http://pushgateway.nginx.ff.lan"
          ### Push interval in seconds
          - name: STATS_PUSH_INTERVAL
            value: "10"
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
F5 Telemetry Tracker REST API (if enabled at build time - see the documentation at https://github.com/fabriziofiorucci/F5-Telemetry-Tracker):
- http://nginx-nim.nginx.ff.lan/f5tt/instances
- http://nginx-nim.nginx.ff.lan/f5tt/metrics
- Push mode (configured through env variables in manifests/0.nginx-nim.yaml)
```

NGINX Instances can push their analytics/data to the containerized NIM instance by changing in /etc/nginx-agent/nginx-agent.conf the line:

```
server: nginx-nim.nginx.ff.lan:31100
```

## Tested NIM releases

This repo has been tested with NIM 1.0.3 and 1.0.4.

## Data persistence

If data persistence is needed across restarts, a persistentVolume for the /data directory can be used.

# Example

## Docker image build

```
$ ./scripts/buildNIM.sh ./nim-files/nginx-manager_1.0.4-415830014_amd64.deb registry.ff.lan:31005/nginx-nim:1.0 true
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
- F5 Telemetry Tracker: http://nginx-nim.nginx.ff.lan/f5tt/instances and http://nginx-nim.nginx.ff.lan/f5tt/metrics and push mode

## Stopping NIM

```
$ ./scripts/nimDockerStart.sh stop
namespace "nginx-nim" deleted
```
