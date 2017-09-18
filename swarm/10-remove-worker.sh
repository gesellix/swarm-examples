#!/usr/bin/env bash

set -o nounset
set -o errexit
#set -o xtrace

cd "${BASH_SOURCE%/*}"

# let all worker nodes leave the swarm
WORKERS=$(docker ps --filter label=de.gesellix.swarm.node=worker --format '{{ .ID }}')
for worker in ${WORKERS}; do
  worker_hostname=$(docker inspect ${worker} --format '{{ .Config.Hostname }}')
  echo ""
  echo "${worker_hostname} is going to leave the swarm."
  docker exec -it ${worker} \
    docker swarm leave || echo "${worker_hostname} has already left the swarm."
done

# shut down all worker nodes and the registries
docker-compose down
