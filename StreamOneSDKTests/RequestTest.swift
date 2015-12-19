//
//  RequestTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 09-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
import Alamofire
@testable import StreamOneSDK

class TestRequest : StreamOneSDK.Request {
    // This can be used to inspect the arguments to sendRequest
    var sendRequestTestCallback: ((url: String, parameters: [String: String]) -> Void)?

    // Set to non-nil to force a timestamp
    var forcedTimestamp: NSTimeInterval?

    // Set to return a mock response
    var mockResponse: String?

    override func timestamp() -> NSTimeInterval {
        if let forcedTimestamp = forcedTimestamp {
            return forcedTimestamp
        }
        return super.timestamp()
    }

    // Overwrite sendRequest to not use Alamofire but just return the mock result
    override func sendRequest(url: String, parameters: [String : String], callback: (response: StreamOneSDK.Response) -> Void) {
        // If a test callback has been provided, call it now
        sendRequestTestCallback?(url: url, parameters: parameters)

        if let response = mockResponse {
            let json = try! NSJSONSerialization.JSONObjectWithData(response.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
            let result = Result<AnyObject, NSError>.Success(json)
            // Also process the response if one is given
            processResult(result, callback: callback)
        }
    }
}

class TestSessionRequest : StreamOneSDK.SessionRequest {
    // This can be used to inspect the arguments to sendRequest
    var sendRequestTestCallback: ((url: String, parameters: [String: String]) -> Void)?

    // Set to non-nil to force a timestamp
    var forcedTimestamp: NSTimeInterval?

    // Set to return a mock response
    var mockResponse: String?

    override func timestamp() -> NSTimeInterval {
        if let forcedTimestamp = forcedTimestamp {
            return forcedTimestamp
        }
        return super.timestamp()
    }

