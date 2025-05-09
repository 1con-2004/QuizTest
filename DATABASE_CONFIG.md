# 数据库配置说明

本项目使用了三种数据库：MySQL、MongoDB和Redis。以下是关于如何配置和检查这些数据库的指南。

## MySQL 配置

### 当前配置
- 版本：8.0.39
- 连接URL：`mysql://root:root@localhost:3306/quiztest`
- 端口：3306
- 数据库名：quiztest（注意大小写）
- 用户名：root
- 密码：root

### 如何配置

1. 安装MySQL：
   - macOS: `brew install mysql`
   - Windows: 从[MySQL官网](https://dev.mysql.com/downloads/mysql/)下载安装程序

2. 启动MySQL服务：
   - macOS: `brew services start mysql`
   - Windows: 通过服务管理器或命令`net start mysql`

3. 创建数据库：
   ```sql
   CREATE DATABASE IF NOT EXISTS quiztest;
   ```

4. 修改配置（如果需要）：
   在项目根目录的`.env`文件中修改`DATABASE_URL`变量。

5. 检查连接：
   ```bash
   mysql -u root -p -e "SHOW DATABASES;" | grep quiztest
   ```

## MongoDB 配置

### 当前配置
- 版本：8.0.9
- 连接URI：`mongodb://localhost:27017/quiztest`
- 端口：27017
- 数据库名：quiztest

### 如何配置

1. 安装MongoDB：
   - macOS: `brew install mongodb-community`
   - Windows: 从[MongoDB官网](https://www.mongodb.com/try/download/community)下载安装程序

2. 启动MongoDB服务：
   - macOS: `brew services start mongodb-community`
   - Windows: 通过服务管理器或命令`net start MongoDB`

3. 修改配置（如果需要）：
   在项目根目录的`.env`文件中修改`MONGODB_URI`变量。

4. 检查连接：
   ```bash
   mongosh --eval "db.adminCommand('listDatabases')" | grep quiztest
   ```

## Redis 配置

### 当前配置
- 版本：7.2.7
- 连接URL：`redis://localhost:6379`
- 端口：6379

### 如何配置

1. 安装Redis：
   - macOS: `brew install redis`
   - Windows: 使用[Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install)或从[Redis官网](https://redis.io/download)下载

2. 启动Redis服务：
   - macOS: `brew services start redis`
   - Windows (WSL): `sudo service redis-server start`

3. 修改配置（如果需要）：
   在项目根目录的`.env`文件中修改`REDIS_URL`变量。

4. 检查连接：
   ```bash
   redis-cli ping
   ```
   如果返回`PONG`，则表示连接成功。

## Docker 配置

如果使用Docker运行项目，环境变量会被docker-compose.yml文件中的配置覆盖：

```yaml
# MySQL 配置
DATABASE_URL=mysql://root:password@mysql:3306/quiztest

# MongoDB 配置
MONGODB_URI=mongodb://mongodb:27017/quiztest

# Redis 配置
REDIS_URL=redis://redis:6379
```

注意Docker环境中的主机名使用的是服务名（如`mysql`、`mongodb`和`redis`），而不是`localhost`。

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