#!/bin/bash

echo "uninstall docker ..."

sudo yum remove docker-engine docker-engine-selinux -y

echo "install docker ..."

#sudo yum install docker -y

sudo yum install -y yum-utils device-mapper-persistent-data lvm2

#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum install -y docker-ce

mkdir -p /usr/local/kubernetes/config

#DOCKER_OPTS=${1:-"--registry-mirrors=https://9snvg9q3.mirror.aliyuncs.com --insecure-registries=registry-vpc.cn-beijing.aliyuncs.com"}

DOCKER_OPTS=${1-:""}

#DOCKER_REGISTRY="--registry-mirror=https://9snvg9q3.mirror.aliyuncs.com --insecure-registry=http://registry-vpc.cn-beijing.aliyuncs.com"

DOCKER_CONFIG=/usr/local/kubernetes/config/docker.conf

echo "gen  ${DOCKER_CONFIG}"

cat <<EOF >$DOCKER_CONFIG
DOCKER_OPTS="-H tcp://127.0.0.1:4243 -H unix:///var/run/docker.sock -s overlay --selinux-enabled=false ${DOCKER_OPTS}"
EOF

echo "gen  /usr/lib/systemd/system/docker.service "

cat <<EOF >/usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target flannel.service
Requires=flannel.service

[Service]
Type=notify
EnvironmentFile=-/usr/local/kubernetes/config/docker.conf
EnvironmentFile=-/run/flannel/docker
WorkingDirectory=/usr/bin/
ExecStart=/usr/bin/dockerd \\
		  \$DOCKER_OPT_BIP \\
		  \$DOCKER_OPT_MTU \\
		  \$DOCKER_OPTS
LimitNOFILE=1048576
LimitNPROC=1048576

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://a3xuyqgj.mirror.aliyuncs.com"],
  "insecure-registries":["registry.cn-qingdao.aliyuncs.com"]
}
EOF

systemctl daemon-reload
systemctl enable docker
systemctl restart docker

sudo docker login -u=13823394@qq.com -p=zx19830113 registry.cn-qingdao.aliyuncs.com

echo "docker install success ..."