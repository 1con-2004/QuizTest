/**
 * API 配置文件
 */

// 从环境变量获取API基础URL
export const API_BASE_URL = import.meta.env.VITE_API_URL || '/api';

// API请求超时时间(毫秒)
export const API_TIMEOUT = 10000;

// API请求头
export const API_HEADERS = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
}; 