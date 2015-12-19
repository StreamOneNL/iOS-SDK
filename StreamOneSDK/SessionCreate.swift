//
//  File.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry

/**
    Type as returned by the `session/create` API action
*/
public struct SessionCreate : Decodable {
    /**
        The ID for this session
    */
    public let id: String

    /**
        The key for this session
    */
    public let key: String

    /**
        The number of seconds before this session expires
    */
    public let timeout: Int

    /**
        The hash for the user that is now logged in
    */
    public let user: String

    /**
        Decode a JSON object into a session/create response

        - Parameter json: The JSON to decode
        - Returns: The decoded session/create response
    */
    public static func decode(json: JSON) -> Decoded<SessionCreate> {
        return curry(SessionCreate.init)
            <^> json <| "id"
            <*> json <| "key"
            <*> json <| "timeout"
            <*> json <| "user"
    }
}