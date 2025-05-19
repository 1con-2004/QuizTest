import dotenv from 'dotenv';
import path from 'path';

// 加载环境变量
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

// 构建MySQL连接URL
const buildMySQLUrl = (): string => {
  const host = process.env.DB_MYSQL_HOST || 'localhost';
  const port = process.env.DB_MYSQL_PORT || '3306';
  const username = process.env.DB_MYSQL_USERNAME || 'root';
  const password = process.env.DB_MYSQL_PASSWORD || 'root';
  const database = process.env.DB_MYSQL_DATABASE || 'quiztest';
  
  return process.env.DATABASE_URL || `mysql://${username}:${password}@${host}:${port}/${database}`;
};

// 构建MongoDB连接URL
const buildMongoDBUrl = (): string => {
  const host = process.env.DB_MONGODB_HOST || 'localhost';
  const port = process.env.DB_MONGODB_PORT || '27017';
  const database = process.env.DB_MONGODB_DATABASE || 'quiztest';
  
  return process.env.MONGODB_URI || `mongodb://${host}:${port}/${database}`;
};

// 构建Redis连接URL
const buildRedisUrl = (): string => {
  const host = process.env.REDIS_HOST || 'localhost';
  const port = process.env.REDIS_PORT || '6379';
  
  return process.env.REDIS_URL || `redis://${host}:${port}`;
};

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT ? parseInt(process.env.PORT, 10) : 3000,
  database: {
    mysql: buildMySQLUrl(),
    mongodb: buildMongoDBUrl(),
  },
  redis: {
    url: buildRedisUrl(),
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'quiztest-secret-key',
    expiresIn: '7d',
  },
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
  },
}; 