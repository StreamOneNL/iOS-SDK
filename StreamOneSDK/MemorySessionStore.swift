//
//  MemorySessionStore.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 07-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    In-memory session storage class

    Values in instances of memory session store are only known for the lifetime of the instance, and
    will be discarded once the instance is destroyed.
*/
public final class MemorySessionStore : SessionStore {
    /**
        The current session ID; nil if no active session
    */
    var id: String!
    
    /**
        The current session key; nil if no active session
    */
    var key: String!
    
    /**
        The user ID of the user logged in with the current session; nil if no active session
    */
    var userId: String!
    
    /**
        The current session timeout as absolute timestamp; nil if no active session
    */
    var timeout: NSTimeInterval!
    
    /**
        Data store for cached values
    */
    var cache = [String: AnyObject]()
    
    /**
        Whether there is an active session
    */
    public var hasSession: Bool {
        // All variables need to be set to a non-nil value for an active session
        guard id != nil && key != nil && userId != nil && timeout != nil else { return false }
        
        // The timeout must not have passed yed
        if timeout < NSDate().timeIntervalSince1970 {
            clearSession()
            return false
        }
        
        // All checks passed; there is an active session
        return true
    }
    
    /**
        Clears the current active session
    */
    public func clearSession() {
        id = nil
        key = nil
        userId = nil
        timeout = nil
        cache = [String: AnyObject]()
    }
    
    /**
        Save a session to this store
        
        - Parameter id: The ID for this session
        - Parameter key: The key for this session
        - Parameter userId: The user ID for this session
        - Parameter timeout: The number of seconds before this session becomes
                             invalid when not doing any requests
    */
    public func setSession(id id: String, key: String, userId: String, timeout: NSTimeInterval) {
        self.id = id
        self.key = key
        self.userId = userId
        self.timeout = NSDate().timeIntervalSince1970 + timeout
    }
    
    /**
        Update the timeout of a session
    
        - Parameter timeout: The new timeout for the active session, in seconds from now
    */
    public func setTimeout(timeout: NSTimeInterval) throws {
        guard hasSession else { throw SessionError.NoSession }
        self.timeout = NSDate().timeIntervalSince1970 + timeout
    }
    
    /**
        Retrieve the current session ID
    
        This function will throw if there is no active session,
    
        - Returns: The current session ID
    */
    public func getId() throws -> String {
        guard hasSession else { throw SessionError.NoSession }
        return id
    }
    
    /**
        Retrieve the current session key
        
        This function will throw if there is no active session.
        
        - Returns: The current session key
    */
    public func getKey() throws -> String {
        guard hasSession else { throw SessionError.NoSession }
        return key
    }
    
    /**
        Retrieve the ID of the user logged in with the current session
        
        This function will throw if there is no active session.
        
        - Returns: The ID of the user logged in with the current session
    */
    public func getUserId() throws -> String {
        guard hasSession else { throw SessionError.NoSession }
        return userId
    }
    
    /**
        Retrieve the current session timeout
        
        This function will throw if there is no active session.
        
        - Returns: The number of seconds before this session expires; negative if the session has expired
    */
    public func getTimeout() throws -> NSTimeInterval {
        guard hasSession else { throw SessionError.NoSession }
        return timeout - NSDate().timeIntervalSince1970
    }
    
    /**
        Check if a certain key is stored in the cache
        
        - Parameter key: Cache key to check for existence
        - Returns: True if and only if the given key is set in the cache
    */
    public func hasCacheKey(key: String) throws -> Bool {
        guard hasSession else { throw SessionError.NoSession }
        return cache[key] != nil
    }
    
    /**
        Retrieve a stored cache key
        
        This function will throw if there is no active session or if hasCacheKey returns false
        for the given key.
        
        - Parameter key: Cache key to get the cached value of
        - Returns: The cached value
    */
    public func getCacheKey(key: String) throws -> AnyObject {
        guard try hasCacheKey(key) else { throw SessionError.NoSuchKey(key: key) }
        return cache[key]!
    }
    
    /**
        Store a cache key
        
        This function will throw if there is no active session.
        
        - Parameter key: Cache key to store a value for
        - Parameter value: Value to store for the given key
    */
    public func setCacheKey(key: String, value: AnyObject) throws {
        guard hasSession else { throw SessionError.NoSession }
        cache[key] = value
    }
    
    /**
        Unset a cached value
        
        This function will throw if there is no active session or if hasCacheKey returns false
        for the given key.
        
        - Parameter key: Cache key to unset
    */
    public func unsetCacheKey(key: String) throws {
        guard try hasCacheKey(key) else { throw SessionError.NoSuchKey(key: key) }
        cache.removeValueForKey(key)
    }
}