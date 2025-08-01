//
//  Category.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-23.
//

import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: String           // unique identifier like "arrays-hashing"
    let name: String         // display name like "Arrays & Hashing"
    let problems: [Problem]  // array of problems in this category
    
    var completedCount: Int {
        problems.filter { $0.status == .completed }.count
    }
    
    var totalCount: Int {
        problems.count
    }
}
