//
//  StandardReqeustFactory.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 25-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Default request factory for the StreamOne iOS SDK
*/
public final class StandardRequestFactory : RequestFactory {
    /**
        Instantiate a new request without a session
        
        - Parametere command: The command to execute
        - Parameter action: The action to execute
        - Returns: The instantiated request
    */
    public func newRequest(command command: String, action: String, config: Config) -> Request {
        return Request(command: command, action: action, config: config)
    }
    
    /**
        Instantiate a new request within a session
        
        - Parameter command: The command to execute
        - Parameter action: The action to execute
        - Parameter sessionStore: The session store containing the required session information
        - Returns: The instantiated request
    */
    public func newSessionRequest(command command: String, action: String, config: Config, sessionStore: SessionStore) throws -> SessionRequest {
        return try SessionRequest(command: command, action: action, config: config, sessionStore: sessionStore)
    }
}