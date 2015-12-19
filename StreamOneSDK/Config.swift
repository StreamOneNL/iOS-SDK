//
//  Config.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 18-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    The configuration for the StreamOne SDK.

    This class is used by the SDK to get the correct configuration values to the
    correct places
*/
public struct Config {
    /**
        The URL of the API endpoint
    */
    public var apiUrl = "https://api.streamonecloud.net"
    
    /**
        The type of authentication to use
    */
    public let authenticationType: AuthenticationType
    
    /**
        If a default account is set, new requests obtained from Platform.newRequest will by
        default use that account. It is still possible to override this by using
        Request.setAccount() on the obtained request.
    */
    public var defaultAccountId: String?
    
    /**
        Request factory to use to instantiate new requests
    */
    public var requestFactory: RequestFactory = StandardRequestFactory()
    
    /**
        The caching object to use for requests
        
        The caching object will be used by the Request class to cache requests when appropiate.
        Any caching object used must implement the CacheInterface.
        
        The SDK provides the following caching classes:
        - NoopCache, which will not cache anything (default)
        - FileCache, which will cache to files on disk
        - MemCache, which will cache on a memcached server
        - MemoryCache, which will cache in memory
    */
    public var requestCache: Cache = NoopCache()

    /**
        The caching object to use for tokens and roles
        
        The caching object will be used by the Actor class to cache tokens and roles.
        Any caching object used must implement the CacheInterface.
        
        The SDK provides the following caching classes:
        - NoopCache, which will not cache anything (default)
        - FileCache, which will cache to files on disk
        - MemCache, which will cache on a memcached server
        - MemoryCache, which will cache in memory
    */
    public var tokenCache: Cache = NoopCache()
    
    /**
        Whether to use the session for roles and tokens cache if using a session. If true, the
        above token cache will never be used and can thus be null if only using sessions
    */
    public var useSessionForTokenCache = true
    
    /**
        Session store to use
    */
    public var sessionStore: SessionStore = MemorySessionStore()
    
    /**
        Create a new configuration

        - Parameter authenticationType: The authentication type to use for this configuration
    */
    public init(authenticationType: AuthenticationType) {
        self.authenticationType = authenticationType
    }
    
    /**
        Set both the request cache and token cache at the same time

        - Parameter cache: The cache to use for requests, tokens and roles
    */
    mutating public func setCache(cache: Cache) {
        requestCache = cache
        tokenCache = cache
    }
}