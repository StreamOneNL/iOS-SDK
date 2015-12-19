//
//  RequestBaseTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 09-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class TestRequestBase : RequestBase {
    var testApiUrl = "http://api.test"
    var testSigningKey = "PSK"

    override func apiUrl() -> String {
        return testApiUrl
    }

    override func signingKey() -> String {
        return testSigningKey
    }
}

class RequestBaseTest : QuickSpec {
    override func spec() {
        let config = Config(authenticationType: .User(id: "id", psk: "psk"))

        it("should set the correct parameters on construction") {
            let request = RequestBase(command: "command", action: "action", config: config)

            expect(request.parameters["api"]).to(equal("3"))
            expect(request.parameters["format"]).to(equal("json"))
        }

        it("should set the command and action correctly in the path") {
            let testCommandAction: (command: String, action: String) -> Void = {
                command, action in
                let path = "/api/" + command + "/" + action
                let request = RequestBase(command: command, action: action, config: config)
                expect(request.path()).to(equal(path))
            }

            testCommandAction(command: "command", action: "action")
            testCommandAction(command: "item", action: "view")
        }

        it("should be able to set the account") {
            let testSetAccount: (account: String) -> Void = {
                account in
                let request = RequestBase(command: "command", action: "action", config: config)
                request.account = account

                expect(request.account).to(equal(account))
                expect(request.parameters["account"]).to(equal(account))
            }

            testSetAccount(account: "ACCOUNT")
            testSetAccount(account: "a")
            testSetAccount(account: "kYxEV4oaRQg2")
            testSetAccount(account: "A4pMV-sKDVEy")
            testSetAccount(account: "A4pMV_sKDVEy")
            testSetAccount(account: "_A4pMVsKDVEy")
            testSetAccount(account: "-A4pMVsKDVEy")
            testSetAccount(account: "A4pMVsKDVEy_")
            testSetAccount(account: "A4pMVsKDVEy-")
        }

        it("should be able to set multiple accounts") {
            let testSetAccounts: (accounts: [String]) -> Void = {
                accounts in
                let request = RequestBase(command: "command", action: "action", config: config)
                request.accounts = accounts

                expect(request.accounts).to(equal(accounts))
                expect(request.parameters["account"]).to(equal(accounts.joinWithSeparator(",")))
            }

            testSetAccounts(accounts: ["ACCOUNT", "a"])
            testSetAccounts(accounts: ["kYxEV4oaRQg2"])
            testSetAccounts(accounts: ["A4pMV-sKDVEy", "A4pMV_sKDVEy"])
            testSetAccounts(accounts: ["-A4pMVsKDVEy", "_A4pMVsKDVEy"])
            testSetAccounts(accounts: ["A4pMVsKDVEy-", "A4pMVsKDVEy_"])
        }

        it("should be able to set the customer") {
            let testSetCustomer: (customer: String) -> Void = {
                customer in
                let request = RequestBase(command: "command", action: "action", config: config)
                request.customer = customer

                expect(request.customer).to(equal(customer))
                expect(request.parameters["customer"]).to(equal(customer))
            }

            testSetCustomer(customer: "CUSTOMER")
            testSetCustomer(customer: "c")
            testSetCustomer(customer: "kYxEV4oaRQg2")
            testSetCustomer(customer: "A4pMV-sKDVEy")
            testSetCustomer(customer: "A4pMV_sKDVEy")
            testSetCustomer(customer: "_A4pMVsKDVEy")
            testSetCustomer(customer: "-A4pMVsKDVEy")
            testSetCustomer(customer: "A4pMVsKDVEy_")
            testSetCustomer(customer: "A4pMVsKDVEy-")
        }



        it("should be able to set the timezone") {
            let testSetTimezone: (timezone: NSTimeZone, expectedTimezone: String) -> Void = {
                timezone, expectedTimezone in
                let request = RequestBase(command: "command", action: "action", config: config)
                request.timezone = timezone

                expect(request.timezone).to(equal(timezone))
                expect(request.parameters["timezone"]).to(equal(expectedTimezone))
            }

            testSetTimezone(timezone: NSTimeZone(name: "Europe/Amsterdam")!, expectedTimezone: "Europe/Amsterdam")
            testSetTimezone(timezone: NSTimeZone(name: "GMT")!, expectedTimezone: "GMT")
        }

        it("should be able to set arguments") {
            let testSetArgument: (arguments: [String: Argument?], arrayArguments: [String: [Argument]]) -> Void = {
                arguments, arrayArguments in
                let request = RequestBase(command: "command", action: "action", config: config)
                for (key, value) in arguments {
                    expect(request.setArgument(key, value: value)).to(beIdenticalTo(request))
                }
                for (key, value) in arrayArguments {
                    expect(request.setArgument(key, value: value)).to(beIdenticalTo(request))
                }

                var expectedArguments = [String: String]()
                for (key, value) in arguments {
                    expectedArguments[key] = value?.value ?? ""
                }
                for (key, value) in arrayArguments {
                    expectedArguments[key] = value.map { $0.value }.joinWithSeparator(",")
                }

                expect(request.arguments).to(equal(expectedArguments))
            }

            testSetArgument(arguments: [:], arrayArguments: [:])
            testSetArgument(arguments: ["id": "WLhMc84KJcAS"], arrayArguments: [:])
            testSetArgument(arguments: ["id": 3, "double": 3.14, "bool": true], arrayArguments: [:])
            testSetArgument(arguments: ["item": "2qgEU-6Kbdoy", "account": "SLoMc-OaZNsy"], arrayArguments: ["abc": ["def", 3, "test"], "uvw": [3, 3.14 as Float, false], "someemptyarray": []])
            testSetArgument(arguments: ["test": "2qgEU-6Kbdoy", "account": "abcde,fghijk,uvwxyz"], arrayArguments: [String: [Argument]]())
            testSetArgument(arguments: ["test": "2qgEU-6Kbdoy", "empty": nil], arrayArguments: [:])
        }

        it("should be possible to set a protocol") {
            let testSetProtocol: (apiUrl: String, protocolToSet: String, expectedProtocol: String) -> Void = {
                apiUrl, protocolToSet, expectedProtocol in
                let request = TestRequestBase(command: "command", action: "action", config: config)
                request.testApiUrl = apiUrl
                request.requestProtocol = protocolToSet

                expect(request.usedProtocol()).to(equal(expectedProtocol))
            }

            testSetProtocol(apiUrl: "http://api.test", protocolToSet: "http", expectedProtocol: "http://")
            testSetProtocol(apiUrl: "http://api.test", protocolToSet: "ftp", expectedProtocol: "ftp://")
            testSetProtocol(apiUrl: "api.test", protocolToSet: "http", expectedProtocol: "http://")
            testSetProtocol(apiUrl: "http://api.test/prefix", protocolToSet: "http", expectedProtocol: "http://")
            testSetProtocol(apiUrl: "http://api.test/prefix", protocolToSet: "ssh", expectedProtocol: "ssh://")
            testSetProtocol(apiUrl: "http://api.test/prefix", protocolToSet: "ssh+ftp", expectedProtocol: "ssh+ftp://")
        }

        it("should determine the API protocol, host and prefix correctly") {
            let testGetApiProtocolHost: (apiUrl: String, expectedProtocol: String?, host: String, prefix: String) -> Void = {
                apiUrl, expectedProtocol, host, prefix in
                let request = TestRequestBase(command: "command", action: "action", config: config)
                request.testApiUrl = apiUrl

                let protoHost = request.getApiProtocolHost()

                if expectedProtocol == nil {
                    expect(protoHost.apiProtocol).to(beNil())
                } else {
                    expect(protoHost.apiProtocol).to(equal(expectedProtocol))
                }
                expect(protoHost.host).to(equal(host))
                expect(protoHost.prefix).to(equal(prefix))
            }

            testGetApiProtocolHost(apiUrl: "http://api.test", expectedProtocol: "http", host: "api.test", prefix: "")
            testGetApiProtocolHost(apiUrl: "http://api.test/prefix", expectedProtocol: "http", host: "api.test", prefix: "/prefix")
            testGetApiProtocolHost(apiUrl: "http://api.test/long/path", expectedProtocol: "http", host: "api.test", prefix: "/long/path")
            testGetApiProtocolHost(apiUrl: "api.streamonecloud.net", expectedProtocol: nil, host: "api.streamonecloud.net", prefix: "")
            testGetApiProtocolHost(apiUrl: "api.streamonecloud.net/prefix", expectedProtocol: nil, host: "api.streamonecloud.net", prefix: "/prefix")
            testGetApiProtocolHost(apiUrl: "ssh://api.streamone.nl", expectedProtocol: "ssh", host: "api.streamone.nl", prefix: "")
            testGetApiProtocolHost(apiUrl: "ssh://api.streamone.nl/prefix", expectedProtocol: "ssh", host: "api.streamone.nl", prefix: "/prefix")
            testGetApiProtocolHost(apiUrl: "ssl+http://localhost", expectedProtocol: "ssl+http", host: "localhost", prefix: "")
            testGetApiProtocolHost(apiUrl: "ssl+http://localhost/long/path", expectedProtocol: "ssl+http", host: "localhost", prefix: "/long/path")
            testGetApiProtocolHost(apiUrl: "http://192.168.178.42", expectedProtocol: "http", host: "192.168.178.42", prefix: "")
            testGetApiProtocolHost(apiUrl: "http://192.168.178.42/prefix", expectedProtocol: "http", host: "192.168.178.42", prefix: "/prefix")
            testGetApiProtocolHost(apiUrl: "http://192.168.178.42/long/path", expectedProtocol: "http", host: "192.168.178.42", prefix: "/long/path")
        }
    }
}