//
//  CacheTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 25-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

protocol CacheTest {
    func constructCache() -> Cache
}

extension CacheTest {
    func testGetSet() {
        testCache(constructCache(), key: "test-str", value: "string")
        testCache(constructCache(), key: "test-int", value: 5)
        testCache(constructCache(), key: "test-bool", value: true)
        testCache(constructCache(), key: "test-float", value: 3.14159)
        testCache(constructCache(), key: "test-array", value: [1,1,2,3,5,8,13,21])
        testCache(constructCache(), key: "test-hash", value: ["a": "val", "foo": "bar"])
    }
    
    func testChange() {
        testChangeForCache("test-str", value1: "string", value2: "newstring")
        testChangeForCache("test-int", value1: 5, value2: -7)
        testChangeForCache("test-bool", value1: true, value2: false)
        testChangeForCache("test-float", value1: 3.14159, value2: 1.41)
        testChangeForCache("test-array", value1: [1,1,2,3,5,8,13,21], value2: ["foo", "bar"])
        testChangeForCache("test-hash", value1: ["a": "val", "foo": "bar"], value2: ["c": "test"])
        testChangeForCache("test-s-i", value1: "string", value2: 5)
        testChangeForCache("test-b-f", value1: true, value2: 3.14159)
        testChangeForCache("test-a-h", value1: [1,2,3], value2: ["foo": "bar"])
    }
    
    func testChangeForCache<T: Equatable, U: Equatable>(key: String, value1: T, value2: U) {
        let cache = constructCache()
        testCache(cache, key: key, value: value1)
        testCache(cache, key: key, value: value2)
    }
    
    func testCache<T: Equatable>(cache: Cache, key: String, value: T) {
        let setTime = NSDate().timeIntervalSince1970
        
        cache.setKey(key, value: value as! AnyObject)
        
        let getVal = cache.getKey(key)
        let getAge = cache.ageOfKey(key)
        
        let getTime = NSDate().timeIntervalSince1970
        
        if let getAge = getAge {
            expect(getVal).toNot(beNil())
            expect(getVal as? T).to(equal(value))
            
            let maxAage = ceil(getTime - setTime) + 1
            expect(getAge).to(beLessThanOrEqualTo(maxAage))
        } else {
            expect(getAge).to(beNil())
            expect(getVal).to(beNil())
        }
    }
    
    func runTests() {
        it("must be able to get and set cache keys") {
            self.testGetSet()
        }
        
        it("must be able to overwrite cache keys") {
            self.testChange()
        }
    }
}