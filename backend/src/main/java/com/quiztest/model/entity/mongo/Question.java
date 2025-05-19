package com.quiztest.model.entity.mongo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Question {
    private String id;
    
    private String text;
    
    private String type;
    
    private List<Answer> answers;
    
    private Integer points;
    
    private String explanation;
} 