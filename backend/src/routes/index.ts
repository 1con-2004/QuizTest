import { Router } from 'express';

const router = Router();

// 欢迎接口
router.get('/', (req, res) => {
  res.json({
    code: 200,
    message: '欢迎使用 QuizTest API',
    data: {
      version: '0.1.0',
      apiPrefix: '/api',
    },
  });
});

// 导出API路由
export const apiRoutes = router; 