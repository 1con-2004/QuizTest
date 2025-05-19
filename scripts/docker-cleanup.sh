#!/bin/bash

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

# 确认函数
confirm() {
    read -p "是否继续? (y/n): " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        info "操作已取消"
        exit 0
    fi
}

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    error "Docker未运行，请先启动Docker"
    
    # 根据不同操作系统给出启动Docker的提示
    case "$(uname -s)" in
        Darwin)
            echo -e "${YELLOW}请启动Docker Desktop应用程序。${NC}"
            echo -e "${YELLOW}您可以通过以下方式启动：${NC}"
            echo -e "1. 在应用程序文件夹中打开Docker.app"
            echo -e "2. 或在终端中运行: open -a Docker"
            ;;
        Linux)
            echo -e "${YELLOW}请启动Docker服务：${NC}"
            echo -e "sudo systemctl start docker"
            ;;
        *)
            echo -e "${YELLOW}请确保Docker服务已启动。${NC}"
            ;;
    esac
    exit 1
fi

echo "=========================="
echo "    Docker 清理工具       "
echo "=========================="
echo ""
echo "此脚本将帮助您清理Docker环境中的未使用资源"
echo "请选择要执行的操作:"
echo ""
echo "1) 清理所有未使用的卷"
echo "2) 清理所有未使用的镜像"
echo "3) 清理所有停止的容器"
echo "4) 清理所有未使用的网络"
echo "5) 全面清理(谨慎使用)"
echo "6) 停止并移除所有当前项目容器"
echo "7) 退出"
echo ""
read -p "请输入选项 [1-7]: " option

case $option in
    1)
        info "准备清理所有未使用的Docker卷..."
        docker volume ls
        echo ""
        warn "此操作将删除所有未被容器使用的卷，数据将无法恢复!"
        confirm
        
        UNUSED_VOLUMES=$(docker volume ls -qf "dangling=true")
        if [ -n "$UNUSED_VOLUMES" ]; then
            echo "$UNUSED_VOLUMES" | xargs docker volume rm
            info "已删除 $(echo "$UNUSED_VOLUMES" | wc -l | tr -d ' ') 个未使用的卷"
        else
            info "没有未使用的卷需要清理"
        fi
        ;;
    2)
        info "准备清理所有未使用的Docker镜像..."
        docker images
        echo ""
        warn "此操作将删除所有未被容器使用的镜像!"
        confirm
        
        docker image prune -af
        info "已清理未使用的镜像"
        ;;
    3)
        info "准备清理所有停止的容器..."
        docker ps -a
        echo ""
        warn "此操作将删除所有已停止的容器!"
        confirm
        
        docker container prune -f
        info "已清理停止的容器"
        ;;
    4)
        info "准备清理所有未使用的网络..."
        docker network ls
        echo ""
        warn "此操作将删除所有未被容器使用的网络!"
        confirm
        
        docker network prune -f
        info "已清理未使用的网络"
        ;;
    5)
        info "准备执行全面清理..."
        echo ""
        warn "此操作将清理所有未使用的卷、镜像、容器和网络，数据将无法恢复!"
        warn "请确保您已备份重要数据!"
        confirm
        
        info "正在清理停止的容器..."
        docker container prune -f
        
        info "正在清理未使用的镜像..."
        docker image prune -af
        
        info "正在清理未使用的卷..."
        docker volume prune -f
        
        info "正在清理未使用的网络..."
        docker network prune -f
        
        info "全面清理完成"
        ;;
    6)
        info "准备停止并移除当前项目的所有容器..."
        docker compose ps
        echo ""
        warn "此操作将停止并移除当前项目的所有容器!"
        confirm
        
        docker compose down
        info "已停止并移除当前项目的所有容器"
        ;;
    7)
        info "退出清理工具"
        exit 0
        ;;
    *)
        error "无效的选项: $option"
        ;;
esac

info "Docker清理完成" 