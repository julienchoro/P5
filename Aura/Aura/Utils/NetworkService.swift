//
//  NetworkService.swift
//  Aura
//
//  Created by Julien Choromanski on 03/03/2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case decodingFailed(Error)
    case unauthorized
    case badRequest
    case serverError
}

// Extension pour permettre la comparaison d'égalité dans les tests
extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.unauthorized, .unauthorized),
             (.badRequest, .badRequest),
             (.serverError, .serverError):
            return true
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// Définition du protocole NetworkServiceProtocol
protocol NetworkServiceProtocol {
    var baseURL: String { get }
    var urlSession: URLSession { get set }
    var requestInterceptor: ((URLRequest) -> URLRequest)? { get set }
    
    func getBaseURL() -> String
    func setAuthToken(_ token: String)
    func getAuthToken() -> String?
    func clearAuthToken()
    func post<T: Encodable, U: Decodable>(endpoint: String, body: T, requiresAuth: Bool) async throws -> U
    func get<T: Decodable>(endpoint: String, requiresAuth: Bool) async throws -> T
}

// Modification de la classe NetworkService pour implémenter le protocole
class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    internal let baseURL = "http://localhost:8080"
    private var authToken: String?
    
    // Propriétés pour les tests
    var urlSession: URLSession = URLSession.shared
    var requestInterceptor: ((URLRequest) -> URLRequest)?
    
    private init() {}
    
    // Méthode d'accès à baseURL pour les tests
    func getBaseURL() -> String {
        return baseURL
    }
    
    // Stockage du token d'authentification
    func setAuthToken(_ token: String) {
        self.authToken = token
        // Sauvegarde du token dans UserDefaults pour le conserver entre les sessions
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    // Récupération du token d'authentification
    func getAuthToken() -> String? {
        if authToken == nil {
            // Si le token n'est pas en mémoire, essayer de le récupérer depuis UserDefaults
            authToken = UserDefaults.standard.string(forKey: "authToken")
        }
        return authToken
    }
    
    // Suppression du token (déconnexion)
    func clearAuthToken() {
        authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    // Méthode générique pour les requêtes POST
    func post<T: Encodable, U: Decodable>(endpoint: String, body: T, requiresAuth: Bool = false) async throws -> U {
        // Vérifier si l'endpoint est vide
        if endpoint.isEmpty {
            throw NetworkError.invalidURL
        }
        
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Ajout du token d'authentification si nécessaire
        if requiresAuth, let token = getAuthToken() {
            request.addValue(token, forHTTPHeaderField: "token")
        }
        
        // Encodage du corps de la requête
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw NetworkError.requestFailed(error)
        }
        
        // Appliquer l'intercepteur de requêtes si défini (pour les tests)
        if let interceptor = requestInterceptor {
            request = interceptor(request)
        }
        
        // Exécution de la requête
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Vérification de la réponse HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                // Décodage de la réponse
                do {
                    return try JSONDecoder().decode(U.self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(error)
                }
            case 400:
                throw NetworkError.badRequest
            case 401:
                throw NetworkError.unauthorized
            default:
                throw NetworkError.serverError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    // Méthode générique pour les requêtes GET
    func get<T: Decodable>(endpoint: String, requiresAuth: Bool = true) async throws -> T {
        // Vérifier si l'endpoint est vide
        if endpoint.isEmpty {
            throw NetworkError.invalidURL
        }
        
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Ajout du token d'authentification si nécessaire
        if requiresAuth, let token = getAuthToken() {
            request.addValue(token, forHTTPHeaderField: "token")
        }
        
        // Appliquer l'intercepteur de requêtes si défini (pour les tests)
        if let interceptor = requestInterceptor {
            request = interceptor(request)
        }
        
        // Exécution de la requête
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Vérification de la réponse HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                // Décodage de la réponse
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(error)
                }
            case 400:
                throw NetworkError.badRequest
            case 401:
                throw NetworkError.unauthorized
            default:
                throw NetworkError.serverError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
} 
