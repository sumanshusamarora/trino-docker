#!/bin/bash

ARG=$1

# Build and run worker and host separately on localhost
build_host_separate_localhost() {
  docker build -t trino-coordinator -f DockerfileCoordinator .
  docker build -t trino-worker -f DockerfileWorker .
  docker run --rm -d --net host --name trino-coordinator trino-coordinator
  docker run --rm -d --net host --name trino-worker trino-worker
}

# Build and run worker and host separately on docker VM network
build_host_separate_docker_vm() {
  docker build -t trino-coordinator -f DockerfileCoordinator .
  docker run --rm -d -p 8099:8099 --name trino-coordinator trino-coordinator
  COORDINATOR_URL="http://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' trino-coordinator):8099"
  docker build --build-arg DISCOVERY_URI=${COORDINATOR_URL} -t trino-worker -f DockerfileWorker .
  docker run --rm -d -p 8200:8200 --name trino-worker trino-worker
  echo "Coordinator running at - $COORDINATOR_URL"
}

# Build and run worker and host on single node on localhost
build_host_single_node_localhost() {
  docker build -t trino-worker -f DockerfileCoordinatorWorker .
  docker run --rm -d --net host --name trino-coordinator-worker trino-coordinator-worker
}

# Build and run worker and host on single node on docker VM network
build_host_single_node_docker_vm() {
  docker build -t trino-worker -f DockerfileCoordinatorWorker .
  docker run --rm -d -p 8099:8099 --name trino-coordinator-worker trino-coordinator-worker
  COORDINATOR_URL="http://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' trino-coordinator-worker):8099"
  echo "Coordinator running at - $COORDINATOR_URL"
}

help_method() {
  echo "bash ./setup.sh separate_local|separate_docker_vm|single_local|single_docker_vm|stop|help"
}

# Build and run worker and host on single node on docker VM network
stop() {
  docker stop trino-worker trino-coordinator trino-coordinator-worker
}

if [[ $# -eq 0 ]] ; then
  echo "Missing Argument"
  help_method
  exit 0
fi

if [ "$1" == "separate_local" ]; then
  build_host_separate_localhost
elif [ "$1" == "separate_docker_vm" ]; then
  build_host_separate_docker_vm
elif [ "$1" == "single_local" ]; then
  build_host_single_node_localhost
elif [ "$1" == "single_docker_vm" ]; then
  build_host_single_node_docker_vm
elif [ "$1" == "stop" ]; then
  stop
elif [ "$1" == "help" ]; then
  help_method
fi
