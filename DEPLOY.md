# Guide: Refactoring Docker Compose for Railway Deployment

The original docker-compose setup used local bind mounts (`./directory:/container/path`), which don't work on Railway. We needed to:

1. Use named volumes instead of bind mounts
2. Bake configuration files into custom images
3. Ensure each service uses only one volume

## Custom Images

### `Dockerfile.prometheus`

```dockerfile
FROM prom/prometheus:v2.35.0
COPY prometheus/prometheus.yml /etc/prometheus/prometheus.yml
```

### `Dockerfile.external-node`

```dockerfile
FROM matterlabs/external-node:2.0-v28.5.0
COPY configs /configs

# Environment variables for the node
ENV DATABASE_URL="postgres://postgres:notsecurepassword@postgres:5430/zksync_local_ext_node" \
    DATABASE_POOL_SIZE=10 \
    EN_HTTP_PORT=3060 \
    # ... (other env vars)
```

### 2. Required Configuration Files

#### Project Structure

```
configs/
├── general.yaml              # DA client config
├── mainnet_consensus_config.yaml
├── mainnet_consensus_secrets.yaml
├── generate_secrets.sh
└── ... (other config files)

prometheus/
└── prometheus.yml
```

#### Example `configs/general.yaml`

```yaml
da_client:
  avail:
    bridge_api_url: https://bridge-api.avail.so
    timeout_ms: 20000
    full_client:
      api_node_url: wss://mainnet.avail-rpc.com/
      app_id: 102
      finality_state: "finalized"
```

### 3. Docker Compose Changes

Original:

```yaml
volumes:
  - ./configs:/configs
  - ./rocksdb:/db
```

Refactored:

```yaml
volumes:
  - external-node-data:/configs
  - external-node-data:/db
```

## Deployment Steps

1. **Build Custom Images**

```bash
# Build Prometheus image
docker build -f Dockerfile.prometheus -t prometheus-custom:local .

# Build External Node image
docker build -f Dockerfile.external-node -t external-node-custom:local .
```

2. **Push Images to Registry**

```bash
# Tag images for your registry
docker tag prometheus-custom:local your-registry/prometheus-custom:latest
docker tag external-node-custom:local your-registry/external-node-custom:latest

# Push to registry
docker push your-registry/prometheus-custom:latest
docker push your-registry/external-node-custom:latest
```

3. **Update Image References**

```yaml
services:
  prometheus:
    image: your-registry/prometheus-custom:latest
  external-node:
    image: your-registry/external-node-custom:latest
```

## Testing Locally

1. **Build Images**

```bash
docker build -f Dockerfile.prometheus -t prometheus-custom:local .
docker build -f Dockerfile.external-node -t external-node-custom:local .
```

2. **Start Stack**

```bash
docker compose up
```

3. **Verify Services**

- Check Prometheus at `localhost:9090`
- Check External Node endpoints
- Verify logs for configuration errors

## Railway Deployment Checklist

- [ ] All bind mounts replaced with named volumes
- [ ] Configuration files baked into images
- [ ] Images pushed to a registry Railway can access
- [ ] Each service uses only one volume
- [ ] Environment variables set in Railway dashboard (if needed)
- [ ] Secrets managed through Railway's secrets management

