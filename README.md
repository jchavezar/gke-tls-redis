# gke-tls-redis
Securing communication from Google Kubernetes Engine to Memorystore (redis)

## Let's get started!

This guide will show you how to connect your gke workload to redis (memorystore) enabling in-transit encryption.

**Time to complete**: About 10 minutes


### Setup
1. Go to [Google Cloud Shell](https://shell.cloud.google.com) and clone this repo
```sh
project_id=<PROJECT_ID>
redis_name=<INSTANCE_NAME>
region=<REGION>
cluster_name=<CLUSTER_NAME>
image_name=<IMAGE_NAME>
secret_name=<SECRET_NAME>
zone=<ZONE>
```

2. Create a redis instance with encryption enabled

```sh

gcloud redis instances create $redis_name --transit-encryption-mode=server-authentication --region=$region

```

3. Save the public ip address and CA key.

```sh

gcloud redis instances describe $redis_name --region=$region

```

Set ip address variable.

```sh

redis_ip=<REDIS_IP>

```

4. Create a GKE cluster with ip-alias enabled.

```sh

gcloud container clusters create $cluster_name \
  --zone=$zone \
  --enable-ip-alias

```

5. Create stunnel file configuration.

```sh

cat << EOF > redis-cli.conf
output=/tmp/stunnel.log
CAfile=/secret/server_ca.pem
client=yes
pid=/var/run/stunnel.pid
verifyChain=yes
sslVersion=TLSv1.2
[redis]
accept=127.0.0.1:6378
connect=$redis_ip:6378
EOF

```

6. Create the bash file.

```sh

cat << EOF > start_stunnel.sh
#!/bin/bash

/usr/bin/stunnel /etc/stunnel/redis-cli.conf

# run forever
tail -f /dev/null
EOF

```

7. Create Dockerfile.

```sh

cat << EOF > Dockerfile
FROM ubuntu
RUN apt update && apt install telnet -y && apt install -y stunnel4
ADD redis-cli.conf /etc/stunnel/redis-cli.conf
ADD start_stunnel.sh /start_stunnel.sh

RUN chmod +x /start_stunnel.sh
RUN chmod 600 /etc/stunnel/redis-cli.conf
CMD ["/start_stunnel.sh"]
EOF

```


8. Build the container image locally.

```sh

docker build . $image_name --tag gcr.io/$project_id/stunnel:v1

```

9. Push the image to google container registry (gcr.io).

```sh

docker push gcr.io/$project_id/stunnel:v1

```

10. Create secret from the CA certificate downloaded earlier. Use an editor like vim|emacs|nano.


```sh

kubectl create secret generic $secret_name --from-file=server_ca.pem

```

11. Create deployment.yaml

```sh

cat << EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stunnel
  labels:
    app: stunnel
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stunnel
  template:
    metadata:
      labels:
        app: stunnel
    spec:
      containers:
      - name: stunnel
        image: gcr.io/user-0001/stunnel:v1
        ports:
        - containerPort: 6378
        volumeMounts:
        - name: sec
          mountPath: /secret/server_ca.pem
          subPath: server_ca.pem
          readOnly: true
          #command: ["bash", "start_stunnel.sh"]
      volumes:
      - name: sec
        secret:
          secretName: casecret
EOF

```

12. Create k8s deployment.


```sh

kubectl create -f deployment.yaml

```

Testing.

```sh

kubectl exec -ti pod/<POD_NAME> /bin/bash
telnet localhost 6378

Logging:

root@stunnel-7d95dff77d-srlc6:/# telnet localhost 6378
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
PING
+PONG

```
