import { Request, Response, NextFunction } from 'express';
import { config } from '../config';

// 自定义错误类
export class AppError extends Error {
  statusCode: number;
  isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

// 错误处理中间件
export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // 默认值
  let statusCode = 500;
  let message = '服务器内部错误';
  let stack = undefined;

  // 如果是自定义操作错误
  if (err instanceof AppError) {
    statusCode = err.statusCode;
    message = err.message;
  }

  // 开发环境下返回错误堆栈
  if (config.env === 'development') {
    stack = err.stack;
  }

  // 返回错误响应
  res.status(statusCode).json({
    code: statusCode,
    message,
    stack,
    data: null,
  });
}; 