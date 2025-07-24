//
//  Problem.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-23.
//

import Foundation

struct Problem: Codable, Identifiable, Hashable {
    let id: String              // Unique identifier (required for Identifiable)
    let title: String           // Problem name like "Two Sum"
    let difficulty: Difficulty  // Uses our Difficulty enum
    let status: ProblemStatus?  // Uses our ProblemStatus enum (optional!)
    let description: String?    // Full problem description (optional)
    let hints: [String]?        // Array of hint strings (optional)
    
    init(
        id: String,
        title: String,
        difficulty: Difficulty,
        status: ProblemStatus? = nil,      // Default to no status
        description: String? = nil,        // Default to no description
        hints: [String]? = nil            // Default to no hints
    ) {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.status = status
        self.description = description
        self.hints = hints
    }
}
