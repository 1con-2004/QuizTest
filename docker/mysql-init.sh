#!/bin/bash
echo "等待MySQL启动..."
sleep 10
echo "开始导入数据..."
mysql -u root -proot quiztest < /docker-entrypoint-initdb.d/mysql-dump.sql 2>/dev/null || echo "MySQL数据导入失败或没有数据需要导入"
echo "MySQL初始化完成"
