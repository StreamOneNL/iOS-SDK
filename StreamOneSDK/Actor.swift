//
//  Actor.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Alamofire

/**
    An actor corresponding to a user (with or without session) or application.

    Besides information about whether this actor is a user or application, one can also set an
    account, multiple accounts or a customer for the actor

    Note that some functions in this class have a callback with a `ResultOrError` argument. That
    argument will either contain the desired value or an error if communication with the API failed.
*/
public class Actor {
    /**
        The configuration to use for this Actor
    */
    public let config: Config

    /**
        The session to use for this Actor; nil if not using a session
    */
    public let session: Session?

    /**
        The cache to use for storing data about tokens and roles
    */
    public let tokenCache: Cache

    /**
        The customer to use for this Actor
    */
    public var customer: String? {
        get {
            return _customer
        }
        set {
            _customer = newValue
            _accounts = []
        }
    }

    /**
        Private storage for `customer`
    */
    private var _customer: String? = nil

    /**
        The account(s) to use for this Actor
    */
    public var accounts: [String] {
        get {
            return _accounts
        }
        set {
            _accounts = newValue
            _customer = nil
        }
    }

    /**
        Private storage for `accounts`
    */
    private var _accounts: [String] = []

    /**
        Construct a new actor object
    
        - Parameter config: The configuration to use for this actor
        - Parameter session: The session to use for this actor; if nil, it will use authentication
                             information from the configuration
    */
    public init(config: Config, session: Session? = nil) {
        self.config = config
        self.session = session

        if let session = session where config.useSessionForTokenCache {
            tokenCache = SessionCache(session: session)
        } else {
            tokenCache = config.tokenCache
        }

        if let account = config.defaultAccountId {
            accounts = [account]
        }
    }

    /**
        Create a new request to the API for this actor

        - Parameter command: The API command to call
        - Parameter action: The action to perform on the API command
        - Returns: A request to the given command and action for the given actor
    */
    public func newRequest(command command: String, action: String) throws -> Request {
        let request = try createCleanRequest(command: command, action: action)

        if let customer = customer {
            request.customer = customer
        } else if accounts.count > 0 {
            request.accounts = accounts
        } else {
            // This call is done to overwrite the default account for the config, if it is set
            request.account = nil
        }

        return request
    }

    /**
        Check if this actor has a given token

        Tokens will be fetched from the StreamOne API.

        Note that the callback will be called on the same thread as the caller of this function.

        - Parameter token: The token to check for
        - Parameter callback: The callback that will be called when it is known whether this actor
                              has the given token
    */
    public final func hasToken(token: String, callback: (hasToken: ResultOrError<Bool>) -> Void) throws {
        try getRoles { roles in
            switch roles {
            case let .Error(err):
                callback(hasToken: .Error(err))
            case let .Result(roles):
                if self.shouldCheckMyTokens(roles) {
                    do {
                        try self.checkMyTokens(token) { hasToken in
                            callback(hasToken: hasToken)
                        }
                    } catch let err {
                        callback(hasToken: .Error(err))
                    }
                } else if self.accounts.count == 0 {
                    callback(hasToken: .Result(self.checkNonAccountHasToken(roles, token: token)))
                } else {
                    callback(hasToken: .Result(self.checkAccountHasToken(roles, token: token)))
                }
            }
        }
    }

    /**
        Get all the tokens for the current actor

        Note that the callback will be called on the same thread as the caller of this function.

        - Parameter callback: The callback that will be called when all tokens for the current actor
                              have been fetched
    */
    public final func getMyTokens(callback: (tokens: ResultOrError<[String]>) -> Void) throws {
        if let tokens = loadMyTokensFromCache() {
            callback(tokens: .Result(tokens))
        } else {
            try loadMyTokensFromApi { tokens in
                callback(tokens: tokens)
            }
        }
    }

