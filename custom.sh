# etcd 1\2\3
./install_etcd.sh etcd01 etcd01=http://192.168.137.250:2380,etcd02=http://192.168.137.10:2380,etcd03=http://192.168.137.11:2380 192.168.137.250
./install_etcd.sh etcd02 etcd01=http://192.168.137.250:2380,etcd02=http://192.168.137.10:2380,etcd03=http://192.168.137.11:2380 192.168.137.10
./install_etcd.sh etcd03 etcd01=http://192.168.137.250:2380,etcd02=http://192.168.137.10:2380,etcd03=http://192.168.137.11:2380 192.168.137.11

# flannel
./install_flannel.sh http://192.168.137.250:2379,http://192.168.137.10:2379,http://192.168.137.11:2379

# docker
./docker.sh

# master
./install_k8s_master.sh 192.168.137.250 http://192.168.137.250:2379,http://192.168.137.10:2379,http://192.168.137.11:2379

# k8s docker prv
./install_docker_registry_secret.sh

# node
./install_k8s_node.sh 192.168.137.250