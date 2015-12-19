//
//  Helpers.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 19-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

@testable import StreamOneSDK

class MyTestCache : Cache {
    func getKey(key: String) -> AnyObject? {
        return nil
    }
    
    func ageOfKey(key: String) -> NSTimeInterval? {
        return nil
    }
    
    func setKey(key: String, value: AnyObject) {
    }
}

class MyRequestFactory : RequestFactory {
    func newRequest(command command: String, action: String, config: Config) -> Request {
        return Request(command: command, action: action, config: config)
    }
    
    func newSessionRequest(command command: String, action: String, config: Config, sessionStore: SessionStore) throws -> SessionRequest {
        return try SessionRequest(command: command, action: action, config: config, sessionStore: sessionStore)
    }
}

class MySessionStore : SessionStore {
    var hasSession: Bool {
        return false
    }
    
    func clearSession() {}
    
    func setSession(id id: String, key: String, userId: String, timeout: NSTimeInterval) {}
    
    func setTimeout(timeout: NSTimeInterval) {}
    
    func getId() throws -> String {
        return ""
    }
    
    func getKey() throws -> String {
        return ""
    }
    
    func getUserId() throws -> String {
        return ""
    }
    
    func getTimeout() throws -> NSTimeInterval {
        return 0
    }
    
    func hasCacheKey(key: String) throws -> Bool {
        return false
    }
    
    func getCacheKey(key: String) throws -> AnyObject {
        return ""
    }
    
    func setCacheKey(key: String, value: AnyObject) throws {}
    
    func unsetCacheKey(key: String) throws {}
}

// Equality on authentication type
extension AuthenticationType: Equatable {}

// Determine if two authentication types are the same
public func ==(lhs: AuthenticationType, rhs: AuthenticationType) -> Bool {
    switch (lhs, rhs) {
    case let (.User(id1, psk1), .User(id2, psk2)):
        return id1 == id2 && psk1 == psk2;
    case let (.Application(id1, psk1), .Application(id2, psk2)):
        return id1 == id2 && psk1 == psk2;
    default:
        return false;
    }
}