# 项目开发规范

## 基本准则

1. 所有团队成员必须遵循本文档中的规范
2. 每位成员负责自己模块的全栈开发，包括前端UI和后端API
3. 使用Cursor和GitHub进行开发和协作

## 分支管理

- `main`: 主分支，只接受经过测试的稳定版本
- `dev`: 开发分支，所有功能开发完成后合并到该分支
- `feature/xxx`: 功能分支，用于开发具体功能
- `hotfix/xxx`: 热修复分支，用于修复线上bug

## 提交规范

提交信息格式：`[类型]: 简短描述`

类型包括：
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档变更
- `style`: 代码格式调整
- `refactor`: 代码重构
- `perf`: 性能优化
- `test`: 测试相关
- `build`: 构建系统或外部依赖变更
- `ci`: CI配置变更
- `chore`: 其他修改

示例：`feat: 添加用户登录功能`

## 代码风格

### JavaScript/TypeScript

- 使用ESLint + Prettier进行代码格式化
- 缩进使用2个空格
- 使用分号结束语句
- 优先使用const和let，避免使用var
- 优先使用箭头函数
- 使用TypeScript类型注解

### CSS

- 使用CSS Modules或styled-components
- 命名采用kebab-case（如`header-container`）
- 避免使用!important

### 文件命名

- 组件文件采用PascalCase（如`UserProfile.tsx`）
- 工具函数文件采用camelCase（如`formatDate.ts`）
- 样式文件与组件同名（如`UserProfile.module.css`）

## 模块开发流程

1. 在`feature`分支上进行开发
2. 前端代码放在`frontend/src/pages/模块名`目录下
3. 后端代码按MVC结构组织
4. 完成后提交PR到`dev`分支
5. PR必须经过至少一位团队成员的代码审查

## Docker开发规范

1. 所有服务必须容器化
2. 本地开发时优先使用热重载模式
3. 不同环境的配置通过环境变量控制
4. Docker镜像尽量轻量化，使用多阶段构建

## API规范

1. 遵循RESTful风格
2. 使用JSON格式交换数据
3. 统一的响应格式：
```json
{
  "code": 200,
  "message": "成功",
  "data": {}
}
```
4. 合理使用HTTP状态码

## 文档规范

1. 每个模块必须包含README.md，说明模块功能和使用方法
2. 对外接口必须有清晰的文档说明
3. 复杂逻辑必须添加注释

## 性能优化准则

1. 前端资源按需加载
2. 使用缓存减少重复请求
3. 图片等静态资源优化
4. 合理的数据库索引设计 