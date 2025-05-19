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

## 环境变量配置

本项目使用 `.env` 文件管理所有环境变量，包括数据库连接信息。项目中包含一个 `.env.example` 示例文件，团队成员可以基于此创建自己的 `.env` 文件。

### 环境变量设置步骤

1. 复制 `.env.example` 为 `.env`：
   ```bash
   cp .env.example .env
   ```

2. 编辑 `.env` 文件，修改为你的本地环境配置：
   ```bash
   # 主要修改以下内容：
   DB_MYSQL_HOST=localhost
   DB_MYSQL_PORT=3306
   DB_MYSQL_USERNAME=root
   DB_MYSQL_PASSWORD=your_password  # 修改为你的MySQL密码
   
   DB_MONGODB_HOST=localhost
   DB_MONGODB_PORT=27017
   
   REDIS_HOST=localhost
   REDIS_PORT=6379
   ```

3. 如果使用Docker环境，可以修改Docker相关配置：
   ```bash
   DOCKER_MYSQL_PORT=13306  # 修改为你想要映射的端口
   DOCKER_MONGODB_PORT=27018
   DOCKER_REDIS_PORT=16379
   ```

### 环境变量说明

- **MySQL配置**：
  - `DB_MYSQL_HOST`, `DB_MYSQL_PORT`, `DB_MYSQL_USERNAME`, `DB_MYSQL_PASSWORD`, `DB_MYSQL_DATABASE`：MySQL连接信息
  - `DATABASE_URL`：由上述参数构建的MySQL连接URL

- **MongoDB配置**：
  - `DB_MONGODB_HOST`, `DB_MONGODB_PORT`, `DB_MONGODB_DATABASE`：MongoDB连接信息
  - `MONGODB_URI`：由上述参数构建的MongoDB连接URL

- **Redis配置**：
  - `REDIS_HOST`, `REDIS_PORT`：Redis连接信息
  - `REDIS_URL`：由上述参数构建的Redis连接URL

- **Docker环境配置**：
  - `DOCKER_MYSQL_ROOT_PASSWORD`, `DOCKER_MYSQL_DATABASE`, `DOCKER_MYSQL_PORT`：Docker中MySQL的配置
  - `DOCKER_MONGODB_PORT`：Docker中MongoDB映射端口
  - `DOCKER_REDIS_PORT`：Docker中Redis映射端口

### 注意事项

- `.env` 文件包含敏感信息，已添加到 `.gitignore`，不会被提交到版本控制系统
- 团队成员应该基于 `.env.example` 创建自己的 `.env` 文件
- 如果对环境变量进行了修改，需要重启服务才能生效

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
- MongoDB 7.0
- Redis 8.0

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

完成本地开发和测试后，有多种方式将应用部署到Docker环境：

##### 方式1: 完整部署 (包含数据迁移)

此脚本将执行完整的部署流程，包括编译代码、导出数据库数据、构建Docker镜像等：

```bash
./scripts/deploy-to-docker.sh
```

这个脚本将：
1. 构建前端生产代码
2. 导出本地数据库数据
3. 配置Docker环境
4. 启动所有Docker容器

**注意**：首次运行可能需要花费较长时间（5-10分钟），因为需要下载Docker镜像并构建应用。

##### 方式2: 快速启动 (仅启动容器)

如果你只需要启动Docker环境而不需要重新编译和数据迁移：

```bash
./scripts/quick-docker.sh
```

这个脚本会检测代码变更并选择性地重新构建服务，通常只需1-2分钟即可完成启动。

##### 方式3: 预加载Docker镜像

如果你是首次使用Docker，可以先预加载所需的基础镜像，这将大大加快首次构建速度：

```bash
./scripts/pull-docker-images.sh
```

这个脚本会预先拉取项目所需的所有基础Docker镜像，建议在首次部署前运行。

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

### Docker 构建太慢怎么办?

Docker 构建过程可能会较慢，特别是在首次构建时。以下是一些提高构建速度的方法：

1. **使用预加载脚本**：
   ```bash
   ./scripts/pull-docker-images.sh  # 预先拉取所有基础镜像
   ```

2. **使用快速启动脚本**：
   ```bash
   ./scripts/quick-docker.sh  # 仅当代码有变更时才重新构建
   ```

3. **利用构建缓存**：
   - 避免使用 `--no-cache` 参数
   - 合理组织 Dockerfile，将不常变更的层放在前面

4. **只构建需要的服务**：
   ```bash
   docker-compose build <服务名>  # 只构建特定服务
   ```

5. **清理不必要的镜像和容器**：
   ```bash
   docker system prune -a  # 清理所有未使用的镜像、容器和网络
   ```

### 遇到部署问题怎么办?

我们提供了几个问题排查和修复脚本：

1. **前端构建失败**: 
   ```bash
   # 修复前端常见问题（包括axios类型错误等）
   ./scripts/fix-frontend.sh
   ```

2. **数据库连接问题**:
   ```bash
   # 检查数据库配置
   ./backend/src/main/java/com/quiztest/util/DBConnectionTest.java
   ```

3. **Docker环境问题**:
   ```bash
   # 查看容器状态
   docker-compose ps
   
   # 查看容器日志
   docker-compose logs <服务名>
   
   # 重建并启动所有容器
   docker-compose down -v
   docker-compose up -d
   ```

### 常见错误及解决方案

#### 1. 前端构建错误

**错误信息**: `AxiosRequestConfig` 类型错误
```
Type 'AxiosRequestConfig<any>' is not assignable to type 'InternalAxiosRequestConfig<any>'
```

**解决方案**:
- 运行 `./scripts/fix-frontend.sh` 自动修复
- 或手动将 `AxiosRequestConfig` 修改为 `InternalAxiosRequestConfig`

#### 2. 数据库连接错误

**错误信息**: `无法连接到数据库` 或 `Authentication failed`

**解决方案**:
- 检查 `.env` 文件中的数据库配置是否正确
- 确认数据库服务是否正在运行
- 验证数据库用户名和密码

#### 3. Docker环境崩溃

**错误信息**: `容器启动失败` 或 `服务无法访问`

**解决方案**:
- 查看日志: `docker-compose logs <服务名>`
- 检查端口冲突: `netstat -tulpn | grep <端口号>`
- 重建环境: `docker-compose down -v && docker-compose up -d`

#### 4. Docker构建超时或过慢

**错误信息**: 构建过程花费过长时间（超过10分钟）

**解决方案**:
- 使用快速启动脚本: `./scripts/quick-docker.sh`
- 预先拉取镜像: `./scripts/pull-docker-images.sh` 
- 检查网络连接，确保可以正常访问Docker Hub
- 清理Docker缓存: `docker system prune -a`
