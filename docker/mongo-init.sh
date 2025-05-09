#!/bin/bash
echo "等待MongoDB启动..."
sleep 10
echo "开始导入数据..."
mongorestore /docker-entrypoint-initdb.d/mongo-dump
echo "数据导入完成"
