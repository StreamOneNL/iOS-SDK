//
//  ActorTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 22-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class TestActor : Actor {
    /**
        Return a predetermined set of roles
    */
    override func loadRolesFromApi(actorType: ActorType, callback: (roles: ResultOrError<[RoleInActor]>) -> Void) throws {
        switch actorType {
        case .User:
            let roles = [
                // user has tokens a, b, c global
                RoleInActor(
                    role: Role(id: "role1", name: "Role 1", customer: nil, tokens: ["a", "b", "c"]),
                    account: nil,
                    customer: nil
                ),
                // it has tokens f, g in account A1
                RoleInActor(
                    role: Role(id: "role2", name: "Role 2", customer: nil, tokens: ["f", "g"]),
                    account: BasicAccount(id: "A1", name: "A1"),
                    customer: nil
                ),
                // and it has tokens g, h in account A2
                RoleInActor(
                    role: Role(id: "role3", name: "Role 3", customer: nil, tokens: ["g", "h"]),
                    account: BasicAccount(id: "A2", name: "A2"),
                    customer: nil
                )
            ]

            callback(roles: .Result(roles))
        case .Application:
            let roles = [
                // application has token z global
                RoleInActor(
                    role: Role(id: "roleapp1", name: "Role app 1", customer: nil, tokens: ["z"]),
                    account: nil,
                    customer: nil
                ),
                // it has tokens y, p in customer C1
                RoleInActor(
                    role: Role(id: "roleapp2", name: "Role app 2", customer: nil, tokens: ["y", "p"]),
                    account: nil,
                    customer: BasicCustomer(id: "C1", name: "C1", dateCreated: "", dateModified: "")
                ),
                // it has tokens x, p in customer C2
                RoleInActor(
                    role: Role(id: "roleapp3", name: "Role app 3", customer: nil, tokens: ["x", "p"]),
                    account: nil,
                    customer: BasicCustomer(id: "C2", name: "C2", dateCreated: "", dateModified: "")
                ),
                // it has tokens w, v in account A1
                RoleInActor(
                    role: Role(id: "roleapp4", name: "Role app 4", customer: nil, tokens: ["w", "v"]),
                    account: BasicAccount(id: "A1", name: "A1"),
                    customer: nil
                ),
                // and it has tokens v, u in account A3
                RoleInActor(
                    role: Role(id: "roleapp5", name: "Role app 5", customer: nil, tokens: ["v", "u"]),
                    account: BasicAccount(id: "A3", name: "A3"),
                    customer: nil
                )
            ]

            callback(roles: .Result(roles))
        }
    }

    /**
        Return a predetermined set of tokens
    */
    override func loadMyTokensFromApi(callback: (tokens: ResultOrError<[String]>) -> Void) throws {
        // This should be consistent with the above list, otherwise we might get unexpected behaviour
        // That makes this function a big if-statement

        // Sort accounts so we can do array comparison easily
        let accounts = self.accounts.sort(<)

        let tokens: [String]

        // Extra assumptions: A1 and A2 belong to C1 and A3 belongs to C2
        if config.authenticationType.isUserAuth || session != nil {
            if customer == nil && accounts.count == 0 {
                tokens = ["a", "b", "c"]
            } else if accounts == ["A1"] {
                tokens = ["a", "b", "c", "f", "g"]
            } else if accounts == ["A2"] {
                tokens = ["a", "b", "c", "g", "h"]
            } else if accounts == ["A1", "A2"] {
                tokens = ["a", "b", "c", "g"]
            } else {
                // Globally available tokens
                tokens = ["a", "b", "c"]
            }
        } else {
            // Application auth
            if customer == nil && accounts.count == 0 {
                tokens = ["z"]
            } else if customer == "C1" {
                tokens = ["z", "y", "p"]
            } else if customer == "C2" {
                tokens = ["z", "x", "p"]
            } else if accounts == ["A1"] {
                tokens = ["z", "y", "p", "w", "v"]
            } else if accounts == ["A3"] {
                tokens = ["z", "y", "p"]
            } else if accounts == ["A3"] {
                tokens = ["z", "x", "p", "v", "u"]
            } else if accounts == ["A1", "A2"] {
                tokens = ["z", "p", "y"]
            } else if accounts == ["A1", "A3"] {
                tokens = ["z", "p", "v"]
            } else if accounts == ["A2", "A3"] {
                tokens = ["z", "p"]
            } else if accounts == ["A1", "A2", "A3"] {
                tokens = ["z", "p"]
            } else {
                // Globally available tokens
                tokens = ["z"]
            }
        }

        callback(tokens: .Result(tokens))
    }
}

