package com.quiztest.config;

import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackages = "com.quiztest.repository.mysql")
@EntityScan(basePackages = "com.quiztest.model.entity.mysql")
public class MySQLConfig {
    // MySQL特定配置
} 