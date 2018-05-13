#!/bin/bash
docker rmi $(docker images | grep registry.cn-qingdao.aliyuncs.com/zx_develop/ | awk '{print $3}')
