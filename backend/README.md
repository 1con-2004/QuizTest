# QuizTest 后端项目

## 目录结构

```
backend/
├── src/             # 源代码
│   ├── controllers/ # 控制器，处理请求
│   ├── models/      # 数据模型
│   ├── routes/      # 路由定义
│   ├── services/    # 业务逻辑
│   ├── utils/       # 工具函数
│   ├── config/      # 配置文件
│   └── middlewares/ # 中间件
├── public/          # 静态资源
└── package.json     # 依赖管理
```

## 技术栈

- 运行环境：Node.js 18+
- 框架：Express
- 语言：TypeScript
- 数据库：MySQL + MongoDB
- 缓存：Redis
- ORM：Mongoose (MongoDB)
- 身份验证：JWT
- API文档：Swagger/OpenAPI
- 日志：Winston

## 本地开发

```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev

# 构建生产版本
pnpm build

# 启动生产版本
pnpm start
```

## 模块开发指南

### 新增API路由

1. 在`src/routes`中添加新的路由文件
2. 在`src/controllers`中添加对应的控制器
3. 在`src/services`中实现业务逻辑
4. 更新API文档

### 数据库模型

1. MySQL数据库通过原生查询或第三方ORM访问
2. MongoDB模型在`src/models/mongoose`中定义
3. 模型命名采用单数形式（如`User`而非`Users`）

### 中间件

1. 全局中间件在`src/app.ts`中注册
2. 路由级中间件在路由文件中注册
3. 自定义中间件在`src/middlewares`中实现

### 错误处理

1. 使用统一的错误处理中间件
2. 遵循API响应格式规范
3. 区分开发环境和生产环境的错误信息

## 环境变量

主要环境变量：

- `NODE_ENV`：环境（development/production）
- `PORT`：服务端口
- `DATABASE_URL`：MySQL数据库连接字符串
- `MONGODB_URI`：MongoDB连接字符串
- `REDIS_URL`：Redis连接字符串
- `JWT_SECRET`：JWT密钥

## 部署

### Docker

```bash
# 构建镜像
docker build -t quiztest-backend .

# 运行容器
docker run -p 3000:3000 quiztest-backend
```

### Docker Compose

使用项目根目录的`docker-compose.yml`进行编排部署。

## 代码规范

- 遵循项目根目录下的`CONTRIBUTING.md`规范
- 使用ESLint和Prettier进行代码格式化
- 使用TypeScript类型系统确保类型安全 