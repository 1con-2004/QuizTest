package com.quiztest.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@Configuration
@EnableMongoRepositories(basePackages = "com.quiztest.repository.mongo")
public class MongoDBConfig {
    // MongoDB特定配置
} 