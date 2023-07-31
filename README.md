# Reth Node Infra

Automates ETH node setup using Lighthouse for the beacon chain and reth for the execution layer.
This is just a plain node setup with no staking involved.

## Architecture

Both Lighthouse and reth have their own Compute instance and run within a docker container.
Both also have their own persistent disk used for the `datadir`.
The persistent disk is mount in `/mnt/disks/sdb/` on the host side and `/mnt/datadir` container side.

## Use

```sh
make docker/build
make docker/login
make docker/push
make devops/terraform/plan
make devops/terraform/apply
```

## JWT Token deployment

The HTTP connection between your beacon node and execution node needs to be authenticated using a JWT Token.
The `/mnt/disks/sdb/jwt.hex` (`/mnt/datadir/jwt.hex` within the container) file is generated automatically by reth.
But it could be overridden using the command below and updating the secret manager.

```sh
openssl rand -hex 32
```

## Bootstraping

Synchronizing the reth archive node from scratch can take a long time on network attached disk.
For this reason it's possible to mount local NVMe SSDs in raid0 to speed up the process.
It should only be used for the first syncing since this type of disk is designed for temporary storage.
To bootstrap the node using NVMe set `bootstrap=true` and redeploy the node, e.g.

```sh
devops/terraform/redeploy/reth_archive_node_vm/node1
```

This will create a raid0 logical device mounted as `/mnt/disks/md0` on the host VM.
Once the node is fully synced stop the reth container and copy the `/mnt/disks/md0` to the network attached persistent disk `/mnt/disks/sdb`.
Disable bootstrapping `bootstrap=false` and redeploy the VM.

## Reaching a firewalled RPC

If the node port is firewalled, it's possible to tunnel before accessing it.

```sh
ssh user@ip -L 0.0.0.0:8545:localhost:8545
```

Or alternatively using gcloud:

```sh
gcloud compute ssh --ssh-flag="-L 8545:localhost:8545" instance-name
```

Quick check that the node is accessible:

```sh
curl http://localhost:8545 \
--header 'Content-Type: application/json' \
--data '{"method": "net_version", "params": [], "id": 1, "jsonrpc": "2.0"}'
```
