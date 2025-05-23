package com.quiztest.model.entity.mongo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "quizzes")
public class Quiz {
    @Id
    private String id;
    
    private String title;
    
    private String description;
    
    private List<Question> questions;
    
    private String createdBy;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    private boolean isPublic;
} 