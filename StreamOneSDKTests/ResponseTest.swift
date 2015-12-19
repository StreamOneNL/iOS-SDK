//
//  ResponseTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 10-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
import Alamofire
import Argo
import Curry
@testable import StreamOneSDK

struct Types {}

// Type with a string array
struct Type1 : Decodable {
    let data: [String]

    static func decode(json: JSON) -> Decoded<Type1> {
        return curry(Type1.init)
            <^> json <|| "data"
    }
}

// Type with some fields
struct Type2 : Decodable {
    let field1: String
    let field2: Int
    let field3: Bool
    let field4: Double

    static func decode(json: JSON) -> Decoded<Type2> {
        return curry(Type2.init)
            <^> json <| "field1"
            <*> json <| "field2"
            <*> json <| "field3"
            <*> json <| "field4"
    }
}

// Type with one string
struct Type3 : Decodable {
    let data: String

    static func decode(json: JSON) -> Decoded<Type3> {
        return curry(Type3.init)
            <^> json <| "data"
    }
}

// Type with some fields
struct Type4 : Decodable {
    let randomField: String
    let missingField: String

    static func decode(json: JSON) -> Decoded<Type4> {
        return curry(Type4.init)
            <^> json <| "randomfield"
            <*> json <| "missingfield"
    }
}

// Type with some optional fields
struct Type5 : Decodable {
    let field1: String
    let field2: String?
    let field3: Int?

    static func decode(json: JSON) -> Decoded<Type5> {
        return curry(Type5.init)
            <^> json <| "field1"
            <*> json <|? "field2"
            <*> json <|? "field3"
    }
}

class ResponseTest : QuickSpec {
    override func spec() {
        it("should set the value of `valid` and `error` correctly when no correct response is parsed") {
            let error = NSError(domain: "S1", code: 1234, userInfo: nil)
            let result = Result<AnyObject, NSError>.Failure(error)

            let response = Response(result: result)

            expect(response.valid).to(beFalse())
            expect(response.error as? NSError).to(beIdenticalTo(error))
        }

        it("should set the value of `valid` correctly when a response is parsed") {
            let testValid: (response: String, valid: Bool) -> Void = {
                response, valid in
                let json = try! NSJSONSerialization.JSONObjectWithData(response.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.valid).to(equal(valid))
            }

            testValid(response: "5", valid: false)
            testValid(response: "\"foo\"", valid: false)
            testValid(response: "5", valid: false)
            testValid(response: "null", valid: false)
            testValid(response: "true", valid: false)
            testValid(response: "false", valid: false)
            testValid(response: "[1,2,3]", valid: false)
            testValid(response: "{\"foo\":\"bar\"}", valid: false)
            testValid(response: "{\"header\":[]}", valid: false)
            testValid(response: "{\"body\":[]}", valid: false)
            testValid(response: "{\"header\":\"foo\",\"body\":null}", valid: false)
            testValid(response: "{\"header\":{\"status\":0},\"body\":null}", valid: false)
            testValid(response: "{\"header\":{\"statusmessage\":\"OK\"},\"body\":[]}", valid: false)
            testValid(response: "{\"header\":{\"status\":\"OK\",\"statusmessage\":\"OK\"},\"body\":[]}", valid: false)
            testValid(response: "{\"header\":{\"status\":0,\"statusmessage\":0},\"body\":[]}", valid: false)
            testValid(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":null}", valid: true)
            testValid(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":true}", valid: true)
            testValid(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":false}", valid: true)
            testValid(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":\"foobar\"}", valid: true)
            testValid(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":{\"foo\":\"bar\"}}", valid: true)
            testValid(response: "{\"header\":{\"status\":1,\"statusmessage\":\"Internal error\"},\"body\":5}", valid: true)
            testValid(response: "{\"header\":{\"status\":103,\"statusmessage\":\"OMG NOES\"},\"body\":[1,2,3]}", valid: true)
        }

        it("should set the value of `success` correctly when a response is parsed") {
            let testSuccess: (response: String, success: Bool) -> Void = {
                response, success in
                let json = try! NSJSONSerialization.JSONObjectWithData(response.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.success).to(equal(success))
            }

            testSuccess(response: "5", success: false)
            testSuccess(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":{\"foo\":\"bar\"}}", success: true)
            testSuccess(response: "{\"header\":{\"status\":1,\"statusmessage\":\"Internal error\"},\"body\":5}", success: false)
            testSuccess(response: "{\"header\":{\"status\":103,\"statusmessage\":\"OMG NOES\"},\"body\":[1,2,3]}", success: false)
        }

        it("should parse the header correctly") {
            let testHeader: (response: String, status: Status, statusMessage: String, additionalHeaders: [String: AnyObject], cacheable: Bool) -> Void = {
                response, status, statusMessage, additionalHeaders, cacheable in
                let json = try! NSJSONSerialization.JSONObjectWithData(response.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.header).toNot(beNil())
                expect(response.header.status).to(equal(status))
                expect(response.header.statusMessage).to(equal(statusMessage))
                expect(response.header.allFields).toNot(beNil())
                expect(response.cacheable).to(equal(cacheable))

                var allFields = additionalHeaders
                allFields["status"] = status.rawValue
                allFields["statusmessage"] = statusMessage

                expect(allFields.keys.count).to(equal(response.header.allFields.keys.count))

                // We can not directly compare allFields with the headers allFields, as the
                // dictionary might have a different order. So we compare each element
                for key in allFields.keys {
                    expect(response.header.allFields.keys).to(contain(key))
                    let v1 = ["data": allFields[key]!]
                    let v2 = ["data": response.header.allFields[key]!]

                    let j1 = try! NSJSONSerialization.dataWithJSONObject(v1, options: [])
                    let j2 = try! NSJSONSerialization.dataWithJSONObject(v2, options: [])

                    expect(j1).to(equal(j2))
                }
            }

            testHeader(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":{\"foo\":\"bar\"}}",
                status: .OK, statusMessage: "OK", additionalHeaders: [:], cacheable: false
            )
            testHeader(response: "{\"header\":{\"status\":1,\"statusmessage\":\"Internal error\"},\"body\":[1,1,2,3,5,8,13]}",
                status: .InternalError, statusMessage: "Internal error", additionalHeaders: [:], cacheable: false
            )
            testHeader(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3},\"body\":null}",
                status: .OK, statusMessage: "OK", additionalHeaders: ["apiversion": 3], cacheable: false
            )
            testHeader(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"cacheable\":true},\"body\":null}",
                status: .OK, statusMessage: "OK", additionalHeaders: ["cacheable": true], cacheable: true
            )
            testHeader(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"cacheable\":false},\"body\":null}",
                status: .OK, statusMessage: "OK", additionalHeaders: ["cacheable": false], cacheable: false
            )
            testHeader(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"timezone\":\"Europe/Amsterdam\"},\"body\":null}",
                status: .OK, statusMessage: "OK", additionalHeaders: ["timezone": "Europe/Amsterdam"], cacheable: false
            )
        }

