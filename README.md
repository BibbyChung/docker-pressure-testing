# docker-pressure-testing

Using this docker image to test your machines.

## How To Use

``` bash
docker run \
  --cpus=0.5 \
  --memory=256M \
  bibbynet/docker-pressure-testing:latest \
    --cpu 1 \
    --vm 1 \
    --vm-bytes 128M
```

``` yaml
# docker-compose -f docker-compose.yaml up

version: "3.7"

services:
  loading-test:
    build:
      context: ./
      dockerfile: ./Dockerfile
    command: ["--cpu", "1", "--vm", "1", "--vm-bytes", "128M"]
    ports: 
      - "80:80"
    deploy:
      resources:
        limits:
          cpus: "0.5"
          memory: 256M
        reservations:
          cpus: "0.5"
          memory: 256M
```

``` yaml
# kubectl apply -f k8s.yaml

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    run: my-pressure-testing
  name: my-pressure-testing
spec:
  replicas: 2
  strategy:
    rollingUpdate:
      maxSurge: 60%
      maxUnavailable: 60%
  selector:
    matchLabels:
      run: my-pressure-testing
  template:
    metadata:
      labels:
        run: my-pressure-testing
    spec:
      containers:
      - image: bibbynet/docker-pressure-testing:1.0
        name: my-pressure-testing
        ports:
        - containerPort: 80
        args: ["--cpu", "1", "--vm", "1", "--vm-bytes", "128M"]
        resources:
          requests:
            cpu: 256m
            memory: 256Mi
          limits:
            cpu: 256m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /
            port: 80
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 10
```

## Options

``` bash
Usage: stress [OPTION [ARG]] ...

 -?, --help         show this help statement
     --version      show version statement
 -v, --verbose      be verbose
 -q, --quiet        be quiet
 -n, --dry-run      show what would have been done
 -t, --timeout N    timeout after N seconds
     --backoff N    wait factor of N microseconds before work starts
 -c, --cpu N        spawn N workers spinning on sqrt()
 -i, --io N         spawn N workers spinning on sync()
 -m, --vm N         spawn N workers spinning on malloc()/free()
     --vm-bytes B   malloc B bytes per vm worker (default is 256MB)
     --vm-stride B  touch a byte every B bytes (default is 4096)
     --vm-hang N    sleep N secs before free (default none, 0 is inf)
     --vm-keep      redirty memory instead of freeing and reallocating
 -d, --hdd N        spawn N workers spinning on write()/unlink()
     --hdd-bytes B  write B bytes per hdd worker (default is 1GB)

Example: stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 10s

Note: Numbers may be suffixed with s,m,h,d,y (time) or B,K,M,G (size).
```
