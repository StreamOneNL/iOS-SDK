//
//  NoopCacheTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 26-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class NoopCacheTest : QuickSpec, CacheTest {
    func constructCache() -> Cache {
        return NoopCache()
    }
    
    override func spec() {
        runTests()
    }
}