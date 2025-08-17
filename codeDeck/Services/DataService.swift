//
//  DataService.swift
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
    
    private let useMockData: Bool
    
    
    // default init -> using real NetworkManager
    init(useMockData: Bool = false) {
        self.networkManager = NetworkManager.shared
        self.useMockData = useMockData
    }
    
    // custom init -> for mock NetworkManager
    init(networkManager: NetworkManagerProtocol, useMockData: Bool = false) {
        self.networkManager = networkManager
        self.useMockData = useMockData
    }
    
    func loadCategories() -> AnyPublisher<[Category], Error> {
        if useMockData {
            return Just(mockCategories())
                .setFailureType(to: Error.self)
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        } else {
            return Future { promise in
                Task {
                    do {
                        // get categories from database
                        let categories = try await DatabaseManager.shared.getCategories()
                        
                        // get problems for each category
                        var categoriesWithProblems: [Category] = []
                        for category in categories {
                            let problems = try await DatabaseManager.shared.getProblems(forCategoryId: category.id)
                            let categoryWithProblems = Category(
                                id: category.id,
                                name: category.name,
                                problems: problems
                            )
                            categoriesWithProblems.append(categoryWithProblems)
                        }
                        
                        promise(.success(categoriesWithProblems))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .receive(on: DispatchQueue.main)  
            .eraseToAnyPublisher()
        }
    }
        
    func updateProblemStatus(problemId: String, status: ProblemStatus) -> AnyPublisher<Void, Error> {
        if useMockData {
            return Just(())
                .setFailureType(to: Error.self)
                .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        } else {
            return Future { promise in
                Task {
                    do {
                        try await DatabaseManager.shared.updateProblemStatus(
                            problemId: problemId,
                            newStatus: status
                        )
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
    }
        
        
    // mock data for testing
    private func mockCategories() -> [Category] {
        return [
            Category(id: "arrays-hashing", name: "Arrays & Hashing", problems: [
                Problem(id: "two-sum", title: "Two Sum", difficulty: .easy, status: .completed),
                Problem(id: "valid-anagram", title: "Valid Anagram", difficulty: .easy, status: .attempted),
                Problem(id: "contains-duplicate", title: "Contains Duplicate", difficulty: .easy),
                Problem(id: "group-anagrams", title: "Group Anagrams", difficulty: .medium, status: .attempted)
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

