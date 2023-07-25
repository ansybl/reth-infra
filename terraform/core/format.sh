echo "$(hostname) $(date) Mounting attached disk"
sudo lsblk
part=$(sudo lsblk | grep 'part /' | grep -oh 'sd[a-z]1' | cut -c1-3 | uniq)
echo "part=$part"
devs=$(sudo lsblk | grep disk | grep -v $part | grep -oh 'sd[a-z]')
echo "devs=$devs"

mount_command() {
  sudo mount -o discard,defaults /dev/$dev /mnt/disks/$dev && \
  sudo chmod a+rwx /mnt/disks/$dev
}

for dev in $devs; do
  # automatically resize/grow the partition if needed
  e2fsck -f -y /dev/sdb
  resize2fs /dev/sdb
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
df -h
