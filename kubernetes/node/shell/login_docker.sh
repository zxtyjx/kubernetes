#!/bin/bash
##
# Name          : login_docker.sh
# Created       : mgr 2015/10/12
# Usages        : ./login_docker.sh [容器名]
##

echo "--------------------"
echo $1
id=$(docker ps |grep $1 |awk '{print $1}')
echo "--------------------"
echo $id
PID=$(docker inspect -f "{{ .State.Pid }}" $id)
echo "--------------------"
echo $PID
nsenter --target $PID --mount --ipc --uts --pid --net /bin/sh
