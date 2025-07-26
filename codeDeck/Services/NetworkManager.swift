//
//  Network.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-07-23.
//

import Foundation
import Combine

public protocol NetworkManagerProtocol {
    // fetch(from: url, as: Category.self) --> returns T or error
    func fetch<T: Codable>(from url: URL, as type: T.Type) -> AnyPublisher<T, Error>
}

class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    private let session = URLSession.shared  // built in networking class
    private init() {}
    
    func fetch<T: Codable>(from url: URL, as type: T.Type) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
        
            // network->data extraction->decode->thread switching->type erasure
        
//        URLSession Response → .map(\.data) → .decode() → .receive(main) → .eraseToAnyPublisher()
//               ↓                   ↓            ↓           ↓                    ↓
//          Raw Response         JSON Data    Swift Object   Main Thread     Simple Type
//
            .map(\.data)
            .decode(type: type, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)  // switch to main thread where ui updates occur
            .eraseToAnyPublisher()  // return a simple type instead of complex one
    }
}
