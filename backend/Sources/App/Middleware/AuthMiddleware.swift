//
//  AuthMiddleware.swift
//  
//
//  Created by Vincent Saluzzo on 03/10/2023.
//

import Vapor



struct AuthMiddleware: Middleware {
    static private var authTokens: [String] = []
    static func registerNewAuthToken() -> String {
        let token = UUID()
        authTokens.append(token.uuidString)
        return token.uuidString
    }
    
    func respond(to request: Vapor.Request, chainingTo next: Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
        let authToken = request.headers.first(name: "token")
        if AuthMiddleware.authTokens.first(where: { $0 == authToken }) != nil {
            return next.respond(to: request)
        } else {
            return request.eventLoop.future(error: Abort(.unauthorized))
        }
    }
}

