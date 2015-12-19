//
//  Response.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 09-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import Curry

/**
    A response is what is returned in the callback of the execute() method of a Request

    It will contain information about whether it is valid, the header data and ways to inspect both
    the header and the body of a response
*/
public struct Response {
    /**
        The header as received from the server after parsing
    */
    public struct Header : Decodable {
        /**
            The atatus as received from the API
        */
        public let status: Status

        /**
            The status message as received from the API
        */
        public let statusMessage: String

        /**
            Dictionary representing all fields in the header
        */
        public var allFields: [String: AnyObject]!

        /**
            Initialize a new header structure

            - Parameter status: The status for this header
            - Parameter statusMessage: The status message for this header
        */
        internal init(status: Status, statusMessage: String) {
            self.status = status
            self.statusMessage = statusMessage
        }

        /**
            Decode a JSON object into a header

            - Parameter json: The JSON to decode
            - Returns: The decoded header
        */
        public static func decode(json: JSON) -> Decoded<Header> {
            return curry(Header.init)
                <^> json <| "status"
                <*> json <| "statusmessage"
        }
    }

    /**
        The received result for this response
    */
    internal var result: Result<AnyObject, NSError>

    /**
        The header as received from the server
    */
    public var header: Header!

    /**
        Whether the response was retrieved from the cache
    */
    internal(set) public var fromCache = false

    /**
        If the response was retrieved from the cache, how old it is in seconds; otherwise nil
    */
    internal(set) public var cacheAge: NSTimeInterval? = nil

    /**
        Whether this response is cacheable
    */
    internal var cacheable: Bool {
        if success {
            if let cacheable = header.allFields["cacheable"] as? Bool where cacheable {
                return true
            }
        }
        return false
    }

    /**
        The body as received from the server
    */
    public var body: AnyObject!

    /**
        If a general error occurred, the error that occurred

        This field will be populated if:
        - A network error occurred
        - The repsonse from the server is not valid JSON
    */
    public var error: ErrorType?

    /**
        Whether this header is valid. If this returns false, it is not safe to read the values
        of the `header` and `body` properties
    */
    public var valid: Bool {
        // Although body can be nil, it will be represented as NSNull so we can check for nil here
        return header != nil && body != nil
    }

    /**
        Check if the request was successful

        The request was successful if the response is valid, and the status is .OK.
    */
    public var success: Bool {
        return valid && header.status == .OK
    }

    /**
        Construct a new Response for a given Alamofire result

        - Parameter result: The result from an Alamofire request
    */
    internal init(result: Result<AnyObject, NSError>) {
        // Save result so we can use it for caching purposes
        self.result = result

        switch result {
        case let .Failure(error):
            self.error = error
        case let .Success(value):
            if let result = value as? [String: AnyObject], let headerJSON = result["header"] {
                let header: Decoded<Header> = decode(headerJSON)
                switch header {
                case let .Failure(.MissingKey(key)):
                    error = NSError(domain: "StreamOne", code: -1, userInfo: ["messsage": "Missing key \(key) in header"])
                case let .Failure(.TypeMismatch(message)):
                    error = NSError(domain: "StreamOne", code: -2, userInfo: ["message": "Type mismatch in header: \(message)"])
                case let .Failure(.Custom(message)):
                    error = NSError(domain: "StreamOne", code: -2, userInfo: ["message": "Error in header: \(message)"])
                case let .Success(header):
                    self.header = header
                    self.header.allFields = result["header"] as? [String: AnyObject]
                }

                body = result["body"]
            }
        }
    }

    /**
        Retrieve the body as a typed object
    
        You should define a variable with a type that conforms to Decodable to put the result in.
        For example:
    
            struct Test: Decodable {
                let value1: String
                let value2: String
    
                static func decode(json: JSON) -> Decoded<Test> {
                    return curry(Test)
                        <^> json <| "value1"
                        <*> json <| "value2"
                }
            }

        - Returns: the body as the given type or nil if converting the body failed
    */
    public func typedBody<T: Decodable where T == T.DecodedType>() -> T? {
        return decode(body)
    }

    /**
        Retrieve the body as an array of typed objects

        This function is the same as above, but it will parse an array of objects.

        - Returns: the body as an array of the given type or nil if converting the body failed
    */
    public func typedBody<T: Decodable where T == T.DecodedType>() -> [T]? {
        return decode(body)
    }

    /**
        Retrieve the body as a typed object wrapped in a `Decoded<T>` enum
    
        This function is equivalent to `typedBody() -> T?`, but returns a `Decoded<T>`. This is
        useful to find out what went wrong with parsing the body

        - Returns: the body wrapped in a `Decoded<T>` enum
    */
    public func typedBody<T: Decodable where T == T.DecodedType>() -> Decoded<T> {
        return decode(body)
    }

    /**
        Retrieve the body as an array of typed objects wrapped in a `Decoded<T>` enum

        This function is equivalent to `typedBody() -> [T]?`, but returns a `Decoded<[T]>`. This is
        useful to find out what went wrong with parsing the body

        - Returns: the body wrapped in a `Decoded<[T]>` enum
    */
    public func typedBody<T: Decodable where T == T.DecodedType>() -> Decoded<[T]> {
        return decode(body)
    }
}