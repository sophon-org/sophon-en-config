# Sophon External Node Scripts

This repository contains scripts for setting up and running the Sophon external node.

## Prerequisites

- Docker
- Docker Compose
- An Avail DA account

## Getting an Avail DA account

To get an Avail DA account, you follow the instructions from the [Avail DA user guide](https://docs.availproject.org/user-guides/accounts).

## Installation and running the node from scratch

This section describes how to install and run the node from scratch, syncing from publicly available snapshots form the official registry.

1. Clone the repository:

```bash
git clone https://github.com/sophon-labs/sophon-external-node.git
cd sophon-external-node
```

2. Run the compose file:

```bash
docker-compose up -d
```

### Downloading the snapshots

The snapshots are downloaded automatically when the node starts. You can find them in the `./postgres` directory.

## Running the node from scratch

This section describes how to run the node from scratch, syncing from the genesis.

### Relevant compose file settings

The following settings in the `docker-compose.yml` file are relevant for running the node from scratch:

```yaml
EN_SNAPSHOTS_RECOVERY_ENABLED: "false"
EN_SNAPSHOTS_OBJECT_STORE_BUCKET_BASE_URL: "raas-sophon-mainnet-external-node-snapshots"
```

After setting the above settings, you can run the node using the following command:

```bash
docker-compose up -d
```
