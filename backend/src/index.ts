import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import helmet from 'helmet';
import { config } from './config';
import { errorHandler } from './middlewares/errorHandler';
import { apiRoutes } from './routes';
import { connectMongoDB, testMySQLConnection, connectRedis } from './models';

// 初始化数据库连接
const initializeDatabase = async () => {
  try {
    await connectMongoDB();
    await testMySQLConnection();
    await connectRedis();
    console.log('所有数据库连接成功，启动服务...');
    startServer();
  } catch (error) {
    console.error('数据库连接失败:', error);
    process.exit(1);
  }
};

// 创建Express应用
const app = express();

// 配置中间件
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

// 静态文件
app.use(express.static('public'));

// API路由
app.use('/api', apiRoutes);

// 首页路由
app.get('/', (req, res) => {
  res.json({
    message: 'QuizTest API 服务已启动',
    status: 'success',
    version: '0.1.0',
  });
});

// 404处理
app.use((req, res) => {
  res.status(404).json({
    code: 404,
    message: '接口不存在',
    data: null,
  });
});

// 错误处理中间件
app.use(errorHandler);

// 启动服务器
const startServer = () => {
  const PORT = config.port || 3000;
  app.listen(PORT, () => {
    console.log(`服务已启动，运行在 http://localhost:${PORT}`);
  });
};

// 启动应用
initializeDatabase();