//
//  FilterButton.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-26.
//


import SwiftUI

struct FilterButton: View {
    @Binding var selectedDifficulties: Set<Difficulty>
    @Binding var selectedStatuses: Set<ProblemStatus>
    @State private var showingFilterSheet = false
    
    var body: some View {
        Button(action: {
            showingFilterSheet = true
        }) {
            Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .foregroundColor(.green)
                .font(.title2)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(
                selectedDifficulties: $selectedDifficulties,
                selectedStatuses: $selectedStatuses
            )
        }
    }
    
    private var hasActiveFilters: Bool {
        !selectedDifficulties.isEmpty || !selectedStatuses.isEmpty
    }
}

struct FilterSheet: View {
    @Binding var selectedDifficulties: Set<Difficulty>
    @Binding var selectedStatuses: Set<ProblemStatus>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Difficulty Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Difficulty")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            DifficultyFilterChip(
                                difficulty: difficulty,
                                isSelected: selectedDifficulties.contains(difficulty),
                                onTap: {
                                    toggleDifficulty(difficulty)
                                }
                            )
                        }
                    }
                }
                
                // Status Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(ProblemStatus.allCases, id: \.self) { status in
                            StatusFilterChip(
                                status: status,
                                isSelected: selectedStatuses.contains(status),
                                onTap: {
                                    toggleStatus(status)
                                }
                            )
                        }
                    }
                }
                
                Spacer()
                
                // Clear All Button
                if hasActiveFilters {
                    Button("Clear All Filters") {
                        selectedDifficulties.removeAll()
                        selectedStatuses.removeAll()
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .navigationTitle("Filter Problems")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        !selectedDifficulties.isEmpty || !selectedStatuses.isEmpty
    }
    
    private func toggleDifficulty(_ difficulty: Difficulty) {
        if selectedDifficulties.contains(difficulty) {
            selectedDifficulties.remove(difficulty)
        } else {
            selectedDifficulties.insert(difficulty)
        }
    }
    
    private func toggleStatus(_ status: ProblemStatus) {
        if selectedStatuses.contains(status) {
            selectedStatuses.remove(status)
        } else {
            selectedStatuses.insert(status)
        }
    }
}

// MARK: - Filter Chips
struct DifficultyFilterChip: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(difficulty.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? difficulty.color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : difficulty.color)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusFilterChip: View {
    let status: ProblemStatus
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: status.icon)
                    .font(.caption)
                
                Text(status.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? status.color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : status.color)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct FilterButton_Previews: PreviewProvider {
    static var previews: some View {
        FilterButton(
            selectedDifficulties: .constant([]),
            selectedStatuses: .constant([])
        )
    }
}
