# QuizTest 前端项目

## 目录结构

```
frontend/
├── public/          # 静态资源
├── src/             # 源代码
│   ├── components/  # 公共组件
│   ├── pages/       # 页面组件
│   ├── api/         # API调用
│   ├── hooks/       # 自定义Hooks
│   ├── assets/      # 资源文件
│   ├── utils/       # 工具函数
│   ├── styles/      # 样式文件
│   └── config/      # 配置文件
└── package.json     # 依赖管理
```

## 技术栈

- 框架：React 18
- 语言：TypeScript
- 状态管理：React Context API + useReducer
- 路由：React Router v6
- UI组件库：Ant Design
- 样式：CSS Modules + SCSS
- HTTP客户端：Axios
- 构建工具：Vite

## 本地开发

```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev

# 构建生产版本
pnpm build

# 预览生产版本
pnpm preview
```

## 模块开发指南

### 新增页面

1. 在`src/pages`下创建对应的页面目录，如`Login`
2. 创建页面组件、相关样式和测试
3. 在路由配置中添加新页面

### 新增组件

1. 在`src/components`下创建组件目录，如`Button`
2. 组件结构建议：
   - `index.tsx`：组件入口
   - `Button.tsx`：组件实现
   - `Button.module.scss`：组件样式
   - `Button.test.tsx`：组件测试
   - `types.ts`：类型定义（如需）
   - `README.md`：组件说明（可选）

### API调用

1. 在`src/api`下按模块创建API调用文件
2. 使用Axios实例进行封装
3. 处理请求拦截和响应拦截

### 状态管理

1. 全局状态在`src/context`中管理
2. 按功能模块拆分Context
3. 使用useReducer管理复杂状态

## 代码规范

- 遵循项目根目录下的`CONTRIBUTING.md`规范
- 使用ESLint和Prettier进行代码格式化
- 组件使用函数式组件和Hooks
- 充分利用TypeScript类型系统 