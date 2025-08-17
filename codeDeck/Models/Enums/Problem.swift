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
    var status: ProblemStatus?
    let description: String?
    let example: String?
    let solution: String?
    let timeComplexity: String?
    let spaceComplexity: String?
    
    init(
        id: String,
        title: String,
        difficulty: Difficulty,
        status: ProblemStatus? = nil,
        description: String? = nil,
        example: String? = nil,
        solution: String? = nil,
        timeComplexity: String? = nil,
        spaceComplexity: String? = nil
    ) {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.status = status
        self.description = description
        self.example = example
        self.solution = solution
        self.timeComplexity = timeComplexity
        self.spaceComplexity = spaceComplexity
    }
}
