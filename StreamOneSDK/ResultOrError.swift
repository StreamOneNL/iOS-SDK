//
//  ResultOrError.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/// Enum containing either a result or an error
public enum ResultOrError<T> {
    /// A successfull result
    case Result(T)
    /// An error
    case Error(ErrorType)

    /**
        Map this result to another result

        - Parameter f: The function to use to map the result
        - Returns: The mapped result if self is a result or self if it is an error
    */
    public func map<S>(f: T -> S) -> ResultOrError<S> {
        switch self {
        case let .Error(err):
            return .Error(err);
        case let .Result(result):
            return .Result(f(result))
        }
    }

    /**
        The value for this result or nil if this result is an error
    */
    public var value: T? {
        switch self {
        case .Error:
            return nil
        case let .Result(result):
            return result
        }
    }

    /**
        The error for this result or nil if no error occurred
    */
    public var error: ErrorType? {
        switch self {
        case let .Error(err):
            return err
        case .Result:
            return nil
        }
    }
}