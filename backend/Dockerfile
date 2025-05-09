# 使用Node.js镜像
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 安装pnpm
RUN npm install -g pnpm

# 首先复制 package.json 和 pnpm-lock.yaml 以利用缓存层
COPY package.json pnpm-lock.yaml* ./

# 安装依赖，但不复制源代码
RUN pnpm install

# 然后复制源代码
COPY . .

# 设置环境变量
ENV NODE_ENV=development

# 暴露端口
EXPOSE 3000

# 使用开发模式启动应用
CMD ["pnpm", "dev"] 