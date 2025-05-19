package com.quiztest;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@SpringBootApplication
@EnableMongoRepositories(basePackages = "com.quiztest.repository.mongo")
public class QuizTestApplication {

    public static void main(String[] args) {
        SpringApplication.run(QuizTestApplication.class, args);
    }
} 