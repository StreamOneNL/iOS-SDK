//
//  PasswordTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class PasswordTest : QuickSpec {
    override func spec() {
        it("should calculate challenge responses correctly") {
            let testChallengeResponse: (password: String, salt: String, challenge: String, expectedResult: String) -> Void = {
                password, salt, challenge, expectedResult in
                let result = Password.generatePasswordResponse(password: password, salt: salt, challenge: challenge)
                expect(result).to(equal(expectedResult))
            }

            testChallengeResponse(password: "password", salt: "$2y$12$gmdjitkypwyd4d1mkeefiv",
                challenge: "EwBdQcB5yq8sU05u4aADv6Abg3oBVhtp",
                expectedResult: "RgFOFwNQQAVeXFtbElkfQRVLVVZUBwtdV1YDWkQoDUsYRC4PDAASUyt+PRoVW2ADYV5hDA4rF1hcUFUU")
            testChallengeResponse(password: "test123", salt: "$2y$12$gmdjitkypwyd4d1mkeefiv",
                challenge: "EwBdQcB5yq8sU05u4aADv6Abg3oBVhtp",
                expectedResult: "FFdBFAFXHQJcUFMPRg9AFEJAUlJdV1RaUVdXXxZWeiA3CAF5TmAwCXA+XSsGGQ1nBw5FYEFFFnRAGXxA")
            testChallengeResponse(password: "password", salt: "$2y$12$euslxtglafeu6zf1zfuvcu",
                challenge: "e7Z1Q6dRbHB86HZwdjiF45dI7d8gxNVB",
                expectedResult: "QlBBEwUGRQFCSg1IEVVdBQIHFFBIUgZNUkYVVxcBVEIPDgB8LzZ5QhM6KgZ7RgpxDHsGUzJ4El4cAX8q")
        }

        it("should calculate V2 hashes correctly") {
            let testV2Hash: (password: String, expectedHash: String) -> Void = {
                password, expectedHash in
                expect(Password.generateV2PasswordHash(password)).to(equal(expectedHash))
            }

            testV2Hash(password: "password", expectedHash: "5f4dcc3b5aa765d61d8327deb882cf99")
            testV2Hash(password: "test123", expectedHash: "cc03e747a6afbbcbf8be7668acfebee5")
            testV2Hash(password: "thisisalongpassword", expectedHash: "6aab4ab53c466fd08635837b9a8f61ff")
        }
    }
}