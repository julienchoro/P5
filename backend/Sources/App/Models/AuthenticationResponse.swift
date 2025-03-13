//
//  AuthenticationResponse.swift
//
//
//  Created by Vincent Saluzzo on 03/10/2023.
//

import Vapor

struct AuthenticationResponse: Content {
    let token: String
}