    /**
        Get the roles for the current configuration and session

        Note that the callback will be called on the same thread as the caller of this function.

        - Parameter callback: The callback that will be called when the roles for the current actor
                              have been fetched
    */
    public final func getRoles(callback: (roles: ResultOrError<[RoleInActor]>) -> Void) throws {
        let actorType: ActorType
        if session != nil || config.authenticationType.isUserAuth {
            actorType = .User
        } else {
            actorType = .Application
        }

        if let roles = loadRolesFromCache(actorType) {
            callback(roles: .Result(roles))
        } else {
            try loadRolesFromApi(actorType) { rolesInActor in
                callback(roles: rolesInActor)
            }
        }
    }

    /**
        Create a 'clean' request for a given command and action

        This will make sure a session request is used if a session is active. No actor or customer
        will be set on this request, even if the actor does have them.

        - Parameter command: The API command to call
        - Parameter action: The action to perform on the API command
        - Returns: A request to the given command and action
    */
    internal func createCleanRequest(command command: String, action: String) throws -> Request {
        if let session = session {
            return try session.newRequest(command: command, action: action)
        } else {
            return config.requestFactory.newRequest(command: command, action: action, config: config)
        }
    }

    /**
        Check whether the `api/mytokens action should be used to check for tokens

        There might not be enough information yet in the list of roles for the current application or
        user to determine the tokens for this actor. This method detects in which cases a more
        specific list of tokens needs to be requested.

        The main issue is that there is no mapping between accounts and customers. Consider a user
        that has a role in a specific account and an actor wants to do a request in an account.
        We then have no way to know if that account belongs to the customer, which we need to know
        to be able to get the tokens of that account (as these should include any tokens for the
        customer of that account). To remedy this, we can request the active tokens specifc for this
        case.

        This method is used to detect this case.

        - Parameter roles: The roles as returned from the `getRoles` function
        - Returns: True if and only if the `api/mytokens` action should be checked for tokens
    */
    internal func shouldCheckMyTokens(roles: [RoleInActor]) -> Bool {
        if accounts.count > 0 {
            for role in roles {
                if role.customer != nil {
                    return true
                }
            }
        }

        return false
    }

    /**
        Use the tokens of the current actor to check if the current actor has the given token
        
        This might request the tokens of the current actor from the API, if not cached

        - Parameter token: The token to check for
        - Parameter callback: The callback to call when the token has been checked
    */
    internal func checkMyTokens(token: String, callback: (hasToken: ResultOrError<Bool>) -> Void) throws {
        try getMyTokens { tokens in
            // Return whether the tokens contain the argument
            callback(hasToken: tokens.map { $0.contains(token) })
        }
    }

    /**
        Load the tokens for the current actor from the cache

        - Returns: The tokens for the current actor, loaded from the cache. If the cache does not
                   contain the roles nil will be returned
    */
    internal func loadMyTokensFromCache() -> [String]? {
        if let cacheData = tokenCache.getKey(tokensCacheKey()) {
            let response = Response(result: .Success(cacheData))
            return response.typedBody()
        }
        return nil
    }

    /**
        Determine the key to use for caching tokens

        - Returns: A cache-key used for tokens
    */
    internal func tokensCacheKey() -> String {
        return "s1:tokens:\(config.authenticationType):\(customer):\(accounts)"
    }

    /**
        Load the tokens for the current actor from the API

        This will also store the tokens in the cache

        - Parameter callback: The callback to call when loading the tokens is complete
    */
    internal func loadMyTokensFromApi(callback: (tokens: ResultOrError<[String]>) -> Void) throws {
        let request = try newRequest(command: "api", action: "mytokens")
        request.execute { response in
            guard response.success else {
                callback(tokens: .Error(RequestError.fromResponse(response)))
                return
            }

            guard let tokens: [String] = response.typedBody() else {
                callback(tokens: ResultOrError.Error(RequestError.fromResponse(response)))
                return
            }

            self.tokenCache.setKey(self.tokensCacheKey(), value: response.result.value!)

            callback(tokens: .Result(tokens))
        }
    }

    /**
        Check if an actor not having an account has a given token

        This function checks whether the token is available for an actor having a customer or a global actor

        - Parameter roles: The roles as returned from the `getRoles` function
        - Parameter token: The token to check
        - Returns: True if and only if the current actor has the given token in any role, taking
                   into account customers
    */
    internal func checkNonAccountHasToken(roles: [RoleInActor], token: String) -> Bool {
        for role in roles {
            if checkRoleForToken(role: role, token: token, customer: customer, account: nil) {
                return true
            }
        }

        return false
    }

