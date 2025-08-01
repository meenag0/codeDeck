//
//  ProblemStatus.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-23.
//

import Foundation
import SwiftUI

enum ProblemStatus: String, CaseIterable, Codable {
    case completed = "Completed"
    case attempted = "Attempted"
    case bookmarked = "Bookmarked"
    
    var color: Color {
        switch self {
        case .completed:
            return .green
        case .attempted:
            return .orange
        case .bookmarked:
            return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .completed: 
            return "checkmark.circle.fill"
        case .attempted: 
            return "clock.circle.fill"
        case .bookmarked: 
            return "bookmark.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .completed:
            return "Completed"
        case .attempted:
            return "Attempted"
        case .bookmarked:
            return "Bookmarked"
        }
    }
    
    
}
