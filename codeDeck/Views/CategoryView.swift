//
//  CategoryView.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-26.
//

import SwiftUI

struct CategoryView: View {
    let category: Category
    let isExpanded: Bool
    let onToggle: () -> Void
    let onProblemTap: (Problem) -> Void
    
    
    var body: some View {
        VStack(spacing: 0) {
            categoryHeader
            
            if isExpanded {
                Divider()
                problemsList
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private var categoryHeader: some View {
        Button(action: onToggle) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    HStack(spacing: 8) {
                        Text("\(category.totalCount) problems")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if category.completedCount > 0 {
                            Text("• \(category.completedCount) completed")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                Spacer()
                
                HStack(spacing: 8) {
                    // Progress indicator
                    if category.completedCount > 0 {
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(category.completedCount) / CGFloat(category.totalCount))
                                .stroke(Color.green, lineWidth: 2)
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(-90))
                        }
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var problemsList: some View {
        VStack(spacing: 0) {
            ForEach(category.problems, id: \.id) { problem in
                Button(action: {
                    onProblemTap(problem)
                }) {
                    ProblemRowView(problem: problem)
                }
                .buttonStyle(PlainButtonStyle())

                if problem.id != category.problems.last?.id {
                    Divider()
                        .padding(.leading)
                }
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCategory = Category(
            id: "arrays-hashing",
            name: "Arrays & Hashing",
            problems: [
                Problem(id: "two-sum", title: "Two Sum", difficulty: .easy, status: .completed),
                Problem(id: "valid-anagram", title: "Valid Anagram", difficulty: .easy, status: .attempted),
                Problem(id: "contains-duplicate", title: "Contains Duplicate", difficulty: .easy)
            ]
        )
        
        VStack(spacing: 16) {
            CategoryView(
                category: sampleCategory,
                isExpanded: false,
                onToggle: {},
                onProblemTap: { _ in }
            )
            
            CategoryView(
                category: sampleCategory,
                isExpanded: true,
                onToggle: {},
                onProblemTap: { _ in }
            )
        }
        .padding()
        .background(Color(.systemGray6))
    }
}
