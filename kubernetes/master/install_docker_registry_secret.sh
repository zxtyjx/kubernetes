#!/bin/bash

echo "create ihuaben-production namespace ..."

kubectl create namespace dev-namespace

echo "create  docker-registry secret ..."

kubectl create secret docker-registry registrykey-aliyun -n dev-namespace --docker-server=registry.cn-qingdao.aliyuncs.com --docker-username=313823394@qq.com --docker-password=zx19830113 --docker-email=13823394@qq.com

kubectl create secret docker-registry registrykey-aliyun-zx -n kube-system --docker-server=registry.cn-qingdao.aliyuncs.com --docker-username=13823394@qq.com --docker-password=zx19830113 --docker-email=13823394@qq.com

echo "install success ..."

