//
//  Customer.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry

/**
    A basic customer as returned from the API
*/
public struct BasicCustomer : Decodable {
    /// Customer ID
    public let id: String

    /// The name of this customer
    public let name: String

    /// When this customer was created
    public let dateCreated: String

    /// When this customer was last modified
    public let dateModified: String

    /**
        Decode a JSON object into a customer

        - Parameter json: The JSON to decode
        - Returns: The decoded customer
    */
    public static func decode(json: JSON) -> Decoded<BasicCustomer> {
        return curry(BasicCustomer.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <| "datecreated"
            <*> json <| "datemodified"
    }
}