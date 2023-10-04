echo "$(hostname) $(date) Mounting attached disk"
sudo lsblk
part=$(sudo lsblk | grep --extended-regexp 'part +/' | grep -oh 'sd[a-z]1' | cut -c1-3 | uniq)
echo "part=$part"
devs=$(sudo lsblk | grep disk | grep -v $part | grep -oh 'sd[a-z]')
echo "devs=$devs"

mount_command() {
  sudo mount -o discard,defaults /dev/$dev /mnt/disks/$dev && \
  sudo chmod a+rwx /mnt/disks/$dev
}

mount_network_attached_devices() {
  for dev in $devs; do
    # automatically resize/grow the partition if needed
    e2fsck -f -y /dev/$dev
    resize2fs /dev/$dev
    sudo mkdir -p /mnt/disks/$dev
    # make sure the `mount` command fails gracefully using the `||`
    # or the startup-script may be aborted entirely
    RESULT=0
    mount_command $dev || RESULT=1
    if [ $RESULT -eq 0 ]; then
      echo "Mounted /dev/$dev to /mnt/disks/$dev"
    else
      echo "Formatting /dev/$dev to ext4"
      sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$dev
      mount_command $dev
    fi
  done
}

# mount all local NVMe en SSD as raid0
# https://cloud.google.com/compute/docs/disks/add-local-ssd#formatmultiple
mount_local_raid0() {
  device_prefix=google-local-nvme-ssd
  # make sure the `mount` command fails gracefully using the `||`
  # or the startup-script may be aborted entirely
  RESULT=0
  # identify all of the local SSDs that we want to mount together
  local_ssd=$(find /dev/ | grep $device_prefix) || RESULT=1
  if [ $RESULT -eq 0 ]; then
    dev=md0
    device_count=$(echo "$local_ssd" | wc -l)
    # combine multiple local SSD devices into a single array named /dev/$dev
    sudo mdadm --create /dev/$dev --level=0 --raid-devices=$device_count $local_ssd
    # confirm the details of the array
    sudo mdadm --detail --prefer=by-id /dev/$dev
    # format the full /dev/$dev array with an ext4 file system
    sudo mkfs.ext4 -F /dev/$dev
    sudo mkdir -p /mnt/disks/$dev
    mount_command $dev
  fi
}

mount_network_attached_devices
mount_local_raid0
df -h
