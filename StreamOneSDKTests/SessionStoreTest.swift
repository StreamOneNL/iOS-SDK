//
//  File.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 07-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

protocol SessionStoreTest {
    func constructSessionStore() -> SessionStore
}

extension SessionStoreTest {
    func runTests() {
        it("should not have a session by default") {
            expect(self.constructSessionStore().hasSession).to(equal(false))
        }

        describe("when having an active session") {
            var store: SessionStore!
            
            beforeEach {
                store = self.constructSessionStore()
                store.setSession(id: "id", key: "key", userId: "user", timeout: 10)
            }
            
            it("should have a session") {
                expect(store.hasSession).to(equal(true))
            }
            
            it("should not have a session after clearing it") {
                store.clearSession()
                expect(store.hasSession).to(equal(false))
            }
            
            it("should be able to retrieve the basic properties") {
                self.testBasicProperties(id: "id", key: "key", userId: "user_id")
                self.testBasicProperties(id: "7JhNCK-SWtEi'", key: "fAoMLYOCEpEi", userId: "_i5EDeMSEwIm")
            }
            
            it("should be able to set a cache key") {
                let key = "thisisakey"
                
                // Cache key should not be set
                expect {
                    expect(try store.hasCacheKey(key)).to(equal(false))
                }.toNot(throwError())
                
                // Set the key and test that it succeeded
                expect {
                    try store.setCacheKey(key, value: "somerandomvalue")
                }.toNot(throwError())
                
                // Cache key should not be set
                expect {
                    expect(try store.hasCacheKey(key)).to(equal(true))
                }.toNot(throwError())
            }
            
            it("should be able to retrieve a set cache key") {
                self.testSetGetCacheKey(store: store, key: "string", value: "string")
                self.testSetGetCacheKey(store: store, key: "int", value: 27)
                self.testSetGetCacheKey(store: store, key: "float", value: 3.14159)
                self.testSetGetCacheKey(store: store, key: "bool-true", value: true)
                self.testSetGetCacheKey(store: store, key: "bool-false", value: false)
                self.testSetGetCacheKey(store: store, key: "array-empty", value: [])
                self.testSetGetCacheKey(store: store, key: "array-values", value: [1, 2, 3])
                self.testSetGetCacheKey(store: store, key: "dictionary", value: ["a": 5, "foo": "bar"])
            }
            
            it("should be able to unset a key") {
                let key = "testUnsetCacheKey"
                
                expect {
                    try store.setCacheKey(key, value: "some random value")
                }.toNot(throwError())
                
                expect {
                    expect(try store.hasCacheKey(key)).to(equal(true))
                }.toNot(throwError())
                
                expect {
                    try store.unsetCacheKey(key)
                }.toNot(throwError())
                
                expect {
                    expect(try store.hasCacheKey(key)).to(equal(false))
                }.toNot(throwError())
            }
            
            it("should be able to clear the cache") {
                let key = "testClearCacheKey"
                
                expect {
                    try store.setCacheKey(key, value: "some random value")
                }.toNot(throwError())
                
                expect {
                    expect(try store.hasCacheKey(key)).to(equal(true))
                }.toNot(throwError())
                
                store.clearSession()
                store.setSession(id: "id", key: "key", userId: "user", timeout: 10)
                
                expect {
                    expect(try store.hasCacheKey(key)).to(equal(false))
                }.toNot(throwError())
            }
        }
        
        describe("error throwing") {
            var store: SessionStore!
            
            beforeEach {
                store = self.constructSessionStore()
            }
            
            describe("without an active session") {
                it("should throw a NoSession error when setting the timeout") {
                    expect {
                        try store.setTimeout(1234)
                    }.to(throwError(SessionError.NoSession))
                }
                
                it("should throw a NoSession error when requesting the id") {
                    expect {
                        try store.getId()
                    }.to(throwError(SessionError.NoSession))
                }
                
                it("should throw a NoSession error when requesting the key") {
                    expect {
                        try store.getKey()
                    }.to(throwError(SessionError.NoSession))
                }
                
                it("should throw a NoSession error when requesting the userId") {
                    expect {
                        try store.getUserId()
                    }.to(throwError(SessionError.NoSession))
                }
                
                it("should throw a NoSession error when requesting the timeout") {
                    expect {
                        try store.getTimeout()
                    }.to(throwError(SessionError.NoSession))
                }
                
                it("should throw a NoSession error when checking for a key") {
                    expect {
                        try store.hasCacheKey("abc")
                    }.to(throwError(SessionError.NoSession))
                }
                
                it("should throw a NoSession error when fetching a key") {
                    expect {
                        try store.getCacheKey("abc")
                    }.to(throwError(SessionError.NoSession))
                }
                
                it("should throw a NoSession error when setting a key") {
                    expect {
                        try store.setCacheKey("abc", value: "def")
                    }.to(throwError(SessionError.NoSession))
                }
                
                it("should throw a NoSession error when unsetting a key") {
                    expect {
                        try store.unsetCacheKey("abc")
                    }.to(throwError(SessionError.NoSession))
                }
            }
            
            describe("with an active session") {
                beforeEach {
                    store.setSession(id: "a", key: "b", userId: "c", timeout: 1234)
                }
                
                it("should throw a NoSuchKey error when fetching a key") {
                    expect {
                        try store.getCacheKey("abc")
                    }.to(throwError {
                        error in
                        guard case SessionError.NoSuchKey(let key) = error else {
                            fail()
                            return
                        }
                        expect(key).to(equal("abc"))
                    })
                }
                
                it("should throw a NoSuchKey error when unsetting a key") {
                    expect {
                        try store.unsetCacheKey("abc")
                    }.to(throwError {
                        error in
                        guard case SessionError.NoSuchKey(let key) = error else {
                            fail()
                            return
                        }
                        expect(key).to(equal("abc"))
                        })
                }
            }
        }
        
        it("should have an initial timeout") {
            // Use a fixed timeout
            let timeout: NSTimeInterval = 10
            
            // Store current time to obtain a bound on maximum timeout change
            let startTime = NSDate().timeIntervalSince1970
            
            // Construct store and set a session
            let store = self.constructSessionStore()
            store.setSession(id: "id", key: "key", userId: "user", timeout: timeout)
            
            // Retrieve the stored timeout
            var newTimeout: NSTimeInterval!
            
            expect {
                newTimeout = try store.getTimeout()
            }.toNot(throwError())
            
            // Calculate maximum time passed
            let timePassed = (NSDate().timeIntervalSince1970 - startTime)
                
            // Check whether timeout decay is within margins
            let timeoutDiff = timeout - newTimeout
                
            expect(timeoutDiff).to(beLessThanOrEqualTo(timePassed))
        }
        
        it("should be possible to update the timeout") {
            // Construct store and set a session with a low timeout
            let store = self.constructSessionStore()
            store.setSession(id: "id", key: "key", userId: "user", timeout: 5)
            
            // Use a fixed timeout
            let timeout: NSTimeInterval = 20
            
            // Store current time to obtain a bound on maximum timeout change
            let startTime = NSDate().timeIntervalSince1970
            
            // Update timeout
            expect {
                try store.setTimeout(timeout)
            }.toNot(throwError())
            
            // Retrieve the stored timeout
            var newTimeout: NSTimeInterval!
            
            expect {
                newTimeout = try store.getTimeout()
            }.toNot(throwError())
            
            // Calculate maximum time passed
            let timePassed = (NSDate().timeIntervalSince1970 - startTime)
            
            // Check whether timeout decay is within margins
            let timeoutDiff = timeout - newTimeout
            
            expect(timeoutDiff).to(beLessThanOrEqualTo(timePassed))
        }
        
        it("should actually timeout after the given timeout") {
            // Construct store and set a session with 0.3 second timeout
            let store = self.constructSessionStore()
            store.setSession(id: "id", key: "key", userId: "user", timeout: 0.3)
            
            // There should be an active session
            expect(store.hasSession).to(equal(true))
            
            // The session should be inactive eventually, wait for at most 0.5 seconds
            expect(store.hasSession).toEventually(equal(false), timeout: 0.5)
        }
    }
    
    func testBasicProperties(id id: String, key: String, userId: String) {
        let timeout: NSTimeInterval = 10
        
        let store = constructSessionStore()
        store.setSession(id: id, key: key, userId: userId, timeout: timeout)
        
        expect(store.hasSession).to(equal(true))
        
        var idFromStore: String?
        var keyFromStore: String?
        var userIdFromStore: String?
        
        expect { idFromStore = try store.getId() }.toNot(throwError())
        expect { keyFromStore = try store.getKey() }.toNot(throwError())
        expect { userIdFromStore = try store.getUserId() }.toNot(throwError())
        
        expect(idFromStore).to(equal(id))
        expect(keyFromStore).to(equal(key))
        expect(userIdFromStore).to(equal(userId))
    }
    
    func testSetGetCacheKey<T: Equatable>(store store: SessionStore, key: String, value: T) {
        expect {
            try store.setCacheKey(key, value: value as! AnyObject)
        }.toNot(throwError())

        expect {
            expect(try store.hasCacheKey(key)).to(equal(true))
        }.toNot(throwError())
        
        expect {
            expect(try store.getCacheKey(key) as? T).to(equal(value))
        }.toNot(throwError())
    }
}