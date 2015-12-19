//
//  Password.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Crypto
import JFCommon

/**
    Class to generate password-related data
*/
public struct Password {
    /**
        Generate a password response for a given password and a salt and challenge from the server

        - Parameter password: The password to generate a response for
        - Parameter salt: The salt to use to generate the response
        - Parameter challenge: The challenge to use
        - Returns: the generated response or nil if the salt is invalid
    */
    public static func generatePasswordResponse(password password: String, salt: String, challenge: String) -> String? {
        if let passwordHash = JFBCrypt.hashPassword(password.MD5!, withSalt: salt) {
            let shaPasswordHash = passwordHash.SHA256!
            let passwordHashWithChallenge = "\(shaPasswordHash)\(challenge)".SHA256!
            return (passwordHashWithChallenge ^ passwordHash).base64encode()
        }

        return nil
    }

    /**
        This function will generate a password hash based on the API version 2 password hashing system

        This is used if the session/initialize API responds that one should send the API version 2 password.
        This is only needed once for every user, as the StreamOne platform will convert the user password to the API
        version 3 system automatically afterwards

        - Parameter password: The plain text password of the user
        - Returns: The hashed password
    */
    public static func generateV2PasswordHash(password: String) -> String {
        return password.MD5!
    }
}