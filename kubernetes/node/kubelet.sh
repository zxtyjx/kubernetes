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

DNS_SERVER_IP=${1:-"172.18.0.250"}
DNS_DOMAIN=${2:-"cluster.local"}
KUBECONFIG_DIR=${KUBECONFIG_DIR:-/usr/local/kubernetes/config}


cat <<EOF >/usr/local/kubernetes/config/kubelet.conf
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=2"
NODE_ADDRESS="--address=0.0.0.0"
NODE_PORT="--port=10250"
NODE_HOSTNAME="--hostname-override=${HOSTNAME}"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBELET_DNS_IP="--cluster-dns=${DNS_SERVER_IP}"
KUBELET_DNS_DOMAIN="--cluster-domain=${DNS_DOMAIN}"
KUBE_POD_INFRA_CONTAINER_IMAGE="--pod-infra-container-image=registry.cn-qingdao.aliyuncs.com/zx_develop/k8s-dns-dnsmasq-nanny-amd64:3.0"
KUBE_RUNTIME_CGROUPS="--runtime-cgroups=/systemd/system.slice"
KUBE_CGROUPS="--kubelet-cgroups=/systemd/system.slice"
KUBE_FAIL_SWAP_ON="--fail-swap-on=false"
KUBE_CONFIG="--kubeconfig=/usr/local/kubernetes/config/kubeconfig.conf"
EOF

KUBELET_OPTS="      \${KUBE_LOGTOSTDERR}     \\
                    \${KUBE_LOG_LEVEL}       \\
                    \${NODE_ADDRESS}         \\
                    \${NODE_PORT}            \\
                    \${NODE_HOSTNAME}        \\
                    \${KUBE_ALLOW_PRIV}      \\
                    \${KUBELET_DNS_IP}       \\
                    \${KUBELET_DNS_DOMAIN}	 \\
                    \${KUBE_RUNTIME_CGROUPS} \\
                    \${KUBE_CGROUPS}		 \\
                    \${KUBE_FAIL_SWAP_ON}	 \\
                    \${KUBE_CONFIG}			 \\
                    \${KUBE_POD_INFRA_CONTAINER_IMAGE}"

cat <<EOF >/usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=-/usr/local/kubernetes/config/kubelet.conf
ExecStart=/usr/local/kubernetes/bin/kubelet ${KUBELET_OPTS}
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
