//
//  MemoryCache.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 26-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    A memory caching implementation, caches everything in memory as long as this object exists
*/
public final class MemoryCache: Cache {
    
    var cache = [String: (NSTimeInterval, AnyObject)]()
    
    /**
        Get the value of a stored key
        
        - Parameter key: Key to get the cached value of
        - Returns: Cached value of the key, or nil if value not found or expired
    */
    public func getKey(key: String) -> AnyObject? {
        return cache[key]?.1
    }
    
    /**
        Get the age of a stored key in seconds
        
        - Parameter key: Key to get the age of
        - Returns: Age of the key in seconds, or nil if value not found or expired
    */
    public func ageOfKey(key: String) -> NSTimeInterval? {
        if let time = cache[key]?.0 {
            return NSDate().timeIntervalSince1970 - time
        }
        return nil
    }
    
    /**
        Store a value for the given key
        
        Stored values are available until this object is destroyed
        
        - Parameter key: Key to cache the value for
        - Parameter value: Value to store for the given key
    */
    public func setKey(key: String, value: AnyObject) {
        cache[key] = (NSDate().timeIntervalSince1970, value)
    }
}