//
//  Difficulty.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-23.
//

import Foundation
import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy:
            return .green
        case .medium:
            return .yellow
        case .hard:
            return .red
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .easy:
            return 0
        case .medium:
            return 1
        case .hard:
            return 2
        }
    }
}
