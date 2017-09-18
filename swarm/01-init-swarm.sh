#!/usr/bin/env bash

set -o nounset
set -o errexit
#set -o xtrace

cd "${BASH_SOURCE%/*}"

if [ "$(docker info --format '{{ .Swarm.LocalNodeState }}')" == "inactive" ];then
  echo "Initialize swarm manager."
  docker swarm init
fi

SWARM_MASTER_NODE_ADDR=$(docker info --format '{{ .Swarm.NodeAddr }}')

echo "Swarm manager is available at ${SWARM_MASTER_NODE_ADDR}."
