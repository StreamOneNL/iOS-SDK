//
//  RoleInActor.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry

/**
    A role for an actor as returned from the API
*/
public struct RoleInActor : Decodable {
    /// Role belonging to this actor role
    public let role: Role

    /// Account belonging to this role
    public let account: BasicAccount?

    /// Customer belonging to this role
    public let customer: BasicCustomer?

    /**
        Decode a JSON object into a role for an actor

        - Parameter json: The JSON to decode
        - Returns: The decoded role for an actor
    */
    public static func decode(json: JSON) -> Decoded<RoleInActor> {
        return curry(RoleInActor.init)
            <^> json <| "role"
            <*> json <|? "account"
            <*> json <|? "customer"
    }
}