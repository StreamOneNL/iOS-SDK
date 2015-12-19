//
//  Request.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 25-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Alamofire

/**
    Execute a request to the StreamOne API

    This class represents a request to the StreamOne API. To execute a new request, first construct
    an instance of this class by specifying the command and action to the constructor. The various
    arguments and options of the request can then be specified and then the request can be actually
    sent to the StreamOne API server by executing the request. Requests will always be sent asynchronously
    and a callback will be called upon completion

    This class only supports version 3 of the StreamOne API. All configuration is done using the
    Config class.

    This class inherits from RequestBase, which is a very basic request-class implementing
    only the basics of setting arguments and parameters, and generic signing of requests. This
    class adds specific signing for users, applications and sessions, as well as a basic caching
    mechanism.
*/
public class Request : RequestBase {
    /**
        Initialize a request for a given command and action

        - Parameter command: The command to use
        - Parameter action: The action to use
        - Parameter config: The configuration to use
    */
    public override init(command: String, action: String, config: Config) {
        super.init(command: command, action: action, config: config)

        // Check if a default account is specified and set it as a parameter. Can later be overridden
        if let account = config.defaultAccountId {
            parameters["account"] = account
        }

        // Set correct authentication_type parameter
        switch config.authenticationType {
        case .User(id: _, psk: _):
            parameters["authentication_type"] = "user"
        case .Application(id: _, psk: _):
            parameters["authentication_type"] = "application"
        }
    }

    /**
        Retrieve the parameters used for signing

        - Returns: A dictionary containing the parameters needed for signing
    */
    override func parametersForSigning() -> [String : String] {
        var parameters = super.parametersForSigning()

        switch (config.authenticationType) {
        case let .User(id: id, psk: _):
            parameters["user"] = id
        case let .Application(id: id, psk: _):
            parameters["application"] = id
        }

        return parameters
    }

    /**
        Execute the prepared request

        If the request can be retrieved from the cache, it will do so.
        Otherwise, this will sign the request, send it to the API server, and process the response.
        When done, it will call the provided callback with the response.
    
        Note that the callback will be called on the same thread as the caller of this function.

        - Parameter callback: The callback to call when processing the response is done
    */
    override public func execute(callback: (response: Response) -> Void) {
        if let response = retrieveFromCache() {
            callback(response: response)
        } else {
            super.execute(callback)
        }
    }

    /**
        Process the result from a request
    
        This will cache the response if possible before calling the callback

        - Parameter result: The result from a HTTP request
        - Parameter callback: The callback to call when processing the result is done
    */
    override func processResult(result: Result<AnyObject, NSError>, callback: (response: Response) -> Void) {
        super.processResult(result) { (response) -> Void in
            self.saveCache(response)
            callback(response: response)
        }
    }

    /**
        Determine the key to use for caching

        - Returns: the key to use for caching
    */
    internal func cacheKey() -> String {
        return "s1:request:\(path())?\(parameters.urlEncode())#\(arguments.urlEncode())"
    }

    /**
        Attempt to retrieve the response for this request from the cache

        - Returns: The cached response if it was found in the cache; nil otherwise
    */
    internal func retrieveFromCache() -> Response? {
        let cache = config.requestCache

        let cachedData = cache.getKey(cacheKey())
        if let cachedData = cachedData {
            let result = Result<AnyObject, NSError>.Success(cachedData)
            var response = Response(result: result)
            response.fromCache = true
            response.cacheAge = cache.ageOfKey(cacheKey())
            return response
        }

        return nil
    }

    /**
        Save the result of the current request to the cache

        This method only saves to cache if the request is cacheable, and if the request was not
        retrieved from the cache.
    */
    internal func saveCache(response: Response) {
        if response.cacheable && !response.fromCache {
            switch response.result {
            case let .Success(object):
                let cache = config.requestCache
                cache.setKey(cacheKey(), value: object)
            default:
                break
            }
        }
    }
}