//
//  FileCacheTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 27-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class FileCacheTest : QuickSpec, CacheTest {
    func constructCache() -> Cache {
        let tempDir = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("s1_cache")
        return try! FileCache(baseDir: tempDir, expirationTime: 30)
    }
    
    override func spec() {
        runTests()
    }
}