//
//  MemorySessionStoreTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 07-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class MemorySessionStoreTest : QuickSpec, SessionStoreTest {
    func constructSessionStore() -> SessionStore {
        return MemorySessionStore()
    }
    
    override func spec() {
        runTests()
    }
}