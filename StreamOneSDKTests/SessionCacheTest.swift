//
//  SessionCacheTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class SessionCacheTest : QuickSpec, CacheTest {
    func constructCache() -> Cache {
        let sessionStore = MemorySessionStore()
        sessionStore.setSession(id: "id", key: "key", userId: "userid", timeout: 1234)
        return SessionCache(sessionStore: sessionStore)
    }

    override func spec() {
        runTests()
    }
}
