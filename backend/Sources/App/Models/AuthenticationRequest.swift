//
//  AuthenticationRequest.swift
//  
//
//  Created by Vincent Saluzzo on 03/10/2023.
//

import Vapor

struct AuthenticationRequest: Content {
    let username: String
    let password: String
}
