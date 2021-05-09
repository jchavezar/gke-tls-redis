# gke-tls-redis
Securing communication from Google Kubernetes Engine to Memorystore (redis)

## Let's get started!

This guide will show you how to connect your gke workload to redis (memorystore) enabling in-transit encryption.

**Time to complete**: About 10 minutes

Create a redis instance with encryption enabled

```bash

gcloud redis instances create redis-name --transit-encryption-mode=server-authentication --region=us-central1

```
