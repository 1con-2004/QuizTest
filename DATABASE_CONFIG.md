# 数据库配置指南

本文档介绍如何配置 QuizTest 项目的数据库连接。

## 环境变量配置

QuizTest 项目使用 `.env` 文件管理所有数据库连接信息和其他环境变量。这种方式允许每个开发人员在本地使用自己的数据库配置，而不需要修改代码。

### 设置步骤

1. 复制 `.env.example` 为 `.env`：
   ```bash
   cp .env.example .env
   ```

2. 编辑 `.env` 文件，修改为你的本地环境配置：
   ```properties
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

### 环境变量详解

#### MySQL 配置

```properties
# MySQL基本配置
DB_MYSQL_HOST=localhost       # MySQL主机地址
DB_MYSQL_PORT=3306            # MySQL端口
DB_MYSQL_USERNAME=root        # MySQL用户名
DB_MYSQL_PASSWORD=password    # MySQL密码
DB_MYSQL_DATABASE=quiztest    # MySQL数据库名

# 构建的MySQL连接URL (不需要手动修改)
DATABASE_URL=mysql://${DB_MYSQL_USERNAME}:${DB_MYSQL_PASSWORD}@${DB_MYSQL_HOST}:${DB_MYSQL_PORT}/${DB_MYSQL_DATABASE}
```

#### MongoDB 配置

```properties
# MongoDB基本配置
DB_MONGODB_HOST=localhost     # MongoDB主机地址
DB_MONGODB_PORT=27017         # MongoDB端口
DB_MONGODB_DATABASE=quiztest  # MongoDB数据库名

# 构建的MongoDB连接URL (不需要手动修改)
MONGODB_URI=mongodb://${DB_MONGODB_HOST}:${DB_MONGODB_PORT}/${DB_MONGODB_DATABASE}
```

#### Redis 配置

```properties
# Redis基本配置
REDIS_HOST=localhost          # Redis主机地址
REDIS_PORT=6379               # Redis端口

# 构建的Redis连接URL (不需要手动修改)
REDIS_URL=redis://${REDIS_HOST}:${REDIS_PORT}
```

#### Docker 环境配置

```properties
# MySQL Docker配置 
DOCKER_MYSQL_ROOT_PASSWORD=root  # Docker中MySQL的root密码
DOCKER_MYSQL_DATABASE=quiztest    # Docker中MySQL的数据库名
DOCKER_MYSQL_PORT=13306           # MySQL映射到主机的端口

# MongoDB Docker配置
DOCKER_MONGODB_PORT=27018         # MongoDB映射到主机的端口

# Redis Docker配置
DOCKER_REDIS_PORT=16379           # Redis映射到主机的端口
```

## 特殊情况

### 1. 使用现有数据库

如果你需要连接到已经存在的数据库，而不是修改单独的配置项，可以直接设置连接URL：

```properties
# 直接设置连接URL
DATABASE_URL=mysql://用户名:密码@主机:端口/数据库名
MONGODB_URI=mongodb://主机:端口/数据库名
REDIS_URL=redis://主机:端口
```

### 2. 使用环境变量优先级

配置系统会按照以下优先级使用配置：

1. 完整的连接URL (`DATABASE_URL`, `MONGODB_URI`, `REDIS_URL`)
2. 分解的配置项 (`DB_MYSQL_HOST` 等)
3. 默认值

## 注意事项

1. `.env` 文件包含敏感信息，已添加到 `.gitignore`，不会被提交到版本控制系统
2. 每个团队成员应该根据自己的本地环境创建自己的 `.env` 文件
3. 修改环境变量后需要重启服务才能生效
4. Docker 开发环境会使用 `.env` 文件中的 Docker 相关配置

## 项目使用的库和ORM

### MySQL
- 使用`mysql2`库直接连接MySQL
- 不使用任何ORM（已移除Prisma）

### MongoDB
- 使用`mongoose`作为MongoDB的ORM
- 模型定义位于`backend/src/models/mongoose/`目录

### Redis
- 使用`redis`库连接Redis

## 如何验证配置是否正确

运行项目，检查日志中是否有数据库连接错误。你也可以访问以下测试API端点验证所有数据库连接：

```
GET http://localhost:3000/api/test-db
```

此API会测试MySQL、MongoDB和Redis的连接并返回结果。

## 配置中的注意事项

1. 安全性：
   - 生产环境中应更改默认密码
   - 考虑限制数据库的网络访问
   - 不要在代码仓库中提交包含真实密码的`.env`文件

2. 性能：
   - MongoDB和Redis默认配置通常适用于开发环境
   - 生产环境可能需要调整内存使用、连接数等参数

3. 数据持久化：
   - 确保配置了适当的备份策略
   - Redis默认使用RDB和AOF进行数据持久化

## 常见问题排查

1. MySQL连接错误：
   - 确认MySQL服务已启动
   - 验证用户名和密码是否正确
   - 检查数据库名称（包括大小写）是否正确
   - 确认端口号（默认3306）是否正确

2. MongoDB连接错误：
   - 确认MongoDB服务已启动
   - 检查MongoDB版本是否兼容
   - 验证连接字符串格式是否正确

3. Redis连接错误：
   - 确认Redis服务已启动
   - 检查端口号（默认6379）是否正确
   - 验证是否设置了密码 