package com.quiztest.model.entity.mongo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Answer {
    private String id;
    
    private String text;
    
    private boolean isCorrect;
} 