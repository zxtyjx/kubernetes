#!/bin/bash

# Copyright 2014 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



#MASTER_ADDRESS=${1:-"10.0.255.5"}
MASTER_ADDRESS="$1"

if [ ! $MASTER_ADDRESS ]; then
  echo "ENTER MASTER_ADDRESS eg:10.0.255.5"
  exit 1
fi

export MASTER_ADDRESS="$MASTER_ADDRESS"

echo "MASTER_ADDRESS: ${MASTER_ADDRESS}"

mkdir -p /usr/local/kubernetes/config
mkdir -p /usr/local/kubernetes/bin

echo "cp file ..."

cp -rf bin/* /usr/local/kubernetes/bin
chmod +x /usr/local/kubernetes/bin/*

mv shell /root/
chmod +x /root/shell/*

echo "set clean_docker_image crontab ..."

echo "0 0 * * * /root/shell/clean_docker_image.sh" >> /var/spool/cron/root

echo "set  kubeconfig ..."

echo "export K8S_HOME=/usr/local/kubernetes" >> /etc/profile
echo "export PATH=\$PATH:\$K8S_HOME/bin" >> /etc/profile
source /etc/profile

./kubeconfig.sh

echo "set  kubelet ..."

./kubelet.sh

echo "set  proxy ..."

./proxy.sh

echo "install success ..."