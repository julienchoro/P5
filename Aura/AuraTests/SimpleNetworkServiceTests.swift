//
//  SimpleNetworkServiceTests.swift
//  AuraTests
//
//  Created by Julien Choromanski on 15/03/2025.
//

import XCTest
@testable import Aura

/// Tests simplifiés qui vérifient les différents retours du backend
class SimpleNetworkServiceTests: XCTestCase {
    
    // MARK: - Tests d'authentification
    
    /// Test d'authentification réussie
    func testAuthSuccess() async throws {
        // Given: un mock configuré pour un succès d'authentification
        let expectedResponse = AuthResponse(token: "mock-token-12345", userId: 42)
        let mock = SimpleMockNetworkService(behavior: .success(expectedResponse))
        
        // When: tentative d'authentification
        let result: AuthResponse = try await mock.post(
            endpoint: "auth", 
            body: TestRequestModel(username: "test@aura.app", password: "test123")
        )
        
        // Then: vérification de la réponse
        XCTAssertEqual(result.token, expectedResponse.token)
        XCTAssertEqual(result.userId, expectedResponse.userId)
    }
    
    /// Test d'authentification échouée (Bad Request)
    func testAuthFailure() async {
        // Given: un mock configuré pour un échec d'authentification
        let mock = SimpleMockNetworkService(behavior: .error(NetworkError.badRequest))
        
        // When & Then: vérifier que l'authentification échoue avec l'erreur attendue
        do {
            let _: AuthResponse = try await mock.post(
                endpoint: "auth", 
                body: TestRequestModel(username: "invalid@test.com", password: "wrongpassword")
            )
            XCTFail("L'authentification aurait dû échouer")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.badRequest)
        } catch {
            XCTFail("Erreur inattendue: \(error)")
        }
    }
    
    // MARK: - Tests d'accès au compte
    
    /// Test d'accès au compte réussi
    func testAccountAccessSuccess() async throws {
        // Given: un mock configuré pour un accès réussi au compte
        let expectedResponse = AccountResponse(
            currentBalance: 5459.32,
            transactions: [
                AccountResponse.Transaction(value: -56.4, label: "IKEA"),
                AccountResponse.Transaction(value: -10, label: "Starbucks"),
                AccountResponse.Transaction(value: 1400, label: "Pole Emploi")
            ]
        )
        let mock = SimpleMockNetworkService(behavior: .success(expectedResponse))
        mock.setAuthToken("valid-token")
        
        // When: tentative d'accès au compte
        let result: AccountResponse = try await mock.get(endpoint: "account")
        
        // Then: vérification de la réponse
        XCTAssertEqual(result.currentBalance, expectedResponse.currentBalance)
        XCTAssertEqual(result.transactions.count, expectedResponse.transactions.count)
    }
    
    /// Test d'accès au compte sans authentification
    func testAccountAccessWithoutAuth() async {
        // Given: un mock sans token d'authentification
        let mock = SimpleMockNetworkService(behavior: .success(AccountResponse(
            currentBalance: 0,
            transactions: []
        )))
        // Pas de token défini
        
        // When & Then: vérifier que l'accès échoue avec une erreur d'authentification
        do {
            let _: AccountResponse = try await mock.get(endpoint: "account")
            XCTFail("L'accès au compte aurait dû échouer sans authentification")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Erreur inattendue: \(error)")
        }
    }
    
    /// Test d'accès au compte avec erreur serveur
    func testAccountAccessServerError() async {
        // Given: un mock configuré pour une erreur serveur
        let mock = SimpleMockNetworkService(behavior: .error(NetworkError.serverError))
        mock.setAuthToken("valid-token")
        
        // When & Then: vérifier que l'accès échoue avec une erreur serveur
        do {
            let _: AccountResponse = try await mock.get(endpoint: "account")
            XCTFail("L'accès au compte aurait dû échouer avec une erreur serveur")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.serverError)
        } catch {
            XCTFail("Erreur inattendue: \(error)")
        }
    }
    
    // MARK: - Tests de transfert d'argent
    
    /// Test de transfert d'argent réussi
    func testMoneyTransferSuccess() async throws {
        // Given: un mock configuré pour un transfert réussi
        let mock = SimpleMockNetworkService(behavior: .success(""))
        mock.setAuthToken("valid-token")
        
        // When: tentative de transfert
        let result: String = try await mock.post(
            endpoint: "account/transfer",
            body: TransferRequest(amount: 100.0, recipient: "John Doe"),
            requiresAuth: true
        )
        
        // Then: vérification de la réponse (chaîne vide en cas de succès)
        XCTAssertEqual(result, "")
    }
    
    /// Test de transfert d'argent avec erreur de validation
    func testMoneyTransferValidationError() async {
        // Given: un mock configuré pour une erreur de validation
        let mock = SimpleMockNetworkService(behavior: .error(NetworkError.badRequest))
        mock.setAuthToken("valid-token")
        
        // When & Then: vérifier que le transfert échoue avec une erreur de validation
        do {
            let _: String = try await mock.post(
                endpoint: "account/transfer",
                body: TransferRequest(amount: -50.0, recipient: "John Doe"),
                requiresAuth: true
            )
            XCTFail("Le transfert avec un montant négatif aurait dû échouer")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.badRequest)
        } catch {
            XCTFail("Erreur inattendue: \(error)")
        }
    }
    
    // MARK: - Tests d'erreurs génériques
    
    /// Test d'erreur de décodage
    func testDecodingError() async {
        // Given: un mock configuré pour une erreur de décodage
        let decodingError = NSError(domain: "DecodingError", code: 1, userInfo: nil)
        let mock = SimpleMockNetworkService(behavior: .error(NetworkError.decodingFailed(decodingError)))
        mock.setAuthToken("valid-token")
        
        // When & Then: vérifier que la requête échoue avec une erreur de décodage
        do {
            let _: AccountResponse = try await mock.get(endpoint: "account")
            XCTFail("La requête aurait dû échouer avec une erreur de décodage")
        } catch let error as NetworkError {
            if case .decodingFailed(_) = error {
                // Test réussi
            } else {
                XCTFail("Erreur attendue: decodingFailed, obtenue: \(error)")
            }
        } catch {
            XCTFail("Erreur inattendue: \(error)")
        }
    }
    
    /// Test d'erreur d'URL invalide
    func testInvalidURLError() async {
        // Given: un mock configuré pour une erreur d'URL
        let mock = SimpleMockNetworkService(behavior: .error(NetworkError.invalidURL))
        // Définir un token d'authentification pour éviter l'erreur unauthorized
        mock.setAuthToken("valid-token")
        
        // When & Then: vérifier que la requête échoue avec une erreur d'URL
        do {
            let _: String = try await mock.get(endpoint: "")
            XCTFail("La requête aurait dû échouer avec une erreur d'URL")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidURL)
        } catch {
            XCTFail("Erreur inattendue: \(error)")
        }
    }
} 