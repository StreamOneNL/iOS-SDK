//
//  Argument.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 08-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Protocol for arguments to a request
*/
public protocol Argument {
    /**
        The actual value to send to the API
    */
    var value: String { get }
}

/**
    Let String conform to the Argument protocol
*/
extension String: Argument {
    /**
        The actual value to send to the API
    */
    public var value: String {
        return self
    }
}

/**
Let Int conform to the Argument protocol
*/
extension Int: Argument {
    /**
        The actual value to send to the API
    */
    public var value: String {
        return "\(self)"
    }
}

/**
    Let Double conform to the Argument protocol
*/
extension Double: Argument {
    /**
        The actual value to send to the API
    */
    public var value: String {
        return "\(self)"
    }
}

/**
    Let Float conform to the Argument protocol
*/
extension Float: Argument {
    /**
        The actual value to send to the API
    */
    public var value: String {
        return "\(self)"
    }
}

/**
    Let Bool conform to the Argument protocol
*/
extension Bool: Argument {
    /**
        The actual value to send to the API
    */
    public var value: String {
        return self ? "1" : "0"
    }
}