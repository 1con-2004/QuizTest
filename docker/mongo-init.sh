#!/bin/bash
echo "等待MongoDB启动..."
sleep 10
echo "开始导入数据..."
if [ -d "/docker-entrypoint-initdb.d/mongo-dump/quiztest" ] && [ "$(ls -A /docker-entrypoint-initdb.d/mongo-dump/quiztest 2>/dev/null)" ]; then
  mongorestore /docker-entrypoint-initdb.d/mongo-dump 2>/dev/null || echo "MongoDB数据导入失败"
  echo "MongoDB数据导入完成"
else
  echo "没有MongoDB数据需要导入"
fi
echo "MongoDB初始化完成"
