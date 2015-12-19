//
//  ConfigTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 19-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class ConfigTest: QuickSpec {
    override func spec() {
        describe("init()") {
            context("when passed a user authentication type") {
                let authenticationType = AuthenticationType.User(id: "userid", psk: "userpsk")
                let config = Config(authenticationType: authenticationType)

                it("should keep track of the authentication type") {
                    expect(config.authenticationType).to(equal(authenticationType))
                }
            }
            
            context("when passed an application authentication type") {
                let authenticationType = AuthenticationType.Application(id: "appid", psk: "apppsk")
                let config = Config(authenticationType: authenticationType)
                
                it("should keep track of the authentication type") {
                    expect(config.authenticationType).to(equal(authenticationType))
                }
            }
        }
        
        describe("Default values") {
            let config = Config(authenticationType: .User(id: "a", psk: "b"))
            
            it("should have the default API URL") {
                expect(config.apiUrl).to(equal("https://api.streamonecloud.net"))
            }
            
            it("should have no default account") {
                expect(config.defaultAccountId).to(beNil())
            }
            
            it("should have a StandardRequestFactory request factory") {
                // We can not use beAKindOf on non Objective-C classes
                expect(config.requestFactory as? StandardRequestFactory).toNot(beNil())
            }
            
            it("should have a NoopCache request cache") {
                // We can not use beAKindOf on non Objective-C classes
                expect(config.requestCache as? NoopCache).toNot(beNil())
            }
            
            it("should have a NoopCache token cache") {
                // We can not use beAKindOf on non Objective-C classes
                expect(config.tokenCache as? NoopCache).toNot(beNil())
            }
            
            it("should have a MemorySessionStore session store") {
                // We can not use beAKindOf on non Objective-C classes
                expect(config.sessionStore as? MemorySessionStore).toNot(beNil())
            }
            
            it("should use the session for the token cache by default") {
                expect(config.useSessionForTokenCache).to(beTrue())
            }
        }
        
        describe("setters") {
            var config: Config!
            
            beforeEach {
                config = Config(authenticationType: .User(id: "a", psk: "b"))
            }
            
            it("should set the API URL") {
                let urlToSet = "http://an.url"
                config.apiUrl = urlToSet
                expect(config.apiUrl).to(equal(urlToSet))
            }
            
            it("should set the default account ID") {
                let accountIdToSet = "abcde01234"
                config.defaultAccountId = accountIdToSet
                expect(config.defaultAccountId).to(equal(accountIdToSet))
            }
            
            it("should set the request factory correctly") {
                let requestFactory = MyRequestFactory()
                config.requestFactory = requestFactory
                // Cast to MyRequestFactory is needed because beIdenticalTo expect AnyObject and RequestFactory is a protocol
                expect(config.requestFactory as? MyRequestFactory).to(beIdenticalTo(requestFactory))
            }
            
            it("should set the request cache correctly") {
                let cache = MyTestCache()
                config.requestCache = cache
                // Cast to MyTestCache is needed because beIdenticalTo expect AnyObject and Cache is a protocol
                expect(config.requestCache as? MyTestCache).to(beIdenticalTo(cache))
            }
            
            it("should set the token cache correctly") {
                let cache = MyTestCache()
                config.tokenCache = cache
                // Cast to MyTestCache is needed because beIdenticalTo expect AnyObject and Cache is a protocol
                expect(config.tokenCache as? MyTestCache).to(beIdenticalTo(cache))
            }
            
            it("should set both caches using setCache") {
                let cache = MyTestCache()
                config.setCache(cache)
                // Cast to MyTestCache is needed because beIdenticalTo expect AnyObject and Cache is a protocol
                expect(config.requestCache as? MyTestCache).to(beIdenticalTo(cache))
                expect(config.tokenCache as? MyTestCache).to(beIdenticalTo(cache))
            }
            
            it("should set the session store correctly") {
                let sessionStore = MySessionStore()
                config.sessionStore = sessionStore
                // Cast to MySessionStore is needed because beIdenticalTo expect AnyObject and SessionStore is a protocol
                expect(config.sessionStore as? MySessionStore).to(beIdenticalTo(sessionStore))
            }
            
            it("should set the value for useSessionForTokenCache correctly") {
                let cases = [true, false]
                for c in cases {
                    config.useSessionForTokenCache = c
                    expect(config.useSessionForTokenCache).to(equal(c))
                }
            }
        }
    }
}