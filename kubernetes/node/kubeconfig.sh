#!/bin/bash

#KUBE_APISERVER="http://10.0.255.5:8080"
KUBE_APISERVER="http://${MASTER_ADDRESS}:8080"
# 设置集群参数
kubectl config set-cluster default-cluster \
  --server=${KUBE_APISERVER} \
  --kubeconfig=/usr/local/kubernetes/config/kubeconfig.conf

kubectl config set-context default-context \
  --cluster=default-cluster \
  --kubeconfig=/usr/local/kubernetes/config/kubeconfig.conf

# 设置默认上下文
kubectl config use-context default-context --kubeconfig=/usr/local/kubernetes/config/kubeconfig.conf