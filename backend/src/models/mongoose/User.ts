import mongoose, { Document, Schema } from 'mongoose';

// 用户接口定义
export interface IUser extends Document {
  username: string;
  email: string;
  password: string;
  role: string;
  createdAt: Date;
  updatedAt: Date;
}

// 用户模式定义
const UserSchema: Schema = new Schema(
  {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: true,
      select: false, // 默认查询不返回密码
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
  },
  {
    timestamps: true, // 自动添加 createdAt 和 updatedAt
  }
);

// 创建并导出模型
export const User = mongoose.model<IUser>('User', UserSchema); 