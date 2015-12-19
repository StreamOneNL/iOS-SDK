//
//  AuthenticationType.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 18-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Authentication types are used to denote how to communicate with the StreamOne API
*/
public enum AuthenticationType {
    /**
        Authenticate as a user

        - Parameter id: The ID of the user to authenticate as
        - Parameter psk: The pre-shared key of the user
    */
    case User(id: String, psk: String)

    /**
        Authenticate as an application

        - Parameter id: The ID of the application to authenticate as
        - Parameter psk: The pre-shared key of the application
    */
    case Application(id: String, psk: String)

    /**
        The ID for the authentication type
    */
    internal var id: String {
        switch self {
        case let .User(id: id, psk: _):
            return id
        case let .Application(id: id, psk: _):
            return id
        }
    }

    /**
        The pre-shared key for the authentication type
    */
    internal var psk: String {
        switch self {
        case let .User(id: _, psk: psk):
            return psk
        case let .Application(id: _, psk: psk):
            return psk
        }
    }

    /**
        Whether this authentication type is user authentication
    */
    internal var isUserAuth: Bool {
        switch self {
        case .User: return true
        case .Application: return false
        }
    }
}

extension AuthenticationType: CustomStringConvertible {
    /// A textual representation of `self`
    public var description: String {
        switch self {
        case let .User(id: id, psk: _):
            return "User(\(id))"
        case let .Application(id: id, psk: _):
            return "Application(\(id))"
        }
    }
}