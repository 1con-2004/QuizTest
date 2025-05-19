#!/bin/bash
# 部署到Docker脚本
# 将本地开发环境同步到Docker环境

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

# 清理未使用的Docker卷
cleanup_volumes() {
    info "清理未使用的Docker卷..."
    UNUSED_VOLUMES=$(docker volume ls -qf "dangling=true")
    if [ -n "$UNUSED_VOLUMES" ]; then
        echo "$UNUSED_VOLUMES" | xargs docker volume rm
        info "已删除 $(echo "$UNUSED_VOLUMES" | wc -l | tr -d ' ') 个未使用的卷"
    else
        info "没有未使用的卷需要清理"
    fi
}

# 检查环境文件
check_env_file() {
    if [ ! -f ".env" ]; then
        warn "未找到.env文件，将从.env.example复制一份"
        if [ -f ".env.example" ]; then
            cp .env.example .env
            info "已复制.env.example为.env，请检查并修改其中的配置"
        else
            error "未找到.env.example文件，请手动创建.env文件"
        fi
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

# 检查工作目录
if [ ! -f "docker-compose.yml" ]; then
  error "请在项目根目录运行此脚本"
fi

# 检查.env文件
check_env_file

info "=== 开始部署到Docker环境 ==="

# 1. 构建后端生产环境代码
info "构建后端代码..."
(cd backend && mvn clean package -DskipTests) 
if [ $? -ne 0 ]; then
    error "后端构建失败，请检查错误信息并修复问题后重试"
fi

# 2. 构建前端生产环境代码
info "构建前端代码..."
(cd frontend && pnpm build) 
if [ $? -ne 0 ]; then
    error "前端构建失败，请检查错误信息并修复问题后重试"
fi

# 3. 导出MySQL数据库
info "导出本地MySQL数据..."
MYSQL_DUMP_FILE="./docker/mysql-dump.sql"
# 从.env文件读取MySQL配置
if [ -f ".env" ]; then
    source <(grep -E "^DB_MYSQL_" .env | sed 's/^/export /')
fi
LOCAL_MYSQL_PASSWORD=${DB_MYSQL_PASSWORD:-"root"}
LOCAL_MYSQL_DB=${DB_MYSQL_DATABASE:-"quiztest"}
LOCAL_MYSQL_USER=${DB_MYSQL_USERNAME:-"root"}
LOCAL_MYSQL_HOST=${DB_MYSQL_HOST:-"localhost"}
LOCAL_MYSQL_PORT=${DB_MYSQL_PORT:-"3306"}

if command -v mysqldump &> /dev/null; then
  info "使用配置: 主机=${LOCAL_MYSQL_HOST}, 端口=${LOCAL_MYSQL_PORT}, 用户=${LOCAL_MYSQL_USER}, 数据库=${LOCAL_MYSQL_DB}"
  mysqldump -h "$LOCAL_MYSQL_HOST" -P "$LOCAL_MYSQL_PORT" -u "$LOCAL_MYSQL_USER" -p"$LOCAL_MYSQL_PASSWORD" "$LOCAL_MYSQL_DB" > "$MYSQL_DUMP_FILE" 2>/dev/null
  if [ $? -ne 0 ]; then
    warn "MySQL导出失败，可能需要手动导出数据"
    touch "$MYSQL_DUMP_FILE"  # 创建空文件避免后续错误
  else
    info "MySQL数据导出成功: $MYSQL_DUMP_FILE"
  fi
else
  warn "未找到mysqldump命令，请手动导出数据"
  touch "$MYSQL_DUMP_FILE"  # 创建空文件避免后续错误
fi

# 4. 导出MongoDB数据库（如需要）
info "导出本地MongoDB数据..."
MONGO_DUMP_DIR="./docker/mongo-dump"
mkdir -p "$MONGO_DUMP_DIR"

# 从.env文件读取MongoDB配置
if [ -f ".env" ]; then
    source <(grep -E "^DB_MONGODB_" .env | sed 's/^/export /')
fi
LOCAL_MONGODB_HOST=${DB_MONGODB_HOST:-"localhost"}
LOCAL_MONGODB_PORT=${DB_MONGODB_PORT:-"27017"}
LOCAL_MONGODB_DB=${DB_MONGODB_DATABASE:-"quiztest"}

if command -v mongodump &> /dev/null; then
  info "使用配置: 主机=${LOCAL_MONGODB_HOST}, 端口=${LOCAL_MONGODB_PORT}, 数据库=${LOCAL_MONGODB_DB}"
  mongodump --host "$LOCAL_MONGODB_HOST" --port "$LOCAL_MONGODB_PORT" --db "$LOCAL_MONGODB_DB" --out="$MONGO_DUMP_DIR" 2>/dev/null
  if [ $? -ne 0 ]; then
    warn "MongoDB导出失败，可能需要手动导出数据"
    mkdir -p "$MONGO_DUMP_DIR/$LOCAL_MONGODB_DB"  # 创建空目录避免后续错误
  else
    info "MongoDB数据导出成功: $MONGO_DUMP_DIR"
  fi
else
  warn "未找到mongodump命令，请手动导出数据"
  mkdir -p "$MONGO_DUMP_DIR/$LOCAL_MONGODB_DB"  # 创建空目录避免后续错误
fi

# 5. 添加MySQL导入脚本
info "创建数据库导入脚本..."
cat > ./docker/mysql-init.sh << EOF
#!/bin/bash
echo "等待MySQL启动..."
sleep 10
echo "开始导入数据..."
mysql -u root -proot quiztest < /docker-entrypoint-initdb.d/mysql-dump.sql 2>/dev/null || echo "MySQL数据导入失败或没有数据需要导入"
echo "MySQL初始化完成"
EOF
chmod +x ./docker/mysql-init.sh

# 6. 添加MongoDB导入脚本
cat > ./docker/mongo-init.sh << EOF
#!/bin/bash
echo "等待MongoDB启动..."
sleep 10
echo "开始导入数据..."
if [ -d "/docker-entrypoint-initdb.d/mongo-dump/quiztest" ] && [ "\$(ls -A /docker-entrypoint-initdb.d/mongo-dump/quiztest 2>/dev/null)" ]; then
  mongorestore /docker-entrypoint-initdb.d/mongo-dump 2>/dev/null || echo "MongoDB数据导入失败"
  echo "MongoDB数据导入完成"
else
  echo "没有MongoDB数据需要导入"
fi
echo "MongoDB初始化完成"
EOF
chmod +x ./docker/mongo-init.sh

# 7. 构建和启动Docker容器
info "构建和启动Docker容器..."
docker compose down || warn "关闭现有容器时出现警告（如果是首次运行可忽略）"

# 使用--parallel并保留缓存来加速构建
info "使用并行构建和缓存加速Docker构建..."
docker compose build --parallel || error "构建Docker镜像失败"

info "启动Docker容器..."
docker compose up -d || error "启动Docker容器失败"

# 等待服务启动
info "等待服务启动..."
sleep 5

# 检查容器状态
info "检查容器状态..."
CONTAINERS=$(docker compose ps --services)
for CONTAINER in $CONTAINERS; do
  STATUS=$(docker compose ps $CONTAINER --format "{{.State}}")
  if [[ "$STATUS" != "running" ]]; then
    warn "容器 $CONTAINER 状态异常: $STATUS"
    docker compose logs $CONTAINER | tail -n 20
  else
    info "容器 $CONTAINER 运行正常"
  fi
done

# 清理未使用的Docker卷
cleanup_volumes

info "=== Docker环境部署完成 ==="
info "Web应用: http://localhost"
info "API端点: http://localhost/api"
info "Spring Boot 服务: http://localhost:3000/api"
info "数据库服务(从主机访问):"
info "  - MySQL: localhost:${DOCKER_MYSQL_PORT:-13306}"
info "  - MongoDB: localhost:${DOCKER_MONGODB_PORT:-27018}"
info "  - Redis: localhost:${DOCKER_REDIS_PORT:-16379}" 