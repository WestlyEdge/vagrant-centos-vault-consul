#!/usr/bin/env bash

HOME="/home/vagrant"
BIN_DIR=$HOME"/bin"
DOWNLOADS_DIR=$HOME"/downloads"

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

# set vault server location environment
export VAULT_ADDR='http://127.0.0.1:8200'

# if an mlock error appears when starting vault, this is the command to allow linux mlock without running the vault process as root
sudo setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

# command to start consul
#nohup consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -bind 127.0.0.1 &

# command to start vault
#nohup vault server -config=/vagrant/vault-config.hcl &
