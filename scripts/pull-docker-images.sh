#!/bin/bash
# 预先拉取项目所需的Docker镜像
# 这可以显著减少首次构建时间

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 输出带颜色的信息
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    error "Docker未运行，请先启动Docker"
fi

info "=== 开始拉取项目所需的Docker镜像 ==="

# 定义需要拉取的镜像
IMAGES=(
  "maven:3.9-amazoncorretto-17"
  "amazoncorretto:17-alpine"
  "node:18-alpine"
  "nginx:alpine"
  "mysql:8.0"
  "mongo:7.0"
  "redis:8.0"
  "nginx:1.21"
)

# 拉取镜像
for IMAGE in "${IMAGES[@]}"; do
  info "正在拉取 $IMAGE..."
  docker pull $IMAGE
  if [ $? -ne 0 ]; then
    warn "拉取 $IMAGE 失败，可能需要手动拉取"
  else
    info "$IMAGE 拉取成功"
  fi
done

info "=== 所有镜像拉取完成 ==="
info "这将显著减少首次构建时间" 