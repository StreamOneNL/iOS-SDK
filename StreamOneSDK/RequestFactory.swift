//
//  RequestFactory.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 25-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Protocol for a request factory to instantiate different kinds of requests
*/
public protocol RequestFactory {
    /**
        Instantiate a new request without a session
        
        - Parametere command: The command to execute
        - Parameter action: The action to execute
        - Returns: The instantiated request
    */
    func newRequest(command command: String, action: String, config: Config) -> Request
    
    /**
        Instantiate a new request within a session
        
        - Parameter command: The command to execute
        - Parameter action: The action to execute
        - Parameter sessionStore: The session store containing the required session information
        - Returns: The instantiated request
    */
    func newSessionRequest(command command: String, action: String, config: Config, sessionStore: SessionStore) throws -> SessionRequest
}