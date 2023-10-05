# Reth Node Infra

Automates ETH node setup using Lighthouse for the beacon chain and Reth for the execution layer.
This is just a plain node setup with no staking involved.

## Architecture

Both Lighthouse and Reth have their own Compute instance and run within a docker container.
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
The `/mnt/disks/sdb/jwt.hex` (`/mnt/datadir/jwt.hex` within the container) file is generated automatically by Reth.
But it could be overridden using the command below and updating the secret manager.

```sh
openssl rand -hex 32
```

## Local NVMe SSD

Synchronizing the Reth archive node from scratch can take a long time on network attached disk.
For this reason it's possible to mount local NVMe SSDs in raid0 for better performances.
To do so set the bootstrap flag to true.
This will create a raid0 logical device mounted as `/mnt/disks/md0` on the host VM.
It can stay this way for normal operations, but keep in mind that local disks are designed for temporary storage.
This means rebooting or recreating the VM would lead to data loss.

## Backing up chain data

Reth chain data can be backed up to a network attached SSD (fast but expensive) or to a bucket (cheap, but slow).
To back it up to a network attached SSD adjust `reth_datadir_disk_size` prior to creating the VM.
Once the node is fully synced stop the container to copy the local data to the network attached persistent disk.

```sh
toolbox gsutil -o GSUtil:parallel_composite_upload_threshold=150M -m \
cp -r /media/root/mnt/disks/md0/* /media/root/mnt/disks/sdb/
```

For bucket backup, set `create_backup_bucket=true`, stop the container and copy to the bucket.

```sh
toolbox gsutil -o GSUtil:parallel_composite_upload_threshold=150M -m \
cp -r /media/root/mnt/disks/md0/* gs://reth-infra-backup-bucket/reth-`date +%Y%m%d`/
```

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
