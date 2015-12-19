//
//  Cache.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 19-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    A key-based cache

    Note: all cache keys starting with "s1:" are used by the SDK. If you want to use this cache,
    please use cache keys not starting with "s1:"
*/
public protocol Cache {
    /**
        Get the value of a stored key
        
        - Parameter key: Key to get the cached value of
        - Returns: Cached value of the key, or nil if value not found or expired
    */
    func getKey(key: String) -> AnyObject?
    
    /**
        Get the age of a stored key in seconds
        
        - Parameter key: Key to get the age of
        - Returns: Age of the key in seconds, or false if value not found or expired
    */
    func ageOfKey(key: String) -> NSTimeInterval?
    
    /**
        Store a value for the given key
        
        Storing a value may not guarantee it being available, so first storing a value and then
        immediately retrieving it may still not give a valid result. For example, the
        NoopCache stores nothing so get(...) will never return any value.
        
        - Parameter key: Key to cache the value for
        - Parameter value: Value to store for the given key
    */
    func setKey(key: String, value: AnyObject)
}