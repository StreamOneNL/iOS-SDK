//
//  MemoryCacheTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 26-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class MemoryCacheTest : QuickSpec, CacheTest {
    func constructCache() -> Cache {
        return MemoryCache()
    }
    
    override func spec() {
        runTests()
    }
}