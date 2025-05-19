/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  // 可以在此处添加更多环境变量类型
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
} 