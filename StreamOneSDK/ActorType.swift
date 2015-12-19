//
//  ActorType.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 17-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/// Enumeration for actor types
internal enum ActorType {
    /// Actor for a user
    case User

    /// Actor for an application
    case Application

    /// Which API command corresponds to this actor type
    var apiCommand: String {
        switch self {
        case .User: return "user"
        case .Application: return "application"
        }
    }
}

extension ActorType: CustomStringConvertible {
    /// A textual representation of `self`
    var description: String {
        switch self {
        case .User: return "User"
        case .Application: return "Application"
        }
    }
}