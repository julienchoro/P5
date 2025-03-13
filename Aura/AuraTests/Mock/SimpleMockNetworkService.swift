//
//  SimpleMockNetworkService.swift
//  AuraTests
//
//  Created by Julien Choromanski on 15/03/2025.
//

import Foundation
@testable import Aura

class SimpleMockNetworkService: NetworkServiceProtocol {
    let baseURL = "http://mock-url.com"
    var urlSession: URLSession = URLSession.shared
    var requestInterceptor: ((URLRequest) -> URLRequest)?
    
    enum Behavior {
        case success(Any)
        case error(NetworkError)
    }
    
    var behavior: Behavior
    private var authToken: String?
    
    init(behavior: Behavior = .success("")) {
        self.behavior = behavior
    }
    
    // Méthodes de base du protocole
    func getBaseURL() -> String { 
        return baseURL 
    }
    
    func setAuthToken(_ token: String) { 
        self.authToken = token 
    }
    
    func getAuthToken() -> String? { 
        return authToken 
    }
    
    func clearAuthToken() { 
        authToken = nil 
    }
    
    func post<T: Encodable, U: Decodable>(endpoint: String, body: T, requiresAuth: Bool = false) async throws -> U {
        if requiresAuth && authToken == nil {
            throw NetworkError.unauthorized
        }
        
        switch behavior {
        case .success(let response):
            if let typedResponse = response as? U {
                return typedResponse
            }
            throw NetworkError.invalidResponse
        case .error(let error):
            throw error
        }
    }
    
    func get<T: Decodable>(endpoint: String, requiresAuth: Bool = true) async throws -> T {
        if requiresAuth && authToken == nil {
            throw NetworkError.unauthorized
        }
        
        switch behavior {
        case .success(let response):
            if let typedResponse = response as? T {
                return typedResponse
            }
            throw NetworkError.invalidResponse
        case .error(let error):
            throw error
        }
    }
} 
