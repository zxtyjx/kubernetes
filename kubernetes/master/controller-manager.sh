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

cat <<EOF >/usr/local/kubernetes/config/kube-controller-manager.conf
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=2"
KUBE_MASTER="--master=http://${MASTER_ADDRESS}:8080"
EOF

KUBE_CONTROLLER_MANAGER_OPTS="  \${KUBE_LOGTOSTDERR} \\
                                \${KUBE_LOG_LEVEL}   \\
                                \${KUBE_MASTER}"

cat <<EOF >/usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/usr/local/kubernetes/config/kube-controller-manager.conf
ExecStart=/usr/local/kubernetes/bin/kube-controller-manager ${KUBE_CONTROLLER_MANAGER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl restart kube-controller-manager