    /**
        Check if an actor having at least one account has a given token

        This function checks whether the token is available for all customers of the current actor

        - Parameter roles: The roles as returned from the `getRoles` function
        - Parameter token: The token to check
        - Returns: True if and only if the current actor has the given token in any role, taking
                   into account customers and accounts
    */
    internal func checkAccountHasToken(roles: [RoleInActor], token: String) -> Bool {
        var numOk = 0
        for account in accounts {
            for role in roles {
                if checkRoleForToken(role: role, token: token, customer: nil, account: account) {
                    numOk++
                    break
                }
            }
        }

        return numOk == accounts.count
    }

    /**
        Check if a given role has a specific token in an account or customer

        - Parameter role: The role as returned from the `getRoles` function
        - Parameter token: The token to check
        - Parameter customer: The customer to use for checking
        - Parameter account: The account to use for checking
        - Returns: True if and only if the given role has the given token and is a super-role of the
                   given customer and account
    */
    internal func checkRoleForToken(role role: RoleInActor, token: String, customer: String?, account: String?) -> Bool {
        return roleIsSuperOf(role, customer: customer, account: account) && role.role.tokens.contains(token)
    }

    /**
        Load the roles of the current configuration and session from the cache

        - Parameter actorType: The actor type to load roles for
        - Returns: The roles for the current configuration and session, loaded from the cache. If
                   the cache does not contain the roles nil will be returned
    */
    internal func loadRolesFromCache(actorType: ActorType) -> [RoleInActor]? {
        if let cacheData = tokenCache.getKey(rolesCacheKey(actorType)) {
            let response = Response(result: .Success(cacheData))
            return response.typedBody()
        }
        return nil
    }

    /**
        Determine the key to use for caching roles

        - Parameter actorType: The actor type to determine the cache key for
        - Returns: A cache-key used for roles
    */
    internal func rolesCacheKey(actorType: ActorType) -> String {
        return "s1:roles:\(actorType):\(config.authenticationType.id)"
    }

    /**
        Load the roles of the current configuration and session from the API

        - Parameter actorType: The actor type to load roles for
        - Parameter callback: The callback that will be called when the roles have been loaded
    */
    internal func loadRolesFromApi(actorType: ActorType, callback: (roles: ResultOrError<[RoleInActor]>) -> Void) throws {
        let request = try newRequest(command: actorType.apiCommand, action: "getmyroles")
        request.execute { response in
            guard response.success else {
                callback(roles: .Error(RequestError.fromResponse(response)))
                return
            }

            guard let roles: [RoleInActor] = response.typedBody() else {
                callback(roles: ResultOrError.Error(RequestError.fromResponse(response)))
                return
            }

            self.tokenCache.setKey(self.rolesCacheKey(actorType), value: response.result.value!)

            callback(roles: .Result(roles))
        }
    }

    /**
        Determine if a given role is a super-role of a given customer and/or account

        A role is a super-role if:
        - It is a role without a customer or account
        - It is a role with a customer (and without an account) and the customer matches the given argument
        - It is a role with an account and the account matches the given argument

        Note that there is a fourth case: if it is a role with a customer, an account is given in the
        arguments and that account belongs to the customer. This case is not handled here, as finding
        out if an account belongs to a customer can not be done.

        See also `shouldCheckMyTokens`

        - Parameter role: The role as returned from the `getRoles` function
        - Parameter $customer: The customer to check for or nil if no customer
        - Parameter $account: The account to check for or nil if no account
        - Returns: True if and only if the given role is a super-role of the given arguments
    */
    internal func roleIsSuperOf(role: RoleInActor, customer: String?, account: String?) -> Bool {
        if role.customer == nil && role.account == nil {
            return true
        }

        if role.account == nil && customer != nil && role.customer?.id == customer {
            return true
        }

        if role.account != nil && account != nil && role.account?.id == account {
            return true
        }

        return false
    }
}