class ActorTest : QuickSpec {
    override func spec() {
        let configUser = Config(authenticationType: .User(id: "user", psk: "psk"))
        var configUserDefaultAccount = Config(authenticationType: .User(id: "user", psk: "psk"))
        configUserDefaultAccount.defaultAccountId = "account"

        let configApplication = Config(authenticationType: .Application(id: "application", psk: "apppsk"))
        var configApplicationDefaultAccount = Config(authenticationType: .Application(id: "application", psk: "apppsk"))
        configApplicationDefaultAccount.defaultAccountId = "account"

        var memorySessionStore: MemorySessionStore

        memorySessionStore = MemorySessionStore()
        memorySessionStore.setSession(id: "session", key: "key", userId: "user", timeout: 100)
        let sessionUser = Session(config: configUser, sessionStore: memorySessionStore)

        memorySessionStore = MemorySessionStore()
        memorySessionStore.setSession(id: "session", key: "key", userId: "user", timeout: 100)
        let sessionUserDefaultAccount = Session(config: configUserDefaultAccount, sessionStore: memorySessionStore)

        memorySessionStore = MemorySessionStore()
        memorySessionStore.setSession(id: "session", key: "key", userId: "user", timeout: 100)
        let sessionApplication = Session(config: configApplication, sessionStore: memorySessionStore)

        memorySessionStore = MemorySessionStore()
        memorySessionStore.setSession(id: "session", key: "key", userId: "user", timeout: 100)
        let sessionApplicationDefaultAccount = Session(config: configApplicationDefaultAccount, sessionStore: memorySessionStore)

        it("should use the token cache of the configuration if not using the session") {
            let actor = Actor(config: configApplication)
            // Casting to NoopCache (which they are), to make it an object
            expect(actor.tokenCache as? NoopCache).to(beIdenticalTo(configApplication.tokenCache as? NoopCache))
        }

        it("should use a session token cache if using the session") {
            var config = configApplication
            config.useSessionForTokenCache = true
            let actor = Actor(config: config, session: sessionApplication)
            // Casting to SessionCache (which it is), to test if it works
            expect(actor.tokenCache as? SessionCache).toNot(beNil())
        }

        it("should set no session when not using one") {
            let actor = Actor(config: configUser)
            expect(actor.session).to(beNil())
        }

        it("should set a session when using one") {
            let actor = Actor(config: configApplication, session: sessionApplication)
            // We can not compare the sessions, as they are structs and not objects
            expect(actor.session).toNot(beNil())
        }

        it("should not have a default account if none provided") {
            for config in [configUser, configApplication] {
                let actor = Actor(config: config)
                expect(actor.accounts).to(beEmpty())
            }
        }

        it("should set the default account correctly") {
            for config in [configUserDefaultAccount, configApplicationDefaultAccount] {
                let actor = Actor(config: config)
                expect(actor.accounts).to(equal([config.defaultAccountId!]))
            }
        }

        it("should set the account of an actor correctly") {
            let accountsToTest = [["account123"], ["account123", "anotheraccount"], []]
            for accounts in accountsToTest {
                let actor = Actor(config: configUserDefaultAccount)
                actor.accounts = accounts
                expect(actor.accounts).to(equal(accounts))

                // It should also clear the customer
                expect(actor.customer).to(beNil())
            }
        }

        it("should set the customer of an actor correclty") {
            let customersToTest: [String?] = ["customer123", nil]
            for customer in customersToTest {
                let actor = Actor(config: configUserDefaultAccount)
                actor.customer = customer
                if customer == nil {
                    expect(actor.customer).to(beNil())
                } else {
                    expect(actor.customer).to(equal(customer))
                }
                expect(actor.accounts).to(beEmpty())
            }
        }

        it("should create a new request correctly when providing accounts") {
            let testNewRequestWithAccount: (config: Config, accounts: [String]) -> Void = {
                config, accounts in

                let actor = Actor(config: config)
                actor.accounts = accounts

                var request: Request! = nil
                expect {
                    request = try actor.newRequest(command: "command", action: "action")
                }.toNot(throwError())

                expect(actor.accounts).to(equal(accounts))

                expect(request.accounts).to(equal(accounts))

                expect(request.config.authenticationType.description)
                    .to(equal(actor.config.authenticationType.description))

                expect(request.customer).to(beNil())
            }

            testNewRequestWithAccount(config: configUser, accounts: ["account123"])
            testNewRequestWithAccount(config: configUserDefaultAccount, accounts: ["account123"])
            testNewRequestWithAccount(config: configApplication, accounts: ["account123"])
            testNewRequestWithAccount(config: configUser, accounts: [])
            testNewRequestWithAccount(config: configUserDefaultAccount, accounts: [])
            testNewRequestWithAccount(config: configApplication, accounts: [])
        }

        it("should create a new request correctly when using the default account") {
            let testNewRequestDefaultAccount: (config: Config) -> Void = {
                config in

                let actor = Actor(config: config)

                var request: Request! = nil
                expect {
                    request = try actor.newRequest(command: "command", action: "action")
                }.toNot(throwError())

                if config.defaultAccountId == nil {
                    expect(request.account).to(beNil())
                } else {
                    expect(request.account).to(equal(config.defaultAccountId))
                }

                expect(request.config.authenticationType.description)
                    .to(equal(actor.config.authenticationType.description))

                expect(request.customer).to(beNil())
            }

            testNewRequestDefaultAccount(config: configUser)
            testNewRequestDefaultAccount(config: configUserDefaultAccount)
            testNewRequestDefaultAccount(config: configApplication)
            testNewRequestDefaultAccount(config: configApplicationDefaultAccount)
        }

        it("should create a new request correctly when providing accounts and a session") {
            let testNewRequestWithAccountInSession: (config: Config, session: Session, accounts: [String]) -> Void = {
                config, session, accounts in

                let actor = Actor(config: config, session: session)
                actor.accounts = accounts

                var request: Request! = nil
                expect {
                    request = try actor.newRequest(command: "command", action: "action")
                }.toNot(throwError())

                // Check correct type
                expect(request as? SessionRequest).toNot(beNil())

                expect(actor.accounts).to(equal(accounts))

                expect(request.accounts).to(equal(accounts))

                expect(request.config.authenticationType.description)
                    .to(equal(actor.config.authenticationType.description))

                expect(request.customer).to(beNil())

                let sessionId = try! session.sessionStore.getId()
                expect(request.parametersForSigning()["session"]).to(equal(sessionId))
                let sessionKey = try! session.sessionStore.getKey()
                expect(request.signingKey()).to(equal("\(config.authenticationType.psk)\(sessionKey)"))
            }

            testNewRequestWithAccountInSession(config: configApplication,
                session: sessionApplication, accounts: ["account123"])
            testNewRequestWithAccountInSession(config: configApplicationDefaultAccount,
                session: sessionApplicationDefaultAccount, accounts: ["account123"])
            testNewRequestWithAccountInSession(config: configApplication,
                session: sessionApplication, accounts: [])
            testNewRequestWithAccountInSession(config: configApplicationDefaultAccount,
                session: sessionApplicationDefaultAccount, accounts: [])
        }

        it("should create a new request correctly when using the default account and a session") {
            let testNewRequestWithAccountInSession: (config: Config, session: Session) -> Void = {
                config, session in

                let actor = Actor(config: config, session: session)

                var request: Request! = nil
                expect {
                    request = try actor.newRequest(command: "command", action: "action")
                }.toNot(throwError())

                // Check correct type
                expect(request as? SessionRequest).toNot(beNil())

                if config.defaultAccountId == nil {
                    expect(request.account).to(beNil())
                } else {
                    expect(request.account).to(equal(config.defaultAccountId))
                }

                expect(request.config.authenticationType.description)
                    .to(equal(actor.config.authenticationType.description))

                expect(request.customer).to(beNil())

                let sessionId = try! session.sessionStore.getId()
                expect(request.parametersForSigning()["session"]).to(equal(sessionId))
                let sessionKey = try! session.sessionStore.getKey()
                expect(request.signingKey()).to(equal("\(config.authenticationType.psk)\(sessionKey)"))
            }

            testNewRequestWithAccountInSession(config: configApplication,
                session: sessionApplication)
            testNewRequestWithAccountInSession(config: configApplicationDefaultAccount,
                session: sessionApplicationDefaultAccount)
        }

        it("should create a new request correctly when providing a customer") {
            let testNewRequestWithCustomer: (config: Config, customer: String?) -> Void = {
                config, customer in

                let actor = Actor(config: config)
                actor.customer = customer

                var request: Request! = nil
                expect {
                    request = try actor.newRequest(command: "command", action: "action")
                }.toNot(throwError())

                if customer == nil {
                    expect(actor.customer).to(beNil())
                    expect(request.customer).to(beNil())
                } else {
                    expect(actor.customer).to(equal(customer))
                    expect(request.customer).to(equal(customer))
                }


                expect(request.config.authenticationType.description)
                    .to(equal(actor.config.authenticationType.description))

                expect(request.accounts).to(beEmpty())
            }

            testNewRequestWithCustomer(config: configUser, customer: "customer1")
            testNewRequestWithCustomer(config: configUserDefaultAccount, customer: "customer1")
            testNewRequestWithCustomer(config: configUser, customer: nil)
            testNewRequestWithCustomer(config: configUserDefaultAccount, customer: nil)
        }

        it("should create a new request correctly when providing a customer and a session") {
            let testNewRequestWithCustomerInSession: (config: Config, session: Session, customer: String?) -> Void = {
                config, session, customer in

                let actor = Actor(config: config, session: session)
                actor.customer = customer

                var request: Request! = nil
                expect {
                    request = try actor.newRequest(command: "command", action: "action")
                }.toNot(throwError())

                // Cast to test type
                expect(request as? SessionRequest).toNot(beNil())

                if customer == nil {
                    expect(actor.customer).to(beNil())
                    expect(request.customer).to(beNil())
                } else {
                    expect(actor.customer).to(equal(customer))
                    expect(request.customer).to(equal(customer))
                }


                expect(request.config.authenticationType.description)
                    .to(equal(actor.config.authenticationType.description))

                expect(request.accounts).to(beEmpty())

                let sessionId = try! session.sessionStore.getId()
                expect(request.parametersForSigning()["session"]).to(equal(sessionId))
                let sessionKey = try! session.sessionStore.getKey()
                expect(request.signingKey()).to(equal("\(config.authenticationType.psk)\(sessionKey)"))
            }

            testNewRequestWithCustomerInSession(config: configApplication, session: sessionApplication, customer: "customer1")
            testNewRequestWithCustomerInSession(config: configApplication, session: sessionApplication, customer: nil)
        }

        it("should throw the correct error when an invalid session is used") {
            for (config, session) in [(configUser, sessionUser), (configUserDefaultAccount, sessionUserDefaultAccount)] {
                let actor = Actor(config: config, session: session)
                expect {
                    try actor.newRequest(command: "command", action: "action")
                }.to(throwError(RequestError.UserAuthenticationNotSupported))
            }
        }

        it("should correctly check for global tokens") {
            let testHasTokenGlobal: (config: Config, token: String, hasToken: Bool) -> Void = {
                config, token, hasToken in

                let actor = TestActor(config: config)
                // We set the accounts to empty to remove any default account if set
                actor.accounts = []
                var done = false

                // Will not throw
                try! actor.hasToken(token) { hasTokenResponse in
                    expect(hasTokenResponse.value).to(equal(hasToken))
                    done = true
                }

                expect(done).toEventually(beTrue())
            }

            testHasTokenGlobal(config: configUser, token: "a", hasToken: true)
            testHasTokenGlobal(config: configUser, token: "b", hasToken: true)
            testHasTokenGlobal(config: configUserDefaultAccount, token: "b", hasToken: true)
            testHasTokenGlobal(config: configUser, token: "d", hasToken: false)
            testHasTokenGlobal(config: configUserDefaultAccount, token: "e", hasToken: false)
            testHasTokenGlobal(config: configUser, token: "s", hasToken: false)
            testHasTokenGlobal(config: configUser, token: "z", hasToken: false)
            testHasTokenGlobal(config: configApplication, token: "z", hasToken: true)
            testHasTokenGlobal(config: configApplication, token: "y", hasToken: false)
            testHasTokenGlobal(config: configApplication, token: "t", hasToken: false)
            testHasTokenGlobal(config: configApplication, token: "a", hasToken: false)
        }

        it("should correctly check for global tokens in a session") {
            let testHasTokenGlobalInSession: (config: Config, session: Session, token: String, hasToken: Bool) -> Void = {
                config, session, token, hasToken in

                let actor = TestActor(config: config, session: session)
                // We set the accounts to empty to remove any default account if set
                actor.accounts = []
                var done = false

                // Will not throw
                try! actor.hasToken(token) { hasTokenResponse in
                    expect(hasTokenResponse.value).to(equal(hasToken))
                    done = true
                }

                expect(done).toEventually(beTrue())
            }

            testHasTokenGlobalInSession(config: configApplication, session: sessionApplication,
                token: "a", hasToken: true)
            testHasTokenGlobalInSession(config: configApplication, session: sessionApplication,
                token: "b", hasToken: true)
            testHasTokenGlobalInSession(config: configApplicationDefaultAccount,
                session: sessionApplicationDefaultAccount, token: "b", hasToken: true)
            testHasTokenGlobalInSession(config: configApplication, session: sessionApplication,
                token: "d", hasToken: false)
            testHasTokenGlobalInSession(config: configApplicationDefaultAccount,
                session: sessionApplicationDefaultAccount, token: "e", hasToken: false)
            testHasTokenGlobalInSession(config: configApplication, session: sessionApplication,
                token: "s", hasToken: false)
            testHasTokenGlobalInSession(config: configApplication, session: sessionApplication,
                token: "z", hasToken: false)
        }

        it("should correctly check for tokens in accounts") {
            let testHasTokenInAccounts: (config: Config, accounts: [String], token: String, hasToken: Bool) -> Void = {
                config, accounts, token, hasToken in

                let actor = TestActor(config: config)
                actor.accounts = accounts
                var done = false

                // Will not throw
                try! actor.hasToken(token) { hasTokenResponse in
                    expect(hasTokenResponse.value).to(equal(hasToken))
                    done = true
                }

                expect(done).toEventually(beTrue())
            }

            testHasTokenInAccounts(config: configUser, accounts: ["A1"],
                token: "a", hasToken: true) // globally, should be OK
            testHasTokenInAccounts(config: configUser, accounts: ["A1"],
                token: "f", hasToken: true) // directly from A1
            testHasTokenInAccounts(config: configUser, accounts: ["A1"],
                token: "g", hasToken: true) // directly from A1
            testHasTokenInAccounts(config: configUser, accounts: ["A1"],
                token: "h", hasToken: false) // h is on A2
            testHasTokenInAccounts(config: configUser, accounts: ["A2"],
                token: "h", hasToken: true) // directly from A2
            testHasTokenInAccounts(config: configUser, accounts: ["A1"],
                token: "t", hasToken: false) // unknown token
            testHasTokenInAccounts(config: configUser, accounts: ["A3"],
                token: "a", hasToken: true) // globally
            testHasTokenInAccounts(config: configUser, accounts: ["A4"],
                token: "q", hasToken: false) // unknown token
            // Default account does not matter here anymore, already tested default account stuff
            testHasTokenInAccounts(config: configApplication, accounts: ["A1"],
                token: "a", hasToken: false) // a is for users, not apps
            testHasTokenInAccounts(config: configApplication, accounts: ["A1"],
                token: "z", hasToken: true) // globally
            testHasTokenInAccounts(config: configApplication, accounts: ["A1"],
                token: "w", hasToken: true) // from A1
            testHasTokenInAccounts(config: configApplication, accounts: ["A1"],
                token: "p", hasToken: true) // from C1
            testHasTokenInAccounts(config: configApplication, accounts: ["A1"],
                token: "y", hasToken: true) // from C1
            testHasTokenInAccounts(config: configApplication, accounts: ["A1"],
                token: "x", hasToken: false) // from C2, so not A1
            testHasTokenInAccounts(config: configApplication, accounts: ["A5"],
                token: "z", hasToken: true) // globally

            testHasTokenInAccounts(config: configUser, accounts: ["A1", "A2"],
                token: "g", hasToken: true) // g is shared between both accounts
            testHasTokenInAccounts(config: configUser, accounts: ["A1", "A2"],
                token: "f", hasToken: false) // f is only in A1
            testHasTokenInAccounts(config: configUser, accounts: ["A1", "A2"],
                token: "h", hasToken: false) // h is only in A2
            testHasTokenInAccounts(config: configUser, accounts: ["A1", "A2"],
                token: "a", hasToken: true) // a is global
            testHasTokenInAccounts(config: configUser, accounts: ["A1", "A2", "A3"],
                token: "g", hasToken: false) // A3 does not have any tokens
            testHasTokenInAccounts(config: configUser, accounts: ["A1", "A2", "A3"],
                token: "a", hasToken: true) // a is still global
            testHasTokenInAccounts(config: configUser, accounts: ["A1", "A2", "A3"],
                token: "q", hasToken: false) // q does not exist
            testHasTokenInAccounts(config: configApplication, accounts: ["A1", "A2", "A3"],
                token: "z", hasToken: true) // z is global
            testHasTokenInAccounts(config: configApplication, accounts: ["A1", "A2", "A3"],
                token: "p", hasToken: true) // p is shared between both customers
            testHasTokenInAccounts(config: configApplication, accounts: ["A1", "A3"],
                token: "v", hasToken: true) // v is shared between both accounts
            testHasTokenInAccounts(config: configApplication, accounts: ["A1", "A3"],
                token: "w", hasToken: false) // w is only in A1
            testHasTokenInAccounts(config: configApplication, accounts: ["A1", "A2", "A3"],
                token: "v", hasToken: false) // v is only in A1 and A3
        }

        it("should correctly check for tokens in accounts when using a session") {
            let testHasTokenInAccountsWithSession: (config: Config, session: Session, accounts: [String], token: String, hasToken: Bool) -> Void = {
                config, session, accounts, token, hasToken in

                let actor = TestActor(config: config, session: session)
                actor.accounts = accounts
                var done = false

                // Will not throw
                try! actor.hasToken(token) { hasTokenResponse in
                    expect(hasTokenResponse.value).to(equal(hasToken))
                    done = true
                }

                expect(done).toEventually(beTrue())
            }

            // The same tests as for the user* tests from the previous one, but then with application*,
            // as these should now be for the user
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1"], token: "a", hasToken: true) // globally, should be OK
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1"], token: "f", hasToken: true) // directly from A1
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1"], token: "g", hasToken: true) // directly from A1
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1"], token: "h", hasToken: false) // h is on A2
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A2"], token: "h", hasToken: true) // directly from A2
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1"], token: "t", hasToken: false) // unknown token
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A3"], token: "a", hasToken: true) // globally
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A4"], token: "q", hasToken: false) // unknown token

            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1", "A2"], token: "g", hasToken: true) // g is shared between both accounts
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1", "A2"], token: "f", hasToken: false) // f is only in A1
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1", "A2"], token: "h", hasToken: false) // h is only in A2
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1", "A2"], token: "a", hasToken: true) // a is global
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1", "A2", "A3"], token: "g", hasToken: false) // A3 does not have any tokens
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1", "A2", "A3"], token: "a", hasToken: true) // a is still global
            testHasTokenInAccountsWithSession(config: configApplication, session: sessionApplication,
                accounts: ["A1", "A2", "A3"], token: "q", hasToken: false) // q does not exist
        }

        it("should correctly check for tokens in a customer") {
            let testHasTokenInCustomer: (config: Config, customer: String, token: String, hasToken: Bool) -> Void = {
                config, customer, token, hasToken in

                let actor = TestActor(config: config)
                actor.customer = customer
                var done = false

                // Will not throw
                try! actor.hasToken(token) { hasTokenResponse in
                    expect(hasTokenResponse.value).to(equal(hasToken))
                    done = true
                }

                expect(done).toEventually(beTrue())
            }

            testHasTokenInCustomer(config: configUser, customer: "C1",
                token: "a", hasToken: true) // global
            testHasTokenInCustomer(config: configUser, customer: "C5",
                token: "a", hasToken: true) // global, even though customer has nothing itself
            testHasTokenInCustomer(config: configUser, customer: "C1",
                token: "f", hasToken: false) // in A1, not C1
            testHasTokenInCustomer(config: configUser, customer: "C1",
                token: "q", hasToken: false) // unknown token
            testHasTokenInCustomer(config: configApplication, customer: "C1",
                token: "z", hasToken: true) // global
            testHasTokenInCustomer(config: configApplication, customer: "C1",
                token: "y", hasToken: true) // in C1
            testHasTokenInCustomer(config: configApplication, customer: "C1",
                token: "p", hasToken: true) // in C1
            testHasTokenInCustomer(config: configApplication, customer: "C1",
                token: "x", hasToken: false) // in C2, not C1
            testHasTokenInCustomer(config: configApplication, customer: "C1",
                token: "w", hasToken: false) // in A1, not C1
        }

        it("should correctly check for tokens in a customer with a session") {
            let testHasTokenInCustomerWithSession: (config: Config, session: Session, customer: String, token: String, hasToken: Bool) -> Void = {
                config, session, customer, token, hasToken in

                let actor = TestActor(config: config, session: session)
                actor.customer = customer
                var done = false

                // Will not throw
                try! actor.hasToken(token) { hasTokenResponse in
                    expect(hasTokenResponse.value).to(equal(hasToken))
                    done = true
                }

                expect(done).toEventually(beTrue())
            }

            // The same tests as for the user* tests from the previous one, but then with application*,
            // as these should now be for the user
            testHasTokenInCustomerWithSession(config: configApplication, session: sessionApplication,
                customer: "C1", token: "a", hasToken: true) // global
            testHasTokenInCustomerWithSession(config: configApplication, session: sessionApplication,
                customer: "C5", token: "a", hasToken: true) // global, even though customer has nothing itself
            testHasTokenInCustomerWithSession(config: configApplication, session: sessionApplication,
                customer: "C1", token: "f", hasToken: false) // in A1, not C1
            testHasTokenInCustomerWithSession(config: configApplication, session: sessionApplication,
                customer: "C1", token: "q", hasToken: false) // unknown token
        }

        // Testing caching is non-trivial in Swift, as we would either need to mock the actor
        // (which can not be done) or do some strange hacks only to test caching.
    }
}