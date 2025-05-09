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

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    error "Docker未运行，请先启动Docker"
fi

# 检查工作目录
if [ ! -f "docker-compose.yml" ]; then
  error "请在项目根目录运行此脚本"
fi

info "=== 开始部署到Docker环境 ==="

# 1. 构建前端生产环境代码
info "构建前端代码..."
(cd frontend && pnpm build) || error "前端构建失败"

# 2. 导出MySQL数据库
info "导出本地MySQL数据..."
MYSQL_DUMP_FILE="./docker/mysql-dump.sql"
LOCAL_MYSQL_PASSWORD="root" # 根据实际情况修改
LOCAL_MYSQL_DB="quiztest"   # 根据实际情况修改

if command -v mysqldump &> /dev/null; then
  mysqldump -u root -p"$LOCAL_MYSQL_PASSWORD" "$LOCAL_MYSQL_DB" > "$MYSQL_DUMP_FILE"
  if [ $? -ne 0 ]; then
    warn "MySQL导出失败，可能需要手动导出数据"
  fi
else
  warn "未找到mysqldump命令，请手动导出数据"
fi

# 3. 导出MongoDB数据库（如需要）
info "导出本地MongoDB数据..."
MONGO_DUMP_DIR="./docker/mongo-dump"
mkdir -p "$MONGO_DUMP_DIR"

if command -v mongodump &> /dev/null; then
  mongodump --out="$MONGO_DUMP_DIR" --db=quiztest
  if [ $? -ne 0 ]; then
    warn "MongoDB导出失败，可能需要手动导出数据"
  fi
else
  warn "未找到mongodump命令，请手动导出数据"
fi

# 4. 添加MySQL导入脚本
info "创建数据库导入脚本..."
cat > ./docker/mysql-init.sh << EOF
#!/bin/bash
echo "等待MySQL启动..."
sleep 10
echo "开始导入数据..."
mysql -u root -proot quiztest < /docker-entrypoint-initdb.d/mysql-dump.sql
echo "数据导入完成"
EOF
chmod +x ./docker/mysql-init.sh

# 5. 添加MongoDB导入脚本
cat > ./docker/mongo-init.sh << EOF
#!/bin/bash
echo "等待MongoDB启动..."
sleep 10
echo "开始导入数据..."
mongorestore /docker-entrypoint-initdb.d/mongo-dump
echo "数据导入完成"
EOF
chmod +x ./docker/mongo-init.sh

# 6. 构建和启动Docker容器
info "构建和启动Docker容器..."
docker-compose down || warn "关闭现有容器时出现警告（如果是首次运行可忽略）"
docker-compose build --no-cache || error "构建Docker镜像失败"
docker-compose up -d || error "启动Docker容器失败"

# 清理未使用的Docker卷
cleanup_volumes

info "=== Docker环境部署完成 ==="
info "Web应用: http://localhost"
info "API端点: http://localhost/api"
info "数据库服务(从主机访问):"
info "  - MySQL: localhost:13306"
info "  - MongoDB: localhost:27018"
info "  - Redis: localhost:16379" 