#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===== QuizTest Docker 环境启动脚本 =====${NC}"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
  echo -e "${RED}Docker 未安装或未在PATH中。请安装Docker后重试。${NC}"
  exit 1
fi

# 检查 Docker 是否在运行
if ! docker info &> /dev/null; then
  echo -e "${RED}Docker 守护进程未运行。${NC}"
  
  # 根据不同操作系统给出启动Docker的提示
  case "$(uname -s)" in
    Darwin)
      echo -e "${YELLOW}请启动Docker Desktop应用程序。${NC}"
      echo -e "${YELLOW}您可以通过以下方式启动：${NC}"
      echo -e "1. 在应用程序文件夹中打开Docker.app"
      echo -e "2. 或在终端中运行: open -a Docker"
      if [ -f "/Applications/Docker.app/Contents/MacOS/Docker" ]; then
        echo -e "${GREEN}尝试自动启动Docker...${NC}"
        open -a Docker
        echo -e "${YELLOW}正在等待Docker启动，这可能需要一点时间...${NC}"
        for i in {1..30}; do
          sleep 2
          if docker info &> /dev/null; then
            echo -e "${GREEN}Docker已成功启动！${NC}"
            break
          fi
          if [ $i -eq 30 ]; then
            echo -e "${RED}等待Docker启动超时，请手动检查Docker状态。${NC}"
            exit 1
          fi
        done
      fi
      ;;
    Linux)
      echo -e "${YELLOW}请启动Docker服务：${NC}"
      echo -e "sudo systemctl start docker"
      ;;
    *)
      echo -e "${YELLOW}请确保Docker服务已启动。${NC}"
      ;;
  esac
fi

# 检查 Docker Compose 是否安装
if ! docker compose version &> /dev/null; then
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
  echo -e "Spring Boot 服务: ${YELLOW}http://localhost:3000/api${NC}"
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