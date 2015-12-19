//
//  SessionRequest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 25-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Alamofire

/**
    Arequest to the StreamOne API with an active session

    Note that it is only possible to use sessions when application authentication is enabled
    in Config. Trying to use sessions with user authentication will always result in
    an authentication error. Refer to the StreamOne Platform Documentation on Sessions for more
    information on using sessions.
*/
public class SessionRequest : Request {
    /**
        The session store containing the required session information
    */
    public let sessionStore: SessionStore

    /**
        Initialize a request for a given command and action and set the session

        - Parameter command: The command to use
        - Parameter action: The action to use
        - Parameter confi: The configuration to use
    */
    public init(command: String, action: String, config: Config, sessionStore: SessionStore) throws {
        self.sessionStore = sessionStore
        super.init(command: command, action: action, config: config)

        switch config.authenticationType {
        case .User:
            throw RequestError.UserAuthenticationNotSupported
        default:
            break
        }
    }

    /**
        This function will return the key used for signing the request

        - Returns: The key used for signing
    */
    override internal func signingKey() -> String {
        return try! "\(super.signingKey())\(sessionStore.getKey())"
    }

    /**
        Retrieve the parameters used for signing

        - Returns: A dictionary containing the parameters needed for signing
    */
    override internal func parametersForSigning() -> [String : String] {
        var parameters = super.parametersForSigning()

        parameters["session"] = try! sessionStore.getId()

        return parameters
    }

    /**
        Process the result from a request

        - Parameter result: The result from a HTTP request
        - Parameter callback: The callback to call when processing the result is done
    */
    override internal func processResult(result: Result<AnyObject, NSError>, callback: (response: Response) -> Void) {
        super.processResult(result) { response in
            if let header = response.header,
                let sessionTimeout = header.allFields["sessiontimeout"] as? Double {
                    try! self.sessionStore.setTimeout(sessionTimeout)
            }
            callback(response: response)
        }
    }
}