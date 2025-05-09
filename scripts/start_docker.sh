#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===== QuizTest Docker 环境启动脚本 =====${NC}"

# 检查 Docker 是否安装
if ! docker --version > /dev/null 2>&1; then
  echo -e "${RED}Docker 未安装或未在PATH中。请安装Docker后重试。${NC}"
  exit 1
fi

# 检查 Docker Compose 是否安装
if ! docker compose version > /dev/null 2>&1; then
  echo -e "${RED}Docker Compose 未安装或未在PATH中。请安装Docker Compose后重试。${NC}"
  exit 1
fi

# 切换到项目根目录
cd "$(dirname "$0")/.." || exit

echo -e "${YELLOW}正在启动 Docker 容器...${NC}"

# 启动 Docker 容器
docker compose up -d

# 检查是否成功启动
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Docker 容器已成功启动√${NC}"
  
  # 显示正在运行的容器
  echo -e "${YELLOW}正在运行的容器:${NC}"
  docker compose ps
  
  echo -e "${GREEN}===== 服务访问信息 =====${NC}"
  echo -e "Web应用: ${YELLOW}http://localhost${NC}"
  echo -e "API端点: ${YELLOW}http://localhost/api${NC}"
  echo -e "数据库服务(从主机访问):"
  echo -e "  - MySQL: ${YELLOW}localhost:13306${NC}"
  echo -e "  - MongoDB: ${YELLOW}localhost:27018${NC}"
  echo -e "  - Redis: ${YELLOW}localhost:16379${NC}"
  
  echo -e "${RED}使用以下命令停止所有服务:${NC}"
  echo -e "${YELLOW}docker compose down${NC}"
else
  echo -e "${RED}Docker 容器启动失败。请检查错误信息。${NC}"
  exit 1
fi 