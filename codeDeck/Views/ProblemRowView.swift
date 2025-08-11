//
//  ProblemRowView.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-26.
//

//
//  ProblemRowView.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-26.
//

import SwiftUI

struct ProblemRowView: View {
    let problem: Problem
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator dot
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(problem.title)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(problem.difficulty.rawValue)
                    .font(.caption)
                    .foregroundColor(problem.difficulty.color)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Status badge (if problem has a status)
            if let status = problem.status {
                HStack(spacing: 4) {
                    Image(systemName: status.icon)
                        .font(.caption2)
                    
                    Text(status.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(status.color.opacity(0.15))
                .foregroundColor(status.color)
                .cornerRadius(8)
            }
        }
        .padding()
        .contentShape(Rectangle()) // Makes entire row tappable
    }
    
    // MARK: - Computed Properties
    private var statusColor: Color {
        // If problem has no status, show gray dot
        guard let status = problem.status else {
            return Color(.systemGray4)
        }
        
        // Otherwise use the status color
        return status.color
    }
}

// MARK: - Preview
struct ProblemRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            // Completed problem
            ProblemRowView(
                problem: Problem(
                    id: "1",
                    title: "Two Sum",
                    difficulty: .easy,
                    status: .completed
                )
            )
            
            Divider()
            
            // Attempted problem
            ProblemRowView(
                problem: Problem(
                    id: "2",
                    title: "Longest Substring Without Repeating Characters",
                    difficulty: .medium,
                    status: .attempted
                )
            )
            
            Divider()
            
            // Bookmarked problem
            ProblemRowView(
                problem: Problem(
                    id: "3",
                    title: "Median of Two Sorted Arrays",
                    difficulty: .hard,
                )
            )
            
            Divider()
            
            // Problem with no status
            ProblemRowView(
                problem: Problem(
                    id: "4",
                    title: "Valid Palindrome",
                    difficulty: .easy
                )
            )
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding()
    }
}
