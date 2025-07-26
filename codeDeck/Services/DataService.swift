//
//  Data.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-26.
//

import Foundation
import Combine


// response structure for api calls

struct apiResponse: Codable {
    let Categories: [Category]
}

// for mock data

protocol DataServiceProtocol {
    func loadCategories() -> AnyPublisher<[Category], Error>
    func updateProblemStatus(problemId: String, status: ProblemStatus) -> AnyPublisher<Void, Error>
}

class DataService: DataServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let baseURL = "https://your-api.com/api/v1"
    
    // default init -> using real NetworkManager
    init() {
        self.networkManager = NetworkManager.shared
    }
    
    // custom init -> for mock NetworkManager
    init(networkManager: NetworkManagerProtocol){
        self.networkManager = networkManager
    }
    
    func loadCategories() -> AnyPublisher<[Category], Error> {
        return Just(mockCategories())
            .setFailureType(to: Error.self)              // Allow for errors (even though mock won't fail)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main) // simulate network delay
            .eraseToAnyPublisher()
    }
    
    func updateProblemStatus(problemId: String, status: ProblemStatus) -> AnyPublisher<Void, Error> {
        return Just(())  // () means "nothing" - just success
            .setFailureType(to: Error.self)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main) // network delay
            .eraseToAnyPublisher()
        
        // TODO: Real API Implementation
    }

    // mock data for testing
    private func mockCategories() -> [Category] {
        return [
            Category(id: "arrays-hashing", name: "Arrays & Hashing", problems: [
                Problem(id: "two-sum", title: "Two Sum", difficulty: .easy, status: .completed),
                Problem(id: "valid-anagram", title: "Valid Anagram", difficulty: .easy, status: .attempted),
                Problem(id: "contains-duplicate", title: "Contains Duplicate", difficulty: .easy),
                Problem(id: "group-anagrams", title: "Group Anagrams", difficulty: .medium, status: .bookmarked)
            ]),
            Category(id: "two-pointers", name: "Two Pointers", problems: [
                Problem(id: "valid-palindrome", title: "Valid Palindrome", difficulty: .easy, status: .completed),
                Problem(id: "3sum", title: "3Sum", difficulty: .medium),
                Problem(id: "container-water", title: "Container With Most Water", difficulty: .medium, status: .attempted)
            ]),
            Category(id: "sliding-window", name: "Sliding Window", problems: [
                Problem(id: "best-time-stock", title: "Best Time to Buy and Sell Stock", difficulty: .easy, status: .completed),
                Problem(id: "longest-substring", title: "Longest Substring Without Repeating Characters", difficulty: .medium)
            ])
        ]
    }
}
