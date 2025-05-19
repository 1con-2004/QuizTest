#!/bin/bash
# 快速启动Docker容器脚本
# 支持前端变更自动检测和重建

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

# 帮助信息
show_help() {
  echo "用法: $0 [选项]"
  echo ""
  echo "选项:"
  echo "  -h, --help                显示帮助信息"
  echo "  -f, --frontend-only       只重建前端"
  echo "  -b, --backend-only        只重建后端"
  echo "  -a, --all                 重建所有服务"
  echo "  --force-rebuild-frontend  强制重建前端并更新Nginx"
  echo ""
  echo "示例:"
  echo "  $0                  使用自动检测启动所有服务"
  echo "  $0 --frontend-only  只重建前端服务"
  echo "  $0 --force-rebuild-frontend  强制重建前端并更新Nginx"
  exit 0
}

# 检查Docker是否运行
check_docker() {
  if ! docker info > /dev/null 2>&1; then
    error "Docker未运行，请先启动Docker"
  fi
}

# 检查工作目录
check_workdir() {
  if [ ! -f "docker-compose.yml" ]; then
    error "请在项目根目录运行此脚本"
  fi
}

# 检查是否有变化的文件需要重新构建
check_rebuild() {
  local service_name=$1
  local rebuild=false
  
  case $service_name in
    backend)
      # 查找任何时间内被修改的Java文件
      if [[ -n $(find ./backend -type f -name "*.java" -o -name "*.xml" -newer ./backend/target/classes 2>/dev/null) ]]; then
        info "检测到后端文件有变化，将重建backend服务"
        rebuild=true
      fi
      ;;
    frontend)
      # 查找任何时间内被修改的前端文件
      if [[ -n $(find ./frontend/src -type f -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -newer ./frontend/node_modules/.cache 2>/dev/null) ]]; then
        info "检测到前端文件有变化，将重建frontend服务"
        rebuild=true
      fi
      ;;
  esac
  
  echo $rebuild
}

# 启动所有服务，根据需要重建指定服务
start_services() {
  local rebuild_backend=$1
  local rebuild_frontend=$2
  
  info "启动Docker容器..."

  if [[ "$rebuild_backend" == "true" && "$rebuild_frontend" == "true" ]]; then
    info "重新构建所有服务..."
    docker-compose up -d --build
  elif [[ "$rebuild_backend" == "true" ]]; then
    info "只重建后端服务..."
    docker-compose up -d --build backend
    docker-compose up -d
  elif [[ "$rebuild_frontend" == "true" ]]; then
    info "只重建前端服务..."
    docker-compose up -d --build frontend
    docker-compose up -d
  else
    info "使用缓存直接启动所有服务..."
    docker-compose up -d
  fi
}

# 强制重建前端并更新Nginx
force_rebuild_frontend() {
  info "=== 强制重建前端开始 ==="
  
  # 停止并删除前端和Nginx容器
  info "停止前端和Nginx容器..."
  docker-compose stop frontend nginx
  
  # 移除容器（确保卷可以被删除）
  info "移除容器..."
  docker-compose rm -f frontend nginx
  
  # 删除旧的构建卷
  info "删除旧的构建卷..."
  docker volume rm quiztest_frontend_build || true
  
  # 清理前端构建缓存
  info "清理前端构建缓存..."
  rm -rf frontend/node_modules/.cache frontend/dist || true
  
  # 强制创建新的卷
  info "创建新的构建卷..."
  docker volume create quiztest_frontend_build
  
  # 重新构建并启动前端
  info "重建前端容器..."
  docker-compose build --no-cache frontend
  docker-compose up -d frontend
  
  # 等待前端构建完成
  info "等待前端构建完成..."
  sleep 10
  
  # 启动Nginx
  info "启动Nginx容器..."
  docker-compose up -d nginx
  
  # 显示提示消息
  info "=== 前端重建完成 ==="
  info "请使用 Ctrl+F5 或 Command+Shift+R 强制刷新浏览器缓存以查看更新"
}

# 检查容器状态
check_status() {
  info "检查容器状态..."
  CONTAINERS=$(docker-compose ps --services)
  for CONTAINER in $CONTAINERS; do
    STATUS=$(docker-compose ps $CONTAINER --format "{{.State}}")
    if [[ "$STATUS" != "running" ]]; then
      warn "容器 $CONTAINER 状态异常: $STATUS"
      docker-compose logs $CONTAINER | tail -n 20
    else
      info "容器 $CONTAINER 运行正常"
    fi
  done
}

# 主函数
main() {
  check_docker
  check_workdir
  
  # 解析命令行参数
  FRONTEND_ONLY=false
  BACKEND_ONLY=false
  FORCE_REBUILD_FRONTEND=false
  REBUILD_ALL=false
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        ;;
      -f|--frontend-only)
        FRONTEND_ONLY=true
        shift
        ;;
      -b|--backend-only)
        BACKEND_ONLY=true
        shift
        ;;
      -a|--all)
        REBUILD_ALL=true
        shift
        ;;
      --force-rebuild-frontend)
        FORCE_REBUILD_FRONTEND=true
        shift
        ;;
      *)
        warn "未知选项: $1"
        show_help
        ;;
    esac
  done
  
  info "=== 快速启动Docker环境 ==="
  
  if [[ "$FORCE_REBUILD_FRONTEND" == "true" ]]; then
    force_rebuild_frontend
    check_status
    info "Web应用: http://localhost"
    info "API端点: http://localhost/api"
    info "前端已强制重建，请清除浏览器缓存后访问网站查看更新效果"
    info "可以使用以下命令查看日志："
    info "  docker-compose logs -f <服务名>"
    exit 0
  elif [[ "$FRONTEND_ONLY" == "true" ]]; then
    info "只重建前端服务 (使用强制重建逻辑)..."
    force_rebuild_frontend
    check_status
    info "Web应用: http://localhost"
    info "API端点: http://localhost/api"
    info "前端已强制重建，请清除浏览器缓存后访问网站查看更新效果"
    info "可以使用以下命令查看日志："
    info "  docker-compose logs -f <服务名>"
    exit 0
  fi
  
  # 根据命令行参数或自动检测决定是否重建服务
  if [[ "$REBUILD_ALL" == "true" ]]; then
    rebuild_backend=true
    rebuild_frontend=true
  elif [[ "$FRONTEND_ONLY" == "true" ]]; then
    rebuild_backend=false
    rebuild_frontend=true
  elif [[ "$BACKEND_ONLY" == "true" ]]; then
    rebuild_backend=true
    rebuild_frontend=false
  else
    # 自动检测是否需要重建
    rebuild_backend=$(check_rebuild "backend")
    rebuild_frontend=$(check_rebuild "frontend")
  fi
  
  # 启动所有服务
  start_services "$rebuild_backend" "$rebuild_frontend"
  
  # 如果重建了前端，确保Nginx也获取到最新的构建文件
  if [[ "$rebuild_frontend" == "true" ]]; then
    info "重启Nginx以获取最新的前端文件..."
    docker-compose restart nginx
  fi
  
  # 等待服务启动
  info "等待服务启动..."
  sleep 5
  
  # 检查容器状态
  check_status
  
  info "=== Docker环境启动完成 ==="
  info "Web应用: http://localhost"
  info "API端点: http://localhost/api"
  if [[ "$rebuild_frontend" == "true" ]]; then
    info "前端已重建，请清除浏览器缓存后访问网站查看更新效果"
  fi
  info "可以使用以下命令查看日志："
  info "  docker-compose logs -f <服务名>"
}

# 执行主函数
main "$@" 