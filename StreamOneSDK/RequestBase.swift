//
//  RequestBase.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 08-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Alamofire
import Crypto

/**
    The base class for Request, abstracting authentication details

    This abstract class provides the basics for doing requests to the StreamOne API, and abstracts
    the authentication details. This allows for subclasses that just implement a valid
    authentication scheme, without having to re-implement all the basics of doing requests. For
    normal use, the Request class provides authentication using users or applications, and
    SessionRequest provides authentication for requests executed within a session.
*/
public class RequestBase {
    /**
        The API command to call
    */
    public final let command: String

    /**
        The action to perform on the API command called
    */
    public final let action: String
    
    /**
        The Config object with information for this request
    */
    public let config: Config

    /**
    The parameters to use for the API request

    The parameters are the GET-parameters sent, and include meta-data for the request such
    as API-version, output type, and authentication parameters. They cannot directly be set.
    */
    internal final var parameters: [String: String]

    /**
        The arguments to use for the API request

        The arguments are the POST-data sent, and represent the arguments for the specific API
        command and action called.
    */
    private(set) public final var arguments = [String: String]()

    /**
        The protocol to use for requests, e.g. 'http'
    
        Setting this property overrides any protocol set in the API URL. The protocol must not
        contain trailing '://'
    */
    public final var requestProtocol: String?

    /**
        Initialize a request for a given command and action

        - Parameter command: The command to use
        - Parameter action: The action to use
        - Parameter confi: The configuration to use
    */
    init(command: String, action: String, config: Config) {
        self.command = command
        self.action = action
        self.config = config

        parameters = [
            "api": "3",
            "format": "json"
        ]
    }

    /**
        The accounts to use for this request
    */
    public var accounts: [String] {
        get {
            if let accounts = parameters["account"] {
                return accounts.componentsSeparatedByString(",")
            }

            return []
        }
        set {
            if newValue.count > 0 {
                parameters["account"] = newValue.joinWithSeparator(",")
            } else {
                parameters.removeValueForKey("account")
            }
            if parameters["customer"] != nil {
                parameters.removeValueForKey("customer")
            }
        }
    }

    /**
        The account to use for this request
    
        If multiple accounts are set the first one will be returned if getting this value
    */
    public var account: String? {
        get {
            if let accounts = parameters["account"] {
                let accountsArray = accounts.componentsSeparatedByString(",")
                if accountsArray.count > 0 {
                    return accountsArray[0]
                }
            }

            return nil
        }
        set {
            if let account = newValue {
                parameters["account"] = account
            } else {
                parameters.removeValueForKey("account")
            }
            if parameters["customer"] != nil {
                parameters.removeValueForKey("customer")
            }
        }
    }

    /**
        The customer to use for this request
    */
    public var customer: String? {
        get {
            if let customer = parameters["customer"] {
                return customer
            }

            return nil
        }
        set {
            parameters["customer"] = newValue
            if parameters["account"] != nil {
                parameters.removeValueForKey("account")
            }
        }
    }

    /**
        The timezone to use for this request
    */
    public var timezone: NSTimeZone? {
        get {
            if let timezone = parameters["timezone"] {
                return NSTimeZone(name: timezone)
            }

            return nil
        }
        set {
            if let timezone = newValue {
                parameters["timezone"] = timezone.name
            } else {
                parameters.removeValueForKey("timezone")
            }
        }
    }

    /**
        Set the value of a single argument

        - Parameter argument: The name of the argument
        - Parameter value: The new value for the argument
        - Returns: A reference to this object, to allow chaining
    */
    public final func setArgument(argument: String, value: Argument) -> Self {
        arguments[argument] = value.value

        return self
    }

    /**
        Set the value of a single argument

        - Parameter argument: The name of the argument
        - Parameter value: The new value for the argument. nil will be translated to an empty string
        - Returns: A reference to this object, to allow chaining
    */
    public final func setArgument(argument: String, value: Argument?) -> Self {
        if let value = value {
            arguments[argument] = value.value
        } else {
            arguments[argument] = ""
        }

        return self
    }

    /**
    Set the value of a single argument

    - Parameter argument: The name of the argument
    - Parameter value: The new value for the argument. It will be joined by comma's
    - Returns: A reference to this object, to allow chaining
    */
    public final func setArgument(argument: String, value: [Argument]) -> Self {
        arguments[argument] = value.map { $0.value }.joinWithSeparator(",")

        return self
    }

