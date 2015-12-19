//
//  SessionCache.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    A session caching implementation, storing cached data in a SessionStore

    Since SessionStoreInterface does not support storing the age of cached data, and CacheInterface
    requires this, this class stores a dictionary in every value with the following keys:

    - time: NSTImeInterval of the moment when the value was stored
    - value: the actual value stored
*/
public class SessionCache : Cache {
    /**
        Session store to store cached values in
    */
    public let sessionStore: SessionStore

    /**
        Create a new session cache

        - Parameter sessionStore: The session store to store the cached values in
    */
    public init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    /**
        Create a new session cache

        - Parameter session: The session to use the store of to store the cached values in
    */
    public convenience init(session: Session) {
        self.init(sessionStore: session.sessionStore)
    }

    /**
        Get the value of a stored key

        - Parameter key: Key to get the cached value of
        - Returns: Cached value of the key, or nil if value not found or expired
    */
    public func getKey(key: String) -> AnyObject? {
        return getData(key)?["value"]
    }

    /**
        Get the age of a stored key in seconds

        - Parameter key: Key to get the age of
        - Returns: Age of the key in seconds, or false if value not found or expired
    */
    public func ageOfKey(key: String) -> NSTimeInterval? {
        if let age = getData(key)?["time"] as? NSTimeInterval {
            return NSDate().timeIntervalSince1970 - age
        }

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
        let data: [String: AnyObject] = ["time": NSDate().timeIntervalSince1970, "value": value]
        try! sessionStore.setCacheKey(key, value: data)
    }

    /**
        Get the cache data associated with a key as a dictionary

        - Parameter key: Key to get the data from
        - Returns: A `[String: AnyObject] dictionary with the data or nil if not found or invalid type
    */
    internal func getData(key: String) -> [String: AnyObject]? {
        guard try! sessionStore.hasCacheKey(key) else { return nil }
        guard let data = try! sessionStore.getCacheKey(key) as? [String: AnyObject] else { return nil }

        return data
    }
}