#!/bin/bash
# 本脚主要目的是使用 docker 实现平滑关闭和启动 Spring Boot 程序
set -e
docker_compose_file=/data/deploy/tools/docker-compose-spring.yml

# 启动前的检测，传入服务名称
function check_before_start() {
  if [[ ! -f "${docker_compose_file}" ]]; then
    echo "【compose】启动文件不存在" && exit 2
  fi
  jar_file="/var/spring/$1.jar"
  if [[ ! -f "${jar_file}" ]]; then
    echo "【jar】运行文件不存在" && exit 2
  fi
}

# 根据服务获取监控端口
function get_actuator_port() {
  case "$1" in
  "gateway-server")
    echo 15001
    ;;
  "uc-server")
    echo 15002
    ;;
  *)
    echo 0
    ;;
  esac
}

# 停服（这里使用了 docker-compose ）
function stop() {
  container_name="$1"
  echo "Container ${container_name} stopping"
  # 容器是否存在
  if [[ -z $(docker ps -a -q -f "name=${container_name}") ]]; then
    return
  fi
  status=$(docker inspect --format '{{.State.Status}}' "${container_name}")
  if [[ "$status" == "running" ]]; then
    # 注销服务
    actuator_port=$(get_actuator_port "$1")
    service_registry_down="http://127.0.0.1:${actuator_port}/actuator/service-registry?status=DOWN"
    data=$(curl -s -X POST "${service_registry_down}" -H "Content-Type: application/vnd.spring-boot.actuator.v2+json;charset=UTF-8" 2>&1)
    if [[ -n $data ]]; then
      echo "$data"
    else
      sleep 20s
    fi
    # 停止服务|直接停止容器
    docker stop -t 30 "${container_name}"
  fi
  docker rm "${container_name}"
}

# 将 jar 包移动到指定目录
function transfer() {
  if [[ ! -d /var/spring ]]; then
    mkdir -p /var/spring
  fi
  if alias | grep -q 'cp='; then
    unalias cp
  fi
  jar_name="$1.jar"
  cp -f /data/deploy/packages/spring/"${jar_name}" /var/spring/"${jar_name}"
}

# 启动服务
function start() {
  check_before_start "$1"
  container_name="$1"
  echo "Starting ${container_name}"
  # 设置环境变量用于构建
  if [[ -n $2 ]]; then
    MODE="$2"
    export MODE
  fi
  # 本地IP加入环境变量
  LOCAL_IP=$(ifconfig -a | grep inet | grep '192.168.*' | awk '{print $2}' | sed -e 's/addr://g')
  export LOCAL_IP
  echo "Building ${container_name} image"
  build_out=$(docker-compose -f "${docker_compose_file}" build "${container_name}")
  echo "${build_out}"
  # up -d 2>&1表示错误信息输出到&1，而&1，将被输出
  output=$(docker-compose --compatibility -f "${docker_compose_file}" up -d "${container_name}" 2>&1)
  echo "${output}"
  container_status=$(docker inspect --format '{{.State.Status}}' "${container_name}")
  echo "Container ${container_name} status is ${container_status}"
  # 项目优化|必须保证-w的正确性
  if [[ "${container_status}" == "running" ]]; then
    echo "Checking $1 status"
    server_status=$(check_server_status "$1")
    echo "Server $1 status is ${server_status}"
    if [[ "${server_status}" != "UP" ]]; then
      exit 9
    fi
  else
    exit 9
  fi
}

# 检测服务状态
function check_server_status() {
  actuator_port=$(get_actuator_port "$1")
  check_url="http://127.0.0.1:${actuator_port}/actuator/health"
  status="UNKNOWN"
  for ((i=1; i<=20; i++)); do
    data=$(curl -s -X GET "${check_url}" -H "Content-Type: application/vnd.spring-boot.actuator.v2+json;charset=UTF-8")
    if [[ -n "$data" ]]; then
      status=$(echo "$data" | jq '.status' | sed 's/\"//g')
    fi
    if [[ "$status" == "UP" ]]; then
      break
    fi
    sleep 5s
  done
  echo "${status}"
}

# 容器&服务状态
function status() {
  container_name="$1"
  container_status=$(docker inspect --format '{{.State.Status}}' "${container_name}")
  echo "Container ${container_name} status is ${container_status}"
  if [[ "${container_status}" == "running" ]]; then
    # 服务健康状态
    server_status=$(check_server_status "$1")
    echo "Server $1 status is ${server_status}"
    # 使用pgrep -f 可以进行进程全字符匹配
    pid=$(pgrep -f "$1.jar")
    if [[ -n "${pid}" ]]; then
      echo "Server $1 pid is ${pid}"
    fi
  fi
}

function deploy() {
  services=("gateway-server" "uc-server")
  for value in "${services[@]}"
  do
    if [[ $1 == "${value}" ]]; then
      stop "$1"
      transfer "$1"
      start "$1" "$2"
    fi
  done
}

function restart() {
  stop "$1"
  start "$1" "$2"
}

# 使用说明，用来提示输入参数
usage() {
  doc=$(cat <<- EOF
Usage: sh /path/xyz/dep-spring.sh <action> <service> [options]

Action         : action name, deploy|restart|stop|status
Service        : service name, gateway-server|uc-server

Options:
  env          : env, test|prod (default is test)
EOF
)
  echo "${doc}" && exit 1
}

# 根据输入参数，选择执行对应方法，不输入则执行使用说明
if [[ $# -ge 2 ]]; then
  case "$1" in
    "deploy")
      deploy "$2" "$3"
      ;;
    "restart")
      restart "$2" "$3"
      ;;
    "stop")
      stop "$2"
      ;;
    "status")
      status "$2"
      ;;
    *)
      usage
      ;;
  esac
else
  usage
fi