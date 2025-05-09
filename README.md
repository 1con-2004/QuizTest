# QuizTest - AI面试模拟平台

QuizTest是一个使用React和Node.js构建的AI面试模拟平台，它同时支持本地开发和Docker容器化部署。

## 项目结构

```
QuizTest
  ├── backend/           # Node.js后端代码
  ├── frontend/          # React前端代码
  ├── docker/            # Docker相关配置和数据
  ├── nginx/             # Nginx配置文件
  ├── scripts/           # 工作流脚本
  └── ...
```

## 工作流程

本项目采用"本地开发 -> Docker部署"的工作流：

1. **本地开发**: 开发人员在本地环境进行开发和测试，可直接访问本地数据库
2. **Docker部署**: 开发完成后，将代码和数据同步到Docker环境中运行

## 开发说明

### 1. 本地开发环境

#### 1.1 环境要求

- Node.js 16+
- PNPM 7+
- MySQL 8.0
- MongoDB 6.0
- Redis 7.0

#### 1.2 启动本地开发环境

```bash
# 确保本地的MySQL, MongoDB和Redis服务已经启动
# 然后运行:
./scripts/start-local-dev.sh
```

这将启动：
- 前端开发服务器: http://localhost:5173
- 后端API服务器: http://localhost:3000

#### 1.3 本地数据库连接信息

**MySQL**:
- 主机: localhost
- 端口: 3306
- 用户名: root
- 密码: root
- 数据库名: quiztest
- 连接URL: `mysql://root:root@localhost:3306/quiztest`

**MongoDB**:
- 主机: localhost
- 端口: 27017
- 数据库名: quiztest
- 连接URL: `mongodb://localhost:27017/quiztest`

**Redis**:
- 主机: localhost
- 端口: 6379
- 连接URL: `redis://localhost:6379`

### 2. Docker部署环境

#### 2.1 环境要求

- Docker
- Docker Compose

#### 2.2 部署到Docker

完成本地开发和测试后，可以使用以下命令将应用部署到Docker环境：

```bash
./scripts/deploy-to-docker.sh
```

这个脚本将：
1. 构建前端生产代码
2. 导出本地数据库数据
3. 配置Docker环境
4. 启动所有Docker容器

或者，如果你只需要启动Docker环境而不需要同步本地数据，可以使用：

```bash
./scripts/start_docker.sh
```

#### 2.3 Docker环境访问方式

部署完成后，可以通过以下方式访问应用：
- Web应用: http://localhost
- 所有API请求会通过Nginx反向代理自动路由到后端服务

#### 2.4 Docker环境中的数据库连接信息

**MySQL**:
- 主机: localhost (从主机访问) 或 mysql (从容器内部访问)
- 端口: 13306 (从主机访问) 或 3306 (从容器内部访问)
- 用户名: root
- 密码: root
- 数据库名: quiztest
- 外部连接URL: `mysql://root:root@localhost:13306/quiztest`
- 容器间连接URL: `mysql://root:root@mysql:3306/quiztest`

**MongoDB**:
- 主机: localhost (从主机访问) 或 mongodb (从容器内部访问)
- 端口: 27018 (从主机访问) 或 27017 (从容器内部访问)
- 数据库名: quiztest
- 外部连接URL: `mongodb://localhost:27018/quiztest`
- 容器间连接URL: `mongodb://mongodb:27017/quiztest`

**Redis**:
- 主机: localhost (从主机访问) 或 redis (从容器内部访问)
- 端口: 16379 (从主机访问) 或 6379 (从容器内部访问)
- 外部连接URL: `redis://localhost:16379`
- 容器间连接URL: `redis://redis:6379`

## 初学者指南：如何连接数据库

### MySQL连接指南

**使用命令行**:
```bash
# 本地环境
mysql -u root -proot quiztest

# Docker环境 (从主机连接)
mysql -u root -proot -h localhost -P 13306 quiztest
```

**使用GUI工具** (如MySQL Workbench):
1. 点击"添加连接"
2. 填写连接信息:
   - 连接名称: QuizTest本地/Docker
   - 连接方法: 标准TCP/IP
   - 主机名: localhost
   - 端口: 3306 (本地) 或 13306 (Docker)
   - 用户名: root
   - 密码: root
   - 默认数据库: quiztest

### MongoDB连接指南

**使用命令行**:
```bash
# 本地环境
mongosh "mongodb://localhost:27017/quiztest"

# Docker环境 (从主机连接)
mongosh "mongodb://localhost:27018/quiztest"
```

**使用GUI工具** (如MongoDB Compass):
1. 点击"New Connection"
2. 在URI字段中输入:
   - 本地环境: `mongodb://localhost:27017/quiztest`
   - Docker环境: `mongodb://localhost:27018/quiztest`
3. 点击"Connect"

### Redis连接指南

**使用命令行**:
```bash
# 本地环境
redis-cli

# Docker环境 (从主机连接)
redis-cli -h localhost -p 16379
```

**使用GUI工具** (如RedisInsight):
1. 点击"添加Redis数据库"
2. 选择"手动添加"
3. 填写连接信息:
   - 主机: localhost
   - 端口: 6379 (本地) 或 16379 (Docker)
   - 名称: QuizTest本地/Docker
4. 点击"添加Redis数据库"

## 常见问题

### 如何重置Docker环境?

```bash
docker-compose down -v  # 删除所有容器和卷
./scripts/deploy-to-docker.sh  # 重新部署
```

### 如何仅重启特定服务?

```bash
docker-compose restart <服务名>  # 例如: docker-compose restart backend
```

### 如何查看Docker容器日志?

```bash
docker-compose logs -f <服务名>  # 例如: docker-compose logs -f backend
```
