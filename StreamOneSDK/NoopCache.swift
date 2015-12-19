//
//  NoopCache.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 19-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    A no-op caching implementation, caching nothing
*/
public final class NoopCache : Cache {
    /**
        Get the value of a stored key
        
        - Parameter key: Key to get the cached value of
        - Returns: Cached value of the key, or nil if value not found or expired
    */
    public func getKey(key: String) -> AnyObject? {
        return nil
    }
    
    /**
        Get the age of a stored key in seconds
        
        - Parameter key: Key to get the age of
        - Returns: Age of the key in seconds, or false if value not found or expired
    */
    public func ageOfKey(key: String) -> NSTimeInterval? {
        return nil
    }
    
    /**
        Store a value for the given key
        
        Storing a value may not guarantee it being available, so first storing a value and then
        immediately retrieving it may still not give a valid result. For example, the
        NoopCache stores nothing so get(...) will never return any value.
        
        - Parameter key: Key to cache the value for
        - Parameter value: Value to store for the given key
    */
    public func setKey(key: String, value: AnyObject) {
        // Nothing
    }
}