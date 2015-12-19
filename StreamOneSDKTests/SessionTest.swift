//
//  SessionTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

// Request factory that returns requests that we can use during testing
class SessionTestRequestFactory : RequestFactory {
    // Set to a list of responses to have returned each time
    var nextMockResponses: [String] = []

    func newRequest(command command: String, action: String, config: Config) -> Request {
        let request = TestRequest(command: command, action: action, config: config)

        if let mockResponse = nextMockResponses.first {
            request.mockResponse = mockResponse
            nextMockResponses.removeFirst()
        }

        return request
    }

    func newSessionRequest(command command: String, action: String, config: Config, sessionStore: SessionStore) throws -> SessionRequest {
        let request = try TestSessionRequest(command: command, action: action, config: config, sessionStore: sessionStore)

        if let mockResponse = nextMockResponses.first {
            request.mockResponse = mockResponse
            nextMockResponses.removeFirst()
        }

        return request
    }
}

class SessionTest : QuickSpec {
    override func spec() {
        var config: Config!
        let requestFactory = SessionTestRequestFactory()

        beforeEach {
            config = Config(authenticationType: .Application(id: "id", psk: "psk"))
            config.requestFactory = requestFactory
        }

        it("should use the session store from the configuration if none given during initialization") {
            let session = Session(config: config)
            expect(session.sessionStore as? MemorySessionStore).to(beIdenticalTo(config.sessionStore as? MemorySessionStore))
        }

        it("should use the session store from the initializer if given") {
            let sessionStore = MemorySessionStore()
            let session = Session(config: config, sessionStore: sessionStore)
            expect(session.sessionStore as? MemorySessionStore).to(beIdenticalTo(sessionStore))
            expect(session.sessionStore as? MemorySessionStore).toNot(beIdenticalTo(config.sessionStore as? MemorySessionStore))
        }

        it("should not have an active session if setSession() has not been called on the session store") {
            let session = Session(config: config)
            expect(session.isActive).to(beFalse())

            expect {
                try session.newRequest(command: "command", action: "action")
                }.to(throwError(SessionError.NoSession))
        }

        it("should have an active session if setSession() has been called on the session store") {
            let session = Session(config: config)

            session.sessionStore.setSession(id: "id", key: "key", userId: "user_id", timeout: 1234)

            expect(session.isActive).to(beTrue())

            expect {
                try session.newRequest(command: "command", action: "action")
            }.toNot(throwError(SessionError.NoSession))
        }

        it("should be able to start a session with correct responses") {
            let testSessionStart: (firstResponse: String, secondResponse: String) -> Void = {
                firstResponse, secondResponse in

                let session = Session(config: config)
                var done = false

                requestFactory.nextMockResponses = []
                requestFactory.nextMockResponses.append(firstResponse)
                requestFactory.nextMockResponses.append(secondResponse)

                session.start(username: "user", password: "password", ip: "ip") { success, lastResponse in
                    done = true
                    expect(success).to(beTrue())
                    expect(session.sessionStore.hasSession).to(beTrue())
                }

                expect(done).toEventually(beTrue())
            }

            testSessionStart(
                firstResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"challenge\":\"OTzt9VSAQHQSFuEf03PZT6e5P4OoS1sw\",\"salt\":\"$2y$12$jyhye3p43mjoxvtfxflfkv\",\"needsv2hash\":false}}",
                secondResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"id\":\"Hz1kPspd2Bk1\",\"key\":\"SQKEyak6R2BcwH3qnTakY50SKeABxXcg\",\"timeout\":3600,\"user\":\"QIpMpsuPCBKn\"}}"
            )

            // Force v2 hash
            testSessionStart(
                firstResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"challenge\":\"OTzt9VSAQHQSFuEf03PZT6e5P4OoS1sw\",\"salt\":\"$2y$12$jyhye3p43mjoxvtfxflfkv\",\"needsv2hash\":true}}",
                secondResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"id\":\"Hz1kPspd2Bk1\",\"key\":\"SQKEyak6R2BcwH3qnTakY50SKeABxXcg\",\"timeout\":3600,\"user\":\"QIpMpsuPCBKn\"}}"
            )
        }

        it("should not be able to start a session with incorrect responses") {
            let testSessionStart: (firstResponse: String, secondResponse: String) -> Void = {
                firstResponse, secondResponse in

                let session = Session(config: config)
                var done = false

                requestFactory.nextMockResponses = []
                requestFactory.nextMockResponses.append(firstResponse)
                requestFactory.nextMockResponses.append(secondResponse)

                session.start(username: "user", password: "password", ip: "ip") { success, lastResponse in
                    done = true
                    expect(success).to(beFalse())
                    expect(session.sessionStore.hasSession).to(beFalse())
                }

                expect(done).toEventually(beTrue())
            }

            // Unsuccessful initialize response
            testSessionStart(
                firstResponse: "{\"header\":{\"status\":1,\"statusmessage\":\"Error\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"challenge\":\"OTzt9VSAQHQSFuEf03PZT6e5P4OoS1sw\",\"salt\":\"$2y$12$jyhye3p43mjoxvtfxflfkv\",\"needsv2hash\":false}}",
                secondResponse: "" // Doesn't matter, first response not OK
            )

            // Invalid body
            testSessionStart(
                firstResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"typo\":\"OTzt9VSAQHQSFuEf03PZT6e5P4OoS1sw\",\"a\":\"$2y$12$jyhye3p43mjoxvtfxflfkv\",\"nebedsv2hash\":false}}",
                secondResponse: "" // Doesn't matter, first response has invalid body
            )

            // Non-valid salt
            testSessionStart(
                firstResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"challenge\":\"OTzt9VSAQHQSFuEf03PZT6e5P4OoS1sw\",\"salt\":\"$XX$12$thisisnotasalt\",\"needsv2hash\":false}}",
                secondResponse: "" // Doesn't matter, first response not OK
            )

            // Unsuccessful create response
            testSessionStart(
                firstResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"challenge\":\"OTzt9VSAQHQSFuEf03PZT6e5P4OoS1sw\",\"salt\":\"$2y$12$jyhye3p43mjoxvtfxflfkv\",\"needsv2hash\":false}}",
                secondResponse: "{\"header\":{\"status\":1,\"statusmessage\":\"Error\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"id\":\"Hz1kPspd2Bk1\",\"key\":\"SQKEyak6R2BcwH3qnTakY50SKeABxXcg\",\"timeout\":3600,\"user\":\"QIpMpsuPCBKn\"}}"

            )

            // Invalid body
            testSessionStart(
                firstResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"challenge\":\"OTzt9VSAQHQSFuEf03PZT6e5P4OoS1sw\",\"salt\":\"$2y$12$jyhye3p43mjoxvtfxflfkv\",\"needsv2hash\":false}}",
                secondResponse: "{\"header\":{\"status\":0,\"statusmessage\":\"OK\",\"apiversion\":3,\"cacheable\":false,\"timezone\":\"Europe/Amsterdam\"},\"body\":{\"a\":\"Hz1kPspd2Bk1\",\"b\":\"SQKEyak6R2BcwH3qnTakY50SKeABxXcg\",\"c\":3600,\"d\":\"QIpMpsuPCBKn\"}}"

            )
        }

        it("should not be able to end a session if none has been started") {
            let session = Session(config: config)

            expect {
                try session.end { _ in }
            }.to(throwError(SessionError.NoSession))
        }

        it("should be able to end a session if one has been started") {
            let session = Session(config: config)

            session.sessionStore.setSession(id: "id", key: "key", userId: "user_id", timeout: 1234)

            var done = false

            // Have some response, doesn't matter what
            requestFactory.nextMockResponses.append("{}")

            expect {
                try session.end { _ in
                    expect(session.isActive).to(beFalse())
                    expect(session.sessionStore.hasSession).to(beFalse())
                    done = true
                }
            }.toNot(throwError(SessionError.NoSession))

            expect(done).toEventually(beTrue())
        }
    }
}