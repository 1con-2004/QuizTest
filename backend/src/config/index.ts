import dotenv from 'dotenv';
import path from 'path';

// 加载环境变量
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT ? parseInt(process.env.PORT, 10) : 3000,
  database: {
    mysql: process.env.DATABASE_URL || 'mysql://root:root@localhost:3306/quiztest',
    mongodb: process.env.MONGODB_URI || 'mongodb://localhost:27017/quiztest',
  },
  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'quiztest-secret-key',
    expiresIn: '7d',
  },
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
  },
}; 