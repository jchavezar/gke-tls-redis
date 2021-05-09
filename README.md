# gke-tls-redis
Securing communication from Google Kubernetes Engine to Memorystore (redis)

## Let's get started!

This guide will show you how to connect your gke workload to redis (memorystore) enabling in-transit encryption.

**Time to complete**: About 10 minutes


### Setup
1. Go to [Google Cloud Shell](https://shell.cloud.google.com) and clone this repo
```sh
project_id= <PROJECT_ID>
redis_name= <INSTANCE_NAME>
region= <REGION>
```

2. Create a redis instance with encryption enabled

```sh

gcloud redis instances create $redis_name --transit-encryption-mode=server-authentication --region=$region

```

3. Save the public ip address and CA key.

```sh

gcloud redis instances describe $redis_name --region=$region

```

4. Create a GKE cluster with ip-alias enabled.

```sh

gcloud container clusters create cluster-name \
  --region=region \
  --enable-ip-alias \
  --subnetwork=subnet-name \
  --cluster-ipv4-cidr=pod-ip-range \
  --services-ipv4-cidr=services-ip-range

```
