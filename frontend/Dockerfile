# 构建阶段
FROM node:18-alpine AS build

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

# 构建应用
RUN pnpm build

# 运行阶段
FROM nginx:alpine

# 从构建阶段复制构建结果到nginx目录
COPY --from=build /app/dist /usr/share/nginx/html

# 复制nginx配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露80端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"] 