#!/usr/bin/env bash

HOME="/home/vagrant"
BIN_DIR=$HOME"/bin"
DOWNLOADS_DIR=$HOME"/downloads"
SERVICE_DIR="/etc/systemd/system"
SHARED_VAGRANT_DIR="/vagrant"

# print user
echo "provisioning as user:" $USER

# create bin dir (~/bin is already in PATH)
mkdir $BIN_DIR

# create temporary downloads dir
mkdir $DOWNLOADS_DIR

# install unzip
sudo yum install -y unzip

# install wget
sudo yum install -y wget

# install jq
cd $BIN_DIR
wget -nv -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod 764 jq

# install consul
cd $DOWNLOADS_DIR
wget -nv https://releases.hashicorp.com/consul/0.8.5/consul_0.8.5_linux_amd64.zip
unzip consul_0.8.5_linux_amd64.zip
mv consul $BIN_DIR/consul

# install vault
cd $DOWNLOADS_DIR
wget -nv https://releases.hashicorp.com/vault/0.7.3/vault_0.7.3_linux_amd64.zip
cd $BIN_DIR
unzip $DOWNLOADS_DIR/vault_0.7.3_linux_amd64.zip

# setup consul to run as a systemd service
cd $SERVICE_DIR
sudo cp $SHARED_VAGRANT_DIR/consul.service  consul.service
sudo chmod 644 consul.service
sudo systemctl daemon-reload
echo "consul has been installed as a systemd service"

# start consul service
sudo systemctl start consul
echo "consul systemd service started"

# set consul service to run at startup
sudo systemctl enable consul
echo "consul systemd service set to run at startup"

# setup vault server to run as a systemd service
cd $SERVICE_DIR
sudo cp $SHARED_VAGRANT_DIR/vault.service  vault.service
sudo chmod 644 vault.service
sudo systemctl daemon-reload
echo "vault has been installed as a systemd service"

# export vault server location environment variable to bash profile
echo "export VAULT_ADDR='http://127.0.0.1:8200'" >>$HOME/.bash_profile

# if an mlock error appears when starting vault, this is the command to allow linux mlock without running the vault process as root
sudo setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

# start vault service
sudo systemctl start vault
echo "vault systemd service started"

# set vault service to run at startup
sudo systemctl enable vault
echo "vault systemd service set to run at startup"