        it("should parse the body correctly") {
            let testBody: (response: String) -> Void = {
                response in
                let json = try! NSJSONSerialization.JSONObjectWithData(response.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                if json["body"] != nil {
                    expect(response.success).to(beTrue())
                    expect(response.body).to(beIdenticalTo(json["body"]))
                } else {
                    expect(response.success).to(beFalse())
                    expect(response.body).to(beNil())
                }
            }

            testBody(response: "{}")
            testBody(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":{\"foo\":\"bar\"}}")
            testBody(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":null}")
            testBody(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":true}")
            testBody(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":false}")
            testBody(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":4}")
            testBody(response: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":\"foobar\"}")
        }

        describe("Typed body parsing") {
            it("should parse an empty body correctly") {
                let input = "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":null}"
                let json = try! NSJSONSerialization.JSONObjectWithData(input.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.body).toNot(beNil())
                expect(response.body as? NSNull).toNot(beNil())
            }

            it("should parse a body with a string correctly") {
                let input = "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":\"This is the full body\"}"
                let json = try! NSJSONSerialization.JSONObjectWithData(input.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.body).toNot(beNil())

                let typedBody: String? = response.typedBody()

                expect(typedBody).to(equal("This is the full body"))
            }

            it("should not parse a body with an integer as a stirng") {
                let input = "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":1337}"
                let json = try! NSJSONSerialization.JSONObjectWithData(input.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.body).toNot(beNil())

                let typedBody: String? = response.typedBody()

                expect(typedBody).to(beNil())
            }

            it("should parse a body with a string array correctly") {

                let input = "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":{\"data\":[\"foo\", \"bar\", \"baz\"]}}"
                let json = try! NSJSONSerialization.JSONObjectWithData(input.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.body).toNot(beNil())

                let typedBody: Type1? = response.typedBody()

                expect(typedBody).toNot(beNil())
                expect(typedBody?.data).to(equal(["foo", "bar", "baz"]))
            }

            it("should parse a body with an object correctly") {
                let input = "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":{\"field1\": \"test\", \"field2\": 1234, \"field3\": true, \"field4\": 3.14159}}"
                let json = try! NSJSONSerialization.JSONObjectWithData(input.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.body).toNot(beNil())

                let typedBody: Type2? = response.typedBody()

                expect(typedBody).toNot(beNil())
                expect(typedBody?.field1).to(equal("test"))
                expect(typedBody?.field2).to(equal(1234))
                expect(typedBody?.field3).to(equal(true))
                expect(typedBody?.field4).to(equal(3.14159))
            }

            it("should parse a body with an array of objects correctly") {
                let input = "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":[{\"data\":\"foo\"},{\"data\":\"bar\"},{\"data\":\"baz\"}]}"
                let json = try! NSJSONSerialization.JSONObjectWithData(input.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.body).toNot(beNil())

                let typedBody: [Type3]? = response.typedBody()

                expect(typedBody).toNot(beNil())
                expect(typedBody?.count).to(equal(3))
                expect(typedBody?[0].data).to(equal("foo"))
                expect(typedBody?[1].data).to(equal("bar"))
                expect(typedBody?[2].data).to(equal("baz"))
            }

            it("should parse a body with some missing fields correctly") {
                let input = "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":{\"randomfield\": \"a\"}}"
                let json = try! NSJSONSerialization.JSONObjectWithData(input.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.body).toNot(beNil())

                let typedBody: Decoded<Type4> = response.typedBody()

                switch typedBody {
                case let .Failure(.MissingKey(key)):
                    expect(key).to(equal("missingfield"))
                default:
                    expect(false).to(beTrue()) // Always fail
                }
            }

            it("should parse a body an incorrect field correctly for other fiels") {
                let input = "{\"header\":{\"status\":0,\"statusmessage\":\"OK\"},\"body\":{\"field1\": \"a\", \"field3\": 5}}"
                let json = try! NSJSONSerialization.JSONObjectWithData(input.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)

                let result = Result<AnyObject, NSError>.Success(json)
                let response = Response(result: result)

                expect(response.body).toNot(beNil())

                let typedBody: Type5? = response.typedBody()

                expect(typedBody).toNot(beNil())
                expect(typedBody?.field1).to(equal("a"))
                expect(typedBody?.field2).to(beNil())
                expect(typedBody?.field3).to(equal(5))
            }
        }
    }
}