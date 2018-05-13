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

mkdir -p /usr/local/kubernetes/config
mkdir -p /usr/local/kubernetes/bin


#ETCD_SERVERS=${1:-"http://10.0.255.5:2379,http://10.0.255.6:2379,http://10.0.255.7:2379"}

ETCD_SERVERS="$1"

if [ ! $ETCD_SERVERS ]; then
  echo "ENTER ETCD_SERVERS eg:http://10.0.255.5:2379,http://10.0.255.6:2379,http://10.0.255.7:2379"
  exit 1
fi

cp -rf bin/* /usr/local/kubernetes/bin
chmod +x /usr/local/kubernetes/bin/*

FLANNEL_NET='{"Network":"172.18.0.0/16", "SubnetMin": "172.18.1.0", "SubnetMax": "172.18.254.0",  "Backend": {"Type": "vxlan"}}'

IFACE="eth0"

cat <<EOF >/usr/local/kubernetes/config/flannel.conf
FLANNEL_ETCD="--etcd-endpoints=${ETCD_SERVERS}"
FLANNEL_ETCD_KEY="--etcd-prefix=/ihuaben.com/network"
FLANNEL_IFACE="--iface=${IFACE}"
EOF

cat <<EOF >/usr/lib/systemd/system/flannel.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target

[Service]
EnvironmentFile=-/usr/local/kubernetes/config/flannel.conf
ExecStartPre=/usr/local/kubernetes/bin/remove-docker0.sh
ExecStart=/usr/local/kubernetes/bin/flanneld \\
    --ip-masq \\
    \${FLANNEL_ETCD} \\
    \${FLANNEL_ETCD_KEY} 
ExecStartPost=/usr/local/kubernetes/bin/mk-docker-opts.sh -d /run/flannel/docker


Type=notify

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF

# Store FLANNEL_NET to etcd.
attempt=0
while true; do
#  /usr/local/kubernetes/bin/etcdctl --ca-file ${CA_FILE} --cert-file ${CERT_FILE} --key-file ${KEY_FILE} \
  /usr/local/kubernetes/bin/etcdctl \
    --no-sync -C ${ETCD_SERVERS} \
    get /ihuaben.com/network/config >/dev/null 2>&1
  if [[ "$?" == 0 ]]; then
    break
  else
    if (( attempt > 600 )); then
      echo "timeout for waiting network config" > ~/kube/err.log
      exit 2
    fi

#    /usr/local/kubernetes/bin/etcdctl --ca-file ${CA_FILE} --cert-file ${CERT_FILE} --key-file ${KEY_FILE} \
    /usr/local/kubernetes/bin/etcdctl \
      --no-sync -C ${ETCD_SERVERS} \
      mk /ihuaben.com/network/config "${FLANNEL_NET}" >/dev/null 2>&1
    attempt=$((attempt+1))
    sleep 3
  fi
done
wait

systemctl enable flannel
systemctl daemon-reload
systemctl restart flannel
