import mongoose from 'mongoose';
import { config } from '../config';
import mysql from 'mysql2/promise';
import { createClient } from 'redis';

// MongoDB连接
export const connectMongoDB = async (): Promise<void> => {
  try {
    await mongoose.connect(config.database.mongodb);
    console.log('MongoDB 连接成功');
  } catch (error) {
    console.error('MongoDB 连接失败:', error);
    process.exit(1);
  }
};

// MySQL连接池
export const mysqlPool = mysql.createPool(config.database.mysql);

// 测试MySQL连接
export const testMySQLConnection = async (): Promise<void> => {
  try {
    const connection = await mysqlPool.getConnection();
    console.log('MySQL 连接成功');
    connection.release();
  } catch (error) {
    console.error('MySQL 连接失败:', error);
    process.exit(1);
  }
};

// Redis客户端
export const redisClient = createClient({
  url: config.redis.url
});

// 测试Redis连接
export const connectRedis = async (): Promise<void> => {
  try {
    await redisClient.connect();
    console.log('Redis 连接成功');
  } catch (error) {
    console.error('Redis 连接失败:', error);
    process.exit(1);
  }
};

// 导出MongoDB模型
export * from './mongoose/User'; 