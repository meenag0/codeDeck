//
//  CodeCheckResult.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-08-17.
//

import Foundation

struct CodeCheckResult {
    let isCorrect: Bool
    let feedback: String
    let suggestions: [String]
    let errors: [String]
    let executionOutput: String?
}

struct CodeCheckRequest: Codable {
    let problem: ProblemData
    let userCode: String
}

struct ProblemData: Codable {
    let title: String
    let description: String?
    let example: String?
    let difficulty: String
    
    init(from problem: Problem) {
        self.title = problem.title
        self.description = problem.description
        self.example = problem.example
        self.difficulty = problem.difficulty.rawValue
    }
}