    /**
        Retrieves the protocol to use for requests, with trailing ://

        If a protocol has been set using the protocol propert, that protocol is used. Otherwise, if a
        protocol is present in the API URL, that protocol is used. If neither gives a valid
        protocol, the default of 'https' is used.

        This method returns the protocol with trailing '://', while the protocol property requires
        a protocol without trailing '://'

        - Returns: The protocol to use
    */
    public final func usedProtocol() -> String {
        if let requestProtocol = requestProtocol {
            return requestProtocol + "://"
        }

        // Use protocol from API URL if given
        if let apiProtocol = getApiProtocolHost().apiProtocol {
            return apiProtocol + "://"
        }

        // No protocol set in any way; default to HTTP
        return "https://"
    }

    /**
        Retrieve the API protocol, host and prefix as retrieved from the apiUrl() method

        The API URL is split into up to 3 parts, the protocol, host and prefix. The following
        forms of URLs, as provided by apiUrl(), are supported:

        - `protocol://host/prefix`
        - `protocol://host`
        - `host/prefix`
        - `host`

        - Returns: A tuple with 3 elements:
                   - protocol: a string with the protocol specified in the API URL, or nil if not
                   - host: a string with the host as specified in the API URL
                   - prefix: a possibly empty string with the path prefix of the URL; contains
                     basically everything after the host
    */
    internal final func getApiProtocolHost() -> (apiProtocol: String?, host: String, prefix: String) {
        // We know the regex is valid, so it will never throw
        let regex = try! Regex("^(?:([a-zA-Z0-9\\+\\.-]+):/?/?)?([^/]*)(.*)$")
        let url = apiUrl()
        let matches = regex.matches(url)

        assert(matches.count == 4, "API URL is in invalid format")

        let apiProtocol: String?
        if matches[1].lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            apiProtocol = matches[1]
        } else {
            apiProtocol = nil
        }

        return (apiProtocol, matches[2], matches[3])
    }

    /**
        Execute the prepared request

        This will sign the request, send it to the API server, and process the response. When done,
        it will call the provided callback with the response.

        Note that the callback will be called on the same thread as the caller of this function.

        - Parameter callback: The callback to call when processing the response is done
    */
    public func execute(callback: (response: Response) -> Void) {
        let protoHost = getApiProtocolHost()
        let server = usedProtocol() + protoHost.host + protoHost.prefix
        let url = server + path() + "?" + signedParameters().urlEncode()

        sendRequest(url, parameters: arguments, callback: callback)
    }

    /**
        Actually send the request over HTTP

        - Parameter url: The URL to send a request to
        - Parameter arguments: The POST parameters to set
        - Parameter callback: The callback to call when the request is done
    */
    internal func sendRequest(url: String, parameters: [String: String], callback: (response: Response) -> Void) {
        Alamofire
            .request(.POST, url, parameters: parameters)
            .responseJSON {
                response in

                self.processResult(response.result, callback: callback)
            }
    }

    /**
        Process the result from a request

        - Parameter result: The result from a HTTP request
        - Parameter callback: The callback to call when processing the result is done
    */
    internal func processResult(result: Result<AnyObject, NSError>, callback: (response: Response) -> Void) {
        let response = Response(result: result)
        callback(response: response)
    }

    /**
        This function returns the base URL of the API, with optional protocol and without trailing /
    
        - Returns: The base URL of the API
    */
    internal func apiUrl() -> String {
        return config.apiUrl
    }

    /**
        This function will return the key used for signing the request

        Subclasses can overwrite this function to provide the correct key

        - Returns: The key used for signing
    */
    internal func signingKey() -> String {
        return config.authenticationType.psk
    }

    /**
        Retrieve the path to use for the API request

        - Returns: The path for the API request
    */
    internal final func path() -> String {
        return "/api/" + command + "/" + action
    }

    /**
        Retrieve the parameters used for signing

        Subclasses can add the parameters that are used specifically for those classes

        - Returns: A dictionary containing the parameters needed for signing
    */
    internal func parametersForSigning() -> [String: String] {
        var parameters = self.parameters
        parameters["timestamp"] = Int(timestamp()).description

        return parameters
    }

    /**
        Get the current timestamp
    
        - Returns: The current timestamp
    */
    internal func timestamp() -> NSTimeInterval {
        return NSDate().timeIntervalSince1970
    }

    /**
        Retrieve the signed parameters for the current request

        This method will lookup the current path, parameters and arguments, calculates the
        authentication parameters, and returns the new set of parameters.

        - Returns: A dictionary containing the defined parameters, as well as authentication parameters
    */
    private func signedParameters() -> [String: String] {
        var parameters = parametersForSigning()
        parameters["signature"] = signature()

        return parameters
    }

    /**
        Returns the signature for the current request

        - Returns: The signature for the current request
    */
    private final func signature() -> String {
        let parameters = parametersForSigning()

        let url = path() + "?" + parameters.urlEncode() + "&" + arguments.urlEncode()
        let key = signingKey()

        return HMAC.sign(message: url, algorithm: .SHA1, key: key)!
    }
}