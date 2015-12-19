//
//  Session.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Manage a session for use with the StreamOne platform
*/
public struct Session {
    /**
        The configuration to use for this Session
    */
    let config: Config

    /**
        The session store to use for this session
    */
    let sessionStore: SessionStore

    /**
        Construct a new session object

        The session object may or may not have an active session, depending on what is stored in the
        passed session store object.

        - Parameter config: The configuration to use for this session
        - Parameter sessionStore: The session store to use for this session; if not given, use the
                                  one defined in the given configuration
    */
    public init(config: Config, sessionStore: SessionStore? = nil) {
        self.config = config
        self.sessionStore = sessionStore ?? config.sessionStore
    }

    /**
        Whether there is an active session

        If there is no active session, it is only possible to start a new session.
    */
    public var isActive: Bool {
        return sessionStore.hasSession
    }

    /**
        Create a new session with the StreamOne API.

        To start a new session provide the username, password, and IP address of the user requesting
        the new session. The IP address is required for rate limiting purposes and can also be a
        unique string identifying the current device. For example, you could use
        `UIDevice.currentDevice().identifierForVendor`
    
        - Parameter username: The username to use for this session
        - Parameter password: The password to use for this session
        - Parameter ip: The IP address of the user creating the session or something to identify the
                        current device
        - Parameter callback: A callback with the status of starting the session and the last
                              response received while starting the session
    */
    public func start(username username: String, password: String, ip: String, callback: (success: Bool,
        lastResponse: Response) -> Void) {

        let initializeRequest = config.requestFactory.newRequest(command: "session", action: "initialize", config: config)
        initializeRequest
            .setArgument("user", value: username)
            .setArgument("userip", value: ip)

        initializeRequest.execute { initializeResponse in
            guard initializeResponse.success else {
                callback(success: false, lastResponse: initializeResponse)
                return
            }

            guard let sessionInitialize: SessionInitialize = initializeResponse.typedBody() else {
                callback(success: false, lastResponse: initializeResponse)
                return
            }

            guard let passwordChallengeResponse = Password.generatePasswordResponse(password: password,
                salt: sessionInitialize.salt, challenge: sessionInitialize.challenge) else {
                callback(success: false, lastResponse: initializeResponse)
                return
            }

            let createRequest = self.config.requestFactory.newRequest(command: "session",
                action: "create", config: self.config)

            createRequest
                .setArgument("challenge", value: sessionInitialize.challenge)
                .setArgument("response", value: passwordChallengeResponse)

            if sessionInitialize.needsV2Hash {
                createRequest.setArgument("v2hash", value: Password.generateV2PasswordHash(password))
            }

            createRequest.execute { createResponse in
                guard createResponse.success else {
                    callback(success: false, lastResponse: createResponse)
                    return
                }

                guard let sessionCreate: SessionCreate = createResponse.typedBody() else {
                    callback(success: false, lastResponse: createResponse)
                    return
                }

                self.sessionStore.setSession(id: sessionCreate.id, key: sessionCreate.key,
                    userId: sessionCreate.user, timeout: NSTimeInterval(sessionCreate.timeout))

                callback(success: true, lastResponse: createResponse)
            }
        }
    }

    /**
        End the currently active session; i.e. log out the user

        This method should only be called with an active session.
    
    - Partameter callback: A callback that will be called after clearing the session. The parameter
                           to the callback will be true if and only if the session was successfully
                           deleted in the API. If not, the session is still cleared from the session
                           store and the session is therefore always inactive after the callback has
                           been called
    */
    public func end(callback: (success: Bool) -> Void) throws {
        guard isActive else { throw SessionError.NoSession }

        let request = try newRequest(command: "session", action: "delete")
        request.execute { response in
            self.sessionStore.clearSession()
            callback(success: response.success)
        }
    }

    /**
        Create a new request that uses the currently active session

        This method should only be called with an active session.

        - Parameter command: The command for the new request
        - Parameter action: The action for the new request
        - Returns: The new request using the currently active session for authentication
    */
    public func newRequest(command command: String, action: String) throws -> SessionRequest {
        guard isActive else { throw SessionError.NoSession }
        return try config.requestFactory.newSessionRequest(command: command, action: action, config: config, sessionStore: sessionStore)
    }
}