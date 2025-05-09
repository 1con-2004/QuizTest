#!/bin/bash
echo "等待MySQL启动..."
sleep 10
echo "开始导入数据..."
mysql -u root -proot quiztest < /docker-entrypoint-initdb.d/mysql-dump.sql
echo "数据导入完成"
