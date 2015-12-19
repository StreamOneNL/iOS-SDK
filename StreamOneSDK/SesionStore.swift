//
//  SesionStore.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 07-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Protocol for session storage

    As a part of storing session information, session stores can also be asked to cache certain
    information for the duration of the session. For example, the tokens that the session user has
    can be stored in the session. This is subject to the following conditions:

    - Data cached in a session will always be cached for exactly the lifetime of the session.
    - It is only allowed to store serializable data in the cache.
*/
public protocol SessionStore {
    /**
        Whether there is an active session
    */
    var hasSession: Bool { get }

    /**
        Clears the current active session
    */
    func clearSession()

    /**
        Save a session to this store
    
        - Parameter id: The ID for this session
        - Parameter key: The key for this session
        - Parameter userId: The user ID for this session
        - Parameter timeout: The number of seconds before this session becomes
                             invalid when not doing any requests
    */
    func setSession(id id: String, key: String, userId: String, timeout: NSTimeInterval)

    /**
        Update the timeout of a session
    
        - Parameter timeout: The new timeout for the active session, in seconds from now
    */
    func setTimeout(timeout: NSTimeInterval) throws

    /**
        Retrieve the current session ID
    
        This function will throw if there is no active session,
        
        - Returns: The current session ID
    */
    func getId() throws -> String

    /**
        Retrieve the current session key
        
        This function will throw if there is no active session.
        
        - Returns: The current session key
    */
    func getKey() throws -> String

    /**
        Retrieve the ID of the user logged in with the current session

        This function will throw if there is no active session.

        - Returns: The ID of the user logged in with the current session
    */
    func getUserId() throws -> String

    /**
        Retrieve the current session timeout
    
        This function will throw if there is no active session.
    
        - Returns: The number of seconds before this session expires; negative if the session has expired
    */
    func getTimeout() throws -> NSTimeInterval

    /**
        Check if a certain key is stored in the cache
    
        This function will throw if there is no active session.
    
        - Parameter key: Cache key to check for existence
        - Returns: True if and only if the given key is set in the cache
    */
    func hasCacheKey(key: String) throws -> Bool
    
    /**
        Retrieve a stored cache key
    
        This function will throw if there is no active session or if hasCacheKey returns false
        for the given key.
    
        - Parameter key: Cache key to get the cached value of
        - Returns: The cached value
    */
    func getCacheKey(key: String) throws -> AnyObject

    /**
        Store a cache key
        
        This function will throw if there is no active session.
    
        - Parameter key: Cache key to store a value for
        - Parameter value: Value to store for the given key
    */
    func setCacheKey(key: String, value: AnyObject) throws

    /**
        Unset a cached value
    
        This function will throw if there is no active session or if hasCacheKey returns false
        for the given key.
    
        - Parameter key: Cache key to unset
    */
    func unsetCacheKey(key: String) throws
}