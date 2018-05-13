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
#ETCD_SERVERS=${2:-"http:/10.0.255.5:2379,http://10.0.255.6:2379,http://10.0.255.7:2379"}

SERVICE_CLUSTER_IP_RANGE=${1:-"172.18.0.0/16"}
ADMISSION_CONTROL=${2:-"NamespaceLifecycle,LimitRanger,NamespaceExists,DefaultStorageClass,ResourceQuota"}

cat <<EOF >/usr/local/kubernetes/config/kube-apiserver.conf
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=2"
KUBE_ETCD_SERVERS="--etcd-servers=${ETCD_SERVERS}"
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"
KUBE_API_PORT="--insecure-port=8080"
NODE_PORT="--kubelet-port=10250"
KUBE_ADVERTISE_ADDR="--advertise-address=${MASTER_ADDRESS}"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"
KUBE_ADMISSION_CONTROL="--admission-control=${ADMISSION_CONTROL}"
EOF

KUBE_APISERVER_OPTS="   \${KUBE_LOGTOSTDERR}         \\
                        \${KUBE_LOG_LEVEL}           \\
                        \${KUBE_ETCD_SERVERS}        \\
                        \${KUBE_API_ADDRESS}         \\
                        \${KUBE_API_PORT}            \\
                        \${NODE_PORT}                \\
                        \${KUBE_ADVERTISE_ADDR}      \\
                        \${KUBE_ALLOW_PRIV}          \\
                        \${KUBE_SERVICE_ADDRESSES}   \\
                        \${KUBE_ADMISSION_CONTROL}"

cat <<EOF >/usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=http://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/usr/local/kubernetes/config/kube-apiserver.conf
ExecStart=/usr/local/kubernetes/bin/kube-apiserver ${KUBE_APISERVER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl restart kube-apiserver
