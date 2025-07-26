//
//  Problem.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-23.
//

import Foundation

struct Problem: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let difficulty: Difficulty  
    let status: ProblemStatus?
    let description: String?
    let hints: [String]?
    
    init(
        id: String,
        title: String,
        difficulty: Difficulty,
        status: ProblemStatus? = nil,
        description: String? = nil,
        hints: [String]? = nil            
    ) {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.status = status
        self.description = description
        self.hints = hints
    }
}
