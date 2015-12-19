//
//  RegexTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 09-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class RegexTest : QuickSpec {
    override func spec() {
        it("should return the correct matches on a successful match") {
            let regex = try! Regex("^[a-z][0-9]123$")

            let matches = regex.matches("z3123")

            expect(matches.count).to(equal(1))
            expect(matches[0]).to(equal("z3123"))
        }

        it("should return capture groups on a successful match") {
            let regex = try! Regex("^([A-Z])_([0-9])\\+test_$")

            let matches = regex.matches("X_7+test_")
            expect(matches.count).to(equal(3))
            expect(matches[0]).to(equal("X_7+test_"))
            expect(matches[1]).to(equal("X"))
            expect(matches[2]).to(equal("7"))
        }

        it("should not return any matches when matching fails") {
            let regex = try! Regex("^invalid$")

            let matches = regex.matches("thisdoesnotmatch")

            expect(matches).to(beEmpty())
        }
    }
}