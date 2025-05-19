#!/bin/bash
# 前端修复脚本 - 用于解决常见的前端问题

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

# 检查工作目录
if [ ! -d "frontend" ]; then
  error "请在项目根目录运行此脚本"
fi

info "=== 开始修复前端问题 ==="

# 进入前端目录
cd frontend

# 检查是否安装pnpm
if ! command -v pnpm &> /dev/null; then
  warn "未找到pnpm命令，尝试安装..."
  npm install -g pnpm || error "pnpm安装失败，请手动安装: npm install -g pnpm"
  info "pnpm已安装"
fi

# 安装依赖
info "重新安装依赖..."
pnpm install || error "依赖安装失败"

# 检查axios版本
AXIOS_VERSION=$(grep "axios" package.json | head -1 | awk -F'"' '{print $4}')
info "当前axios版本: $AXIOS_VERSION"

if [[ $(echo "$AXIOS_VERSION" | cut -d. -f1) -lt 1 ]]; then
  warn "检测到较旧的axios版本，尝试更新..."
  pnpm add axios@latest
  info "已更新axios到最新版本"
  
  # 修复axios类型问题
  info "更新axios类型定义..."
  
  # 检查http.ts文件
  if [ -f "src/api/http.ts" ]; then
    info "修复src/api/http.ts中的类型定义..."
    sed -i '' 's/AxiosRequestConfig/InternalAxiosRequestConfig/g' src/api/http.ts || warn "自动修复失败，可能需要手动修复"
    grep -q "InternalAxiosRequestConfig" src/api/http.ts || warn "未找到InternalAxiosRequestConfig导入，请手动添加"
  fi
fi

# 检查类型错误
info "检查TypeScript类型错误..."
pnpm exec tsc --noEmit

if [ $? -ne 0 ]; then
  warn "发现TypeScript类型错误，尝试修复常见问题..."
  
  # 常见的类型错误修复
  find src -name "*.ts" -o -name "*.tsx" | xargs grep -l "AxiosRequestConfig" | while read file; do
    info "修复文件: $file"
    sed -i '' 's/AxiosRequestConfig/InternalAxiosRequestConfig/g' "$file"
    grep -q "InternalAxiosRequestConfig" "$file" || sed -i '' 's/import axios, { AxiosInstance/import axios, { AxiosInstance, InternalAxiosRequestConfig/g' "$file"
  done
  
  # 重新检查
  info "重新检查类型错误..."
  pnpm exec tsc --noEmit
  
  if [ $? -ne 0 ]; then
    warn "仍然存在类型错误，可能需要手动修复"
  else
    info "类型错误已修复"
  fi
else
  info "没有发现类型错误"
fi

# 尝试构建
info "尝试构建前端项目..."
pnpm build

if [ $? -ne 0 ]; then
  error "构建失败，请手动检查错误并修复"
else
  info "构建成功!"
fi

info "=== 前端问题修复完成 ===" 