    // Overwrite sendRequest to not use Alamofire but just return the mock result
    override func sendRequest(url: String, parameters: [String : String], callback: (response: StreamOneSDK.Response) -> Void) {
        // If a test callback has been provided, call it now
        sendRequestTestCallback?(url: url, parameters: parameters)

        if let response = mockResponse {
            let json = try! NSJSONSerialization.JSONObjectWithData(response.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
            let result = Result<AnyObject, NSError>.Success(json)
            // Also process the response if one is given
            processResult(result, callback: callback)
        }
    }
}

class RequestTest : QuickSpec {
    override func spec() {
        let configUser = Config(authenticationType: .User(id: "user", psk: "psk"))
        var configUserDefaultAccount = Config(authenticationType: .User(id: "user", psk: "psk"))
        configUserDefaultAccount.defaultAccountId = "account"

        let configApplication = Config(authenticationType: .Application(id: "application", psk: "apppsk"))
        var configApplicationDefaultAccount = Config(authenticationType: .Application(id: "application", psk: "apppsk"))
        configApplicationDefaultAccount.defaultAccountId = "account"

        it("should be able to set an account") {
            let testSetAccount: (config: Config, setAccount: Bool, account: String?, expected: String?) -> Void = {
                config, setAccount, account, expected in
                let request = Request(command: "command", action: "action", config: config)
                if setAccount {
                    request.account = account
                }

                if let expected = expected {
                    expect(request.account).to(equal(expected))
                    expect(request.parameters["account"]).to(equal(expected))
                } else {
                    expect(request.account).to(beNil())
                    expect(request.parameters["account"]).to(beNil())
                }

                expect(request.customer).to(beNil())
                expect(request.parameters["customer"]).to(beNil())
            }

            testSetAccount(config: configUser, setAccount: true, account: "account1", expected: "account1")
            testSetAccount(config: configUserDefaultAccount, setAccount: true, account: "account1", expected: "account1")
            testSetAccount(config: configApplication, setAccount: false, account: nil, expected: nil)
            testSetAccount(config: configApplicationDefaultAccount, setAccount: false, account: nil, expected: "account")
            testSetAccount(config: configApplication, setAccount: true, account: nil, expected: nil)
            testSetAccount(config: configApplicationDefaultAccount, setAccount: true, account: nil, expected: nil)
        }

        it("should be able to set a customer") {
            let testSetCustomer: (config: Config, setCustomer: Bool, customer: String?, expected: String?, expectedAccount: String?) -> Void = {
                config, setCustomer, customer, expected, expectedAccount in
                let request = Request(command: "command", action: "action", config: config)
                if setCustomer {
                    request.customer = customer
                }

                if let expected = expected {
                    expect(request.customer).to(equal(expected))
                    expect(request.parameters["customer"]).to(equal(expected))
                } else {
                    expect(request.customer).to(beNil())
                    expect(request.parameters["customer"]).to(beNil())
                }

                if let expectedAccount = expectedAccount {
                    expect(request.account).to(equal(expectedAccount))
                    expect(request.parameters["account"]).to(equal(expectedAccount))
                } else {
                    expect(request.account).to(beNil())
                    expect(request.parameters["account"]).to(beNil())
                }
            }

            testSetCustomer(config: configUser, setCustomer: true, customer: "customer1", expected: "customer1", expectedAccount: nil)
            testSetCustomer(config: configUserDefaultAccount, setCustomer: true, customer: "customer1", expected: "customer1", expectedAccount: nil)
            testSetCustomer(config: configApplication, setCustomer: false, customer: nil, expected: nil, expectedAccount: nil)
            testSetCustomer(config: configApplicationDefaultAccount, setCustomer: false, customer: nil, expected: nil, expectedAccount: "account")
            testSetCustomer(config: configApplication, setCustomer: true, customer: nil, expected: nil, expectedAccount: nil)
            testSetCustomer(config: configApplicationDefaultAccount, setCustomer: true, customer: nil, expected: nil, expectedAccount: nil)
        }

        it("should set the correct parameters from the config") {
            let testConfig: (config: Config, expectedType: String) -> Void = {
                config, expectedType in
                let request = Request(command: "command", action: "action", config: config)

                expect(request.parameters["authentication_type"]).to(equal(expectedType))
                expect(request.parametersForSigning()[expectedType]).to(equal(config.authenticationType.id))
                expect(request.signingKey()).to(equal(config.authenticationType.psk))
            }

            testConfig(config: configUser, expectedType: "user")
            testConfig(config: configUserDefaultAccount, expectedType: "user")
            testConfig(config: configApplication, expectedType: "application")
            testConfig(config: configApplicationDefaultAccount, expectedType: "application")
        }

        it("should send the correct data in a request") {
            enum ActorToSet {
                case DoNotChange
                case Account(account: String)
                case Accounts(accounts: [String])
                case ClearAccount
                case Customer(customer: String)

                func apply(request: StreamOneSDK.Request) {
                    switch self {
                    case .DoNotChange:
                        // Nothing
                        break
                    case let .Account(account: account):
                        request.account = account
                    case let .Accounts(accounts: accounts):
                        request.accounts = accounts
                    case .ClearAccount:
                        request.account = nil
                    case let .Customer(customer: customer):
                        request.customer = customer
                    }
                }
            }

            let testExecute: (config: Config, command: String, action: String, actorToSet: ActorToSet, timestamp: NSTimeInterval?, arguments: [String: Argument], expectedUrl: String) -> Void = {
                config, command, action, actorToSet, timestamp, arguments, expectedUrl in

                let request = TestRequest(command: command, action: action, config: config)
                for (key, value) in arguments {
                    request.setArgument(key, value: value)
                }

                actorToSet.apply(request)

                request.forcedTimestamp = timestamp

                var done = false

                // Check correct URL and parameters
                request.sendRequestTestCallback = {
                    url, parameters in
                    expect(url).to(equal(expectedUrl))
                    var stringArguments: [String: String] = [:]
                    for (key, value) in arguments {
                        stringArguments[key] = value.value
                    }
                    expect(parameters).to(equal(stringArguments))
                    done = true
                }

                request.execute {
                    response in
                }

                expect(done).toEventually(beTrue())
            }

            testExecute(config: configUser, command: "item", action: "view", actorToSet: .DoNotChange, timestamp: 1234, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?api=3&authentication_type=user&format=json&signature=a3a030d15fd3faef49fd1340cb474113645628dc&timestamp=1234&user=user")
            testExecute(config: configUser, command: "item", action: "view", actorToSet: .DoNotChange, timestamp: 5678, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?api=3&authentication_type=user&format=json&signature=6e553a65157cadab99a32b9a893e4b87c3c6de4d&timestamp=5678&user=user")
            testExecute(config: configApplication, command: "item", action: "view", actorToSet: .DoNotChange, timestamp: 1234, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?api=3&application=application&authentication_type=application&format=json&signature=588b4aaa105678d5de14b9f87e431c9cc7fe458c&timestamp=1234")
            testExecute(config: configUser, command: "user", action: "create", actorToSet: .DoNotChange, timestamp: 1234, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/user/create?api=3&authentication_type=user&format=json&signature=965e9d965aeda81d3aa9a3e0eda4793b0b3412c7&timestamp=1234&user=user")
            testExecute(config: configUser, command: "item", action: "view", actorToSet: .DoNotChange, timestamp: 1234, arguments: ["x": "ABxu233"],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?api=3&authentication_type=user&format=json&signature=02b3c66918d4d1cce6f1558ee2470c341dfe40db&timestamp=1234&user=user")
            testExecute(config: configUserDefaultAccount, command: "item", action: "view", actorToSet: .DoNotChange, timestamp: 1234, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?account=account&api=3&authentication_type=user&format=json&signature=3006f0b64c8f43beda1ae231834b5d64829d4124&timestamp=1234&user=user")
            testExecute(config: configUserDefaultAccount, command: "item", action: "view", actorToSet: .Account(account: "account1"), timestamp: 1234, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?account=account1&api=3&authentication_type=user&format=json&signature=fa8b0d01574be985f018f4fe7059b10b80aacbf1&timestamp=1234&user=user")
            testExecute(config: configUserDefaultAccount, command: "item", action: "view", actorToSet: .Accounts(accounts: ["account1", "account2"]), timestamp: 1234, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?account=account1%2Caccount2&api=3&authentication_type=user&format=json&signature=a35a4d37e8102113ac34ba1986d34370d59737a1&timestamp=1234&user=user")
            testExecute(config: configUserDefaultAccount, command: "item", action: "view", actorToSet: .Customer(customer: "customer1"), timestamp: 1234, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?api=3&authentication_type=user&customer=customer1&format=json&signature=741337e9c6811836762d9116b76b56849e11791c&timestamp=1234&user=user")
            testExecute(config: configUserDefaultAccount, command: "item", action: "view", actorToSet: .ClearAccount, timestamp: 1234, arguments: [:],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?api=3&authentication_type=user&format=json&signature=a3a030d15fd3faef49fd1340cb474113645628dc&timestamp=1234&user=user")
            testExecute(config: configUser, command: "item", action: "view", actorToSet: .DoNotChange, timestamp: 1234, arguments: ["searchtitle": "test", "archived": false],
                expectedUrl: "https://api.streamonecloud.net/api/item/view?api=3&authentication_type=user&format=json&signature=a9bd2d16054ea481b2004627ee3d6748b8fe3d88&timestamp=1234&user=user")
        }

        it("should use the cache if and only if a response is cacheable") {
            let testCache: (response: String, shouldBeCached: Bool) -> Void = {
                response, shouldBeCached in
                var config = configUser

                config.requestCache = MemoryCache()

                // Used to get the cache key
                let request = TestRequest(command: "command", action: "action", config: config)
                request.setArgument("test", value: response)

                let arguments = ["test": response]
                expect(request.cacheKey()).to(equal("s1:request:/api/command/action?api=3&authentication_type=user&format=json#\(arguments.urlEncode())"))

                expect(config.requestCache.getKey(request.cacheKey())).to(beNil())

                request.mockResponse = response

                var done = false
                request.execute { response in
                    expect(response.cacheable).to(equal(shouldBeCached))
                    expect(response.fromCache).to(beFalse())
                    if shouldBeCached {
                        let resultJson = try! NSJSONSerialization.dataWithJSONObject(response.result.value!, options: [])
                        let cacheJson = try! NSJSONSerialization.dataWithJSONObject(config.requestCache.getKey(request.cacheKey())!, options: [])
                        expect(resultJson).to(equal(cacheJson))
                    } else {
                        expect(config.requestCache.getKey(request.cacheKey())).to(beNil())
                    }
                    done = true

                    // Request again, to see if it came from the cache if expected
                    var secondDone = false

                    request.execute { secondResponse in
                        expect(secondResponse.cacheable).to(equal(shouldBeCached))
                        expect(secondResponse.fromCache).to(equal(shouldBeCached))

                        if shouldBeCached {
                            let resultJson = try! NSJSONSerialization.dataWithJSONObject(secondResponse.result.value!, options: [])
                            let cacheJson = try! NSJSONSerialization.dataWithJSONObject(config.requestCache.getKey(request.cacheKey())!, options: [])
                            expect(resultJson).to(equal(cacheJson))
                        } else {
                            expect(config.requestCache.getKey(request.cacheKey())).to(beNil())
                        }

                        secondDone = true
                    }

                    expect(secondDone).toEventually(beTrue())
                }

                expect(done).toEventually(beTrue())
            }

            testCache(response: "{\"header\":{\"status\":0,\"statusmessage\":\"ok\"},\"body\":null}", shouldBeCached: false)
            testCache(response: "{\"header\":{\"status\":0,\"statusmessage\":\"ok\",\"cacheable\":false},\"body\":null}", shouldBeCached: false)
            testCache(response: "{\"header\":{\"status\":0,\"statusmessage\":\"ok\",\"cacheable\":true},\"body\":null}", shouldBeCached: true)
        }
    }
}