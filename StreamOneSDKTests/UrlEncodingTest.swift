//
//  UrlEncodingTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 09-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class UrlEncodingTest : QuickSpec {
    override func spec() {
        it("should be able to correctly URL encode dictionaries") {
            self.testUrlEncoding(["a": "b", "c": "d"], expectedOutput: "a=b&c=d")
            self.testUrlEncoding(["d": ""], expectedOutput: "d=")
            self.testUrlEncoding(["": "", "a": "b"], expectedOutput: "=&a=b")

            // Keys will be sorted case-sensitive, so X before a
            self.testUrlEncoding(["Xy3": "bXY=def", "a": "b"], expectedOutput: "Xy3=bXY%3Ddef&a=b")
        }
    }

    func testUrlEncoding(input: [String: String], expectedOutput: String) {
        expect(input.urlEncode()).to(equal(expectedOutput))
    }
}