#!/bin/bash

ARG=$1

# Build and run worker and host separately on localhost
build_host_separate_localhost() {
  docker build -t trino-cordinator -f DockerfileCordinator .
  docker build -t trino-worker -f DockerfileWorker .
  docker run --rm -d --net host --name trino-cordinator trino-cordinator
  docker run --rm -d --net host --name trino-worker trino-worker
}

# Build and run worker and host separately on docker VM network
build_host_separate_docker_vm() {
  docker build -t trino-cordinator -f DockerfileCordinator .
  docker run --rm -d -p 8099:8099 --name trino-cordinator trino-cordinator
  docker build --build-arg CORDINATOR_URL=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' trino-cordinator):8099 -t trino-worker -f DockerfileWorker .
  docker run --rm -d -p 8200:8200 --name trino-worker trino-worker
}

# Build and run worker and host on single node on localhost
build_host_single_node_localhost() {
  docker build -t trino-worker -f DockerfileCordinatorWorker .
  docker run --rm -d --net host --name trino-cordinator-worker trino-cordinator-worker
}

# Build and run worker and host on single node on docker VM network
build_host_single_node_docker_vm() {
  docker build -t trino-worker -f DockerfileCordinatorWorker .
  docker run --rm -d -p 8099:8099 --name trino-cordinator-worker trino-cordinator-worker
}

help_method() {
  echo "Missing Argument"
  echo "bash ./setup.sh separate_local|separate_docker_vm|single_local|single_docker_vm|stop|help"
}

# Build and run worker and host on single node on docker VM network
stop() {
  docker kill $(docker ps -q)
}

if [[ $# -eq 0 ]] ; then
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
