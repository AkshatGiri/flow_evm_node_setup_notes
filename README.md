# Running a Flow Evm Node

## Introduction

## Setting up server

I'm using a server on linode running Ubuntu 20.04 LTS.

### Update and upgrade the server

```bash
sudo apt-get update && sudo apt-get upgrade
```

### Installing docker

The easiest way to install Docker on Ubuntu is to use the official Docker repository. Here's the step-by-step process:

First, update your package list and install required dependencies:

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
```

Add Docker's official GPG key:

```bash
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Set up the Docker repository:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Update the package list again and install Docker:

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Verify the installation:

```bash
sudo docker run hello-world
```

If you want to run Docker without sudo, you can add your user to the docker group:

```bash
sudo usermod -aG docker $USER
```

Then log out and back in for the changes to take effect.

### Download the Flow EVM node image

```bash
docker pull us-west1-docker.pkg.dev/dl-flow-devex-production/development/flow-evm-gateway:${VERSION}
```

image versions can be found [here](https://console.cloud.google.com/artifacts/docker/dl-flow-devex-production/us-west1/development/flow-evm-gateway?invt=AblAFg&inv=1)

### Running the Flow EVM node

Get the IMAGE_ID

```
docker images
```

The following command runs the node in index only mode which means you won't need to any gas in the coa account and will not accrue any fees in the coinbase account. You can remove the `--index-only` flag if you wish to process transactions.

```bash
docker run -d -p 8545:8545 {IMAGE_ID} \
--access-node-grpc-host=access.mainnet.nodes.onflow.org:9000 \
--access-node-spork-hosts=access-001.mainnet25.nodes.onflow.org:9000 \
--flow-network-id=flow-mainnet \
--init-cadence-height=85981135 \
--ws-enabled=true \
--coinbase={FLOW_EVM_ACCOUNT_WITHOUT_0x} \
--coa-address={CADENCE_ACCOUNT_WITHOUT_0x} \
--coa-key={CADENCE_ACCOUNT_PRIVATE_KEY_WITHOUT_0x} \
--gas-price=100 \
--index-only
```

OR if this is a private node you can run the following and disable most of the rate limits.

```bash
docker run -d -p 8545:8545 -p 8080:8080 -p 6060:6060 {IMAGE_ID} \
--access-node-grpc-host=access.mainnet.nodes.onflow.org:9000 \
--access-node-spork-hosts=access-001.mainnet25.nodes.onflow.org:9000 \
--flow-network-id=flow-mainnet \
--init-cadence-height=85981135 \
--ws-enabled=true \
--coinbase={FLOW_EVM_ACCOUNT_WITHOUT_0x} \
--coa-address={CADENCE_ACCOUNT_WITHOUT_0x} \
--coa-key={CADENCE_ACCOUNT_PRIVATE_KEY_WITHOUT_0x} \
--gas-price=100 \
--rate-limit=0 \
--stream-limit=0 \
--stream-timeout=60 \
--filter-expiry=0
```

### Check the logs

```bash
docker ps
```

Get the CONTAINER_ID

This command allows us to listen to new logs as they come in instead of printing all of the old ones which is what docker logs will do by default.

```bash
docker logs -f --tail 0 {CONTAINER_ID}
```

### Check sysc level

I've made a script that get the current synced blocks as well as the highest block on the network and then shows the percentage of the sync.

If you're running it for the first time you might need to give it permission to run.

```bash
chmod +x check_progress.sh
```

Then you can run it with

```bash
./check_progress.sh
```

## Useful links

- https://developers.flow.com/networks/node-ops/access-onchain-data/evm-gateway/evm-gateway-setup
- https://github.com/onflow/flow-evm-gateway

## TODOs

- Expose rpc to the internet.
  - There are a few ways to do this. Using ngnix, opening an ssh tunnel, cady, reverse proxy etc. For my personal use I've used an ssh tunnel and connected the pulic port directly to the container port. Probably not the right way to do this for production but works for my use case. Not sure what's the recommended way to do this. Since we're also trying to support websocket connections I'm not sure what method provides the least overhead and easies setup / maintainability.
