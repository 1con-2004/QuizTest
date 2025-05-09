#!/bin/bash
# 本地开发环境启动脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 显示带颜色的消息
echo_info() {
  echo -e "${GREEN}[INFO] $1${NC}"
}

echo_warn() {
  echo -e "${YELLOW}[WARN] $1${NC}"
}

echo_error() {
  echo -e "${RED}[ERROR] $1${NC}"
}

# 检查工作目录
if [ ! -f "pnpm-workspace.yaml" ]; then
  echo_error "请在项目根目录运行此脚本"
  exit 1
fi

# 检查前端和后端目录是否存在
if [ ! -d "frontend" ]; then
  echo_error "前端目录不存在，请确保frontend目录在项目根目录中"
  exit 1
fi

if [ ! -d "backend" ]; then
  echo_error "后端目录不存在，请确保backend目录在项目根目录中"
  exit 1
fi

# 检查各种数据库是否已启动
check_mysql() {
  echo_info "检查MySQL服务..."
  if command -v mysql &> /dev/null; then
    if mysql -u root -proot -e "SELECT 1" &> /dev/null; then
      echo_info "MySQL服务正常运行"
      return 0
    else
      echo_warn "MySQL服务未运行或无法连接，请确保已启动MySQL服务"
      return 1
    fi
  else
    echo_warn "未找到mysql命令，请确保已安装MySQL客户端"
    return 1
  fi
}

check_mongodb() {
  echo_info "检查MongoDB服务..."
  if command -v mongosh &> /dev/null; then
    if mongosh --eval "db.adminCommand('ping')" &> /dev/null; then
      echo_info "MongoDB服务正常运行"
      return 0
    else
      echo_warn "MongoDB服务未运行或无法连接，请确保已启动MongoDB服务"
      return 1
    fi
  else
    echo_warn "未找到mongosh命令，请确保已安装MongoDB客户端"
    return 1
  fi
}

check_redis() {
  echo_info "检查Redis服务..."
  if command -v redis-cli &> /dev/null; then
    if redis-cli ping &> /dev/null; then
      echo_info "Redis服务正常运行"
      return 0
    else
      echo_warn "Redis服务未运行或无法连接，请确保已启动Redis服务"
      return 1
    fi
  else
    echo_warn "未找到redis-cli命令，请确保已安装Redis客户端"
    return 1
  fi
}

# 启动应用
start_app() {
  echo_info "安装依赖..."
  pnpm install

  # 确保进程不存在
  pkill -f "pnpm dev" || true
  sleep 1

  # 启动后端
  echo_info "启动后端服务..."
  if ! cd backend; then
    echo_error "无法进入后端目录，请检查权限或目录是否存在"
    exit 1
  fi
  pnpm dev &
  backend_pid=$!
  cd ..

  # 启动前端
  echo_info "启动前端服务..."
  if ! cd frontend; then
    echo_error "无法进入前端目录，请检查权限或目录是否存在"
    exit 1
  fi
  pnpm dev &
  frontend_pid=$!
  cd ..

  echo_info "===================================="
  echo_info "本地开发环境已启动"
  echo_info "前端服务: http://localhost:5173"
  echo_info "后端服务: http://localhost:3000"
  echo_info "===================================="
  echo_info "按 Ctrl+C 停止所有服务"

  # 等待用户按下Ctrl+C
  trap "kill $backend_pid $frontend_pid 2>/dev/null" INT
  wait
}

# 主流程
echo_info "=== 开始启动本地开发环境 ==="

# 检查数据库服务
check_mysql
check_mongodb
check_redis

# 启动应用
start_app 