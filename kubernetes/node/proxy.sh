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

cat <<EOF >/usr/local/kubernetes/config/kube-proxy.conf
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=2"
NODE_HOSTNAME="--hostname-override=${HOSTNAME}"
KUBE_MASTER="--master=http://${MASTER_ADDRESS}:8080"
EOF

KUBE_PROXY_OPTS="   \${KUBE_LOGTOSTDERR} \\
                    \${KUBE_LOG_LEVEL}   \\
                    \${NODE_HOSTNAME}    \\
                    \${KUBE_MASTER}"

cat <<EOF >/usr/lib/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=-/usr/local/kubernetes/config/kube-proxy.conf
ExecStart=/usr/local/kubernetes/bin/kube-proxy ${KUBE_PROXY_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-proxy
systemctl restart kube-proxy
