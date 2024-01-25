### Set up some temp variables to use in our script

# This variables represents the size of the added attached disk we specified
# at VM creation.  Whatever you specified at creation time should match this variable
# NOTE: If you happen to create an attached disk that's the same size as the boot
# disk (don't do that) then this all will fail.
DISK_SIZE=200G
# This fetches our attached disk
DISK_NAME=`sudo lsblk | grep -Eo "^[[:space:]]*[a-z0-9]+.*$DISK_SIZE" | grep -Eo "^[[:space:]]*[a-z0-9]+"`
# Because the disk name can change each time, we need to fetch the UUID to use in /etc/fstab
DISK_UUID=`sudo blkid /dev/$DISK_NAME | grep -Eo '="[a-z0-9\-]+" ' | grep -Eo "[a-z0-9\-]+"`
# A default directory to store the database data itself. If you don't want it in this location,
# you can change this directory. Note here that GCE startup scripts run as root
# and the $USER variable is not yet defined, so be careful.
OMNI_DATA_DIR=/var/lib/alloydbomni/data

# Formatting our new drive
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DISK_NAME
# Creating our mount point.
sudo mkdir -p $OMNI_DATA_DIR
# Mount the disk and make it writeable
sudo mount -o discard,defaults /dev/$DISK_NAME $OMNI_DATA_DIR
sudo chmod a+w $OMNI_DATA_DIR
# Backup the fstab file just in case we mess something up, then write an entry for our
# new disk so it mounts on startup. If you want to allow the machine to come up even if
# the disk isn't available for whatever reason, you'll want to add 'nofail' to the options
# right after discard and defaults, so that piece reads: 'discard,defaults,nofail'
sudo cp /etc/fstab /etc/fstab.backup
echo "UUID=$DISK_UUID $OMNI_DATA_DIR ext4 discard,defaults 0 2" | sudo tee -a /etc/fstab
# Because of timing of all of this, an occasional panic will cause a lost+found directory to
# be created, but not used. Intentionally, the rm does NOT use the m flag, so if the directory
# isn't empty (something really did go wrong) that will fail and stop the script at this point
sudo rm -r lost+found

### Time to start installing things!
sudo apt-get update
# First up need to install the requirements for installing Docker
sudo apt-get -y install ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Next up, time to install Docker itself
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
curl https://us-apt.pkg.dev/doc/repo-signing-key.gpg | sudo apt-key add -
sudo apt update
echo "deb https://us-apt.pkg.dev/projects/alloydb-omni alloydb-omni-apt main" | sudo tee -a /etc/apt/sources.list.d/artifact-registry.list
sudo apt update
# And now we're installing AlloyDB Omni itself
sudo apt-get -y install alloydb-cli
sudo alloydb database-server install --data-dir=$OMNI_DATA_DIR
sudo alloydb database-server start
# Last, installing the psql client so we can easily interact with our Omni server
sudo apt-get -y install postgresql-client
# Now you should be able to connect to Omni with 'psql -h localhost -U postgres'
# Note that there is no password set by default, so be sure first thing you do is
# set a password for the postgres user.