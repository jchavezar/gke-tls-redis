# gke-tls-redis
Securing communication from Google Kubernetes Engine to Memorystore (redis)

## Let's get started!

This guide will show you how to connect your gke workload to redis (memorystore) enabling in-transit encryption.

**Time to complete**: About 10 minutes


### Setup
1. Go to [Google Cloud Shell](https://shell.cloud.google.com) and clone this repo
```sh
project_id= *PROJECT_ID*
name= *INSTANCE_NAME*
```

2. Create a redis instance with encryption enabled

```sh

gcloud redis instances create redis-name --transit-encryption-mode=server-authentication --region=us-central1

```
