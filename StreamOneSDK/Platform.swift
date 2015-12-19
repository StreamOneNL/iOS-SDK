//
//  Platform.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 25-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    A representation of the StreamOne platform used as a factory for various available operations

    To work with the SDK, a Platform needs to be provided a configuration. This Platform can then
    be used to create various ways to work with the configured platform, such as Requests or Sessions.
*/
public struct Platform {
    /**
        The used configuration for the platform
    */
    public let config: Config
    
    /**
        Construct a new platform object

        - Parameter config: The configuration to use for the platform
    */
    public init(config: Config) {
        self.config = config
    }
    
    /**
        Create a new request for the platform

        - Parameter command: The command for the request
        - Parameter action: The action for the request
    */
    public func newRequest(command command: String, action: String) -> Request {
        return config.requestFactory.newRequest(command: command, action: action, config: config)
    }

    /**
        Create a Session object to work with API sessions

        - Parameter sessionStore: The session store to use for this session; if not given, use the
                                  one defined in the configuration
        - Returns: The created session
    */
    public func newSession(sessionStore sessionStore: SessionStore? = nil) -> Session {
        return Session(config: config, sessionStore: sessionStore)
    }

    /**
        Create an Actor object to perform requests as an actor

        - Parameter session: If given, the actor will use this session to act upon (i.e. it will
                             be a user actor with the given user information); if not given, use
                             actor information from the configuration
        - Returns: The created actor object
    */
    public func newActor(session session: Session? = nil) -> Actor {
        return Actor(config: config, session: session)
    }
}