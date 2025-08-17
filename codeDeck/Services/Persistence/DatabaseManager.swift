//
//  DatabaseManager.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-08-10.
//

import Foundation
import SQLite

enum DatabaseError: Error {
    case connectionError
}

actor DatabaseManager {
    static let shared = DatabaseManager()
    
    private var db: Connection?

    private let categories = Table("categories")
    private let problems = Table("problems")
    
    private let categoryId = Expression<String>("id")
    private let categoryName = Expression<String>("name")
    
    private let problemId = Expression<String>("id")
    private let problemTitle = Expression<String>("title")
    private let problemDifficulty = Expression<String>("difficulty")
    private var problemStatus = Expression<String?>("status")
    private let problemCategoryId = Expression<String>("categoryId")
    
    private let problemDescription = Expression<String?>("description")
    private let problemHints = Expression<String?>("hints") // JSON string
    private let problemExample = Expression<String?>("example")
    private let problemSolution = Expression<String?>("solution")
    private let problemTimeComplexity = Expression<String?>("timeComplexity")
    private let problemSpaceComplexity = Expression<String?>("spaceComplexity")


    private init() { }
    
    func setup() async {
        do {
            let path = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("codeDeck.sqlite")
                .path
            
            db = try Connection(path)
            print("🔍 DATABASE PATH: \(path)")
            print("Open this in DB Browser: file://\(path)")
            print("Connected")
            
            try createTables()
        } catch {
            print("Error setting up DB: \(error)")
        }
    }
    
    private func createTables() throws {
        try db?.run(categories.create(ifNotExists: true) { t in
            t.column(categoryId, primaryKey: true)
            t.column(categoryName)
        })
        try db?.run(problems.create(ifNotExists: true) { t in
            t.column(problemId, primaryKey: true)
            t.column(problemTitle)
            t.column(problemDifficulty)
            t.column(problemStatus)
            t.column(problemCategoryId)
            t.column(problemDescription)
            t.column(problemHints)
            t.column(problemExample)
            t.column(problemSolution)
            t.column(problemTimeComplexity)
            t.column(problemSpaceComplexity)
        })
    }
    
    func addCategory(id: String, name: String) {
        do {
            let insert = categories.insert(categoryId <- id, categoryName <- name)
            try db?.run(insert)
        } catch {
            print("Error inserting category: \(error)")
        }
    }
    
    func getCategories() async throws -> [Category] {
        guard let db = db else { throw DatabaseError.connectionError }
        
        var result: [Category] = []
        for row in try db.prepare(categories) {
            result.append(Category(id: row[categoryId], name: row[categoryName], problems: []))
        }
        return result
    }

    func getProblems(forCategoryId categoryId: String) async throws -> [Problem] {
        var result: [Problem] = []
        
        do {
            for row in try db!.prepare(problems.filter(problemCategoryId == categoryId)) {
                let statusEnum = row[problemStatus].flatMap { ProblemStatus(rawValue: $0) }
                let diffEnum = Difficulty(rawValue: row[problemDifficulty])
                
                result.append(Problem(
                    id: row[problemId],
                    title: row[problemTitle],
                    difficulty: diffEnum ?? .easy,
                    status: statusEnum,
                    description: row[problemDescription],
                    example: row[problemExample],
                    solution: row[problemSolution],
                    timeComplexity: row[problemTimeComplexity],
                    spaceComplexity: row[problemSpaceComplexity]
                ))
            }
        } catch {
                print("Error: \(error)")
        }
    
        return result
    }

    
    func updateProblemStatus(problemId: String, newStatus: ProblemStatus?) async throws {
        guard let db = db else { throw DatabaseError.connectionError }

        let problemToUpdate = problems.filter(self.problemId == problemId)
        try db.run(problemToUpdate.update(problemStatus <- newStatus?.rawValue))
    }
    
    func addProblem(
        id: String,
        title: String,
        difficulty: Difficulty,
        categoryId: String,
        description: String? = nil,
        example: String? = nil,
        solution: String? = nil,
        timeComplexity: String? = nil,
        spaceComplexity: String? = nil,
        status: ProblemStatus? = nil,
    ) async throws {
        guard let db = db else { throw DatabaseError.connectionError }
        
        do {
            let insert = problems.insert(
                problemId <- id,
                problemTitle <- title,
                problemDifficulty <- difficulty.rawValue,
                problemStatus <- status?.rawValue,
                problemCategoryId <- categoryId,
                problemDescription <- description,
                problemExample <- example,
                problemSolution <- solution,
                problemTimeComplexity <- timeComplexity,
                problemSpaceComplexity <- spaceComplexity
            )
            try db.run(insert)
        } catch {
            print("Error inserting problem: \(error)")
            throw error
        }
    }
    
    func updateProblemDetails(
        problemId: String,
        description: String? = nil,
        example: String? = nil,
        solution: String? = nil,
        timeComplexity: String? = nil,
        spaceComplexity: String? = nil
    ) async throws {
        guard let db = db else { throw DatabaseError.connectionError }
        
        let problemToUpdate = problems.filter(self.problemId == problemId)

        
        do {
            try db.run(problemToUpdate.update(
                self.problemDescription <- description,
                self.problemExample <- example,
                self.problemSolution <- solution,
                self.problemTimeComplexity <- timeComplexity,
                self.problemSpaceComplexity <- spaceComplexity
            ))
        } catch {
            print("Error updating problem details: \(error)")
            throw error
        }
    }
    
}

