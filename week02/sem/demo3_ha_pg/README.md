# Vulnerable PostgreSQL High Availability Cluster Example

## ⚠️ Security Warning
**IMPORTANT**: This configuration is intentionally vulnerable and is meant for demonstration spoofing of the patroni configuration via an insecure etcd api

Vulnerability
In the current configuration, etcd is launched without authentication, which allows an attacker to:

* Gain unauthorized access to the etcd API
* Modify PostgreSQL configuration through etcd
* Change the archive_command parameter and achieve Remote Code Execution (RCE) on the PostgreSQL server

## Recommendations for Fixing Vulnerabilities
For production use, the vulnerabilities must be addressed:

1. Enable authentication in etcd:
    * Add parameters like `--auth-token`, `--client-cert-auth`, and `--trusted-ca-file` to etcd configuration
2. Use API v3 instead of v2:
    * Remove the `--enable-v2=true` parameter
    * Update Patroni configuration to work with API v3

## Overview
This repository demonstrates a setup of a High Availability PostgreSQL cluster using Patroni for cluster management, etcd for distributed consensus, and HAProxy for load balancing.

## Launching the Cluster
To start the cluster, run:

```bash
docker-compose up --build -d
```
After startup, you'll have a working PostgreSQL cluster with automatic failover capability.

## Failover Demonstration
One of the key features of this high availability setup is automatic failover. To demonstrate this:

1. Identify the current primary PostgreSQL node (either pg-patroni-1 or pg-patroni-2)

2. Stop the primary node container:
    ```bash
    docker-compose stop pg-patroni-1
    ```
3. The system will automatically:
* Detect the failure of the primary node
* Promote the replica node to become the new primary
* Update etcd with the new leader information
* HAProxy will automatically route traffic to the new primary node
