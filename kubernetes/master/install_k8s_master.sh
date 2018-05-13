#!/bin/bash


#MASTER_ADDRESS=${1:-"10.0.255.5"}
MASTER_ADDRESS="$1"

ETCD_SERVERS="$2"

if [ ! $MASTER_ADDRESS ]; then
  echo "ENTER MASTER_ADDRESS eg:10.0.255.5"
  exit 1
fi

if [ ! $ETCD_SERVERS ]; then
  echo "ENTER ETCD_SERVERS eg:http:/10.0.255.5:2379,http://10.0.255.6:2379,http://10.0.255.7:2379"
  exit 1
fi


export MASTER_ADDRESS="$MASTER_ADDRESS"

export ETCD_SERVERS="$ETCD_SERVERS"

echo "MASTER_ADDRESS: ${MASTER_ADDRESS}"

echo "ETCD_SERVERS: ${ETCD_SERVERS}"


mkdir -p /usr/local/kubernetes/config
mkdir -p /usr/local/kubernetes/bin

echo "cp file ..."

cp -rf bin/* /usr/local/kubernetes/bin
chmod +x /usr/local/kubernetes/bin/*

echo "set  kubeconfig ..."

echo "export K8S_HOME=/usr/local/kubernetes" >> /etc/profile
echo "export PATH=\$PATH:\$K8S_HOME/bin" >> /etc/profile
source /etc/profile


./kubeconfig.sh

echo "set  apiserver ..."

./apiserver.sh

sleep 5s

echo "set  controller-manager ..."

./controller-manager.sh

echo "set  scheduler ..."

./scheduler.sh

echo "set proxy ..."

./proxy.sh

echo "install success ..."

