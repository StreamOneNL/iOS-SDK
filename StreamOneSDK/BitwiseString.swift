//
//  BitwiseString.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Bitwise XOR of two strings

    Each unicode character in `lhs` and `rhs` at the same position will be XOR'ed.
    The resulting string will have a length equal to the length of the shortest input string.

    - Parameter lhs: The first argument to bitwise XOR
    - Parameter rhs: The second argument to bitwise XOR
    - Returns: The bitwise XOR'ed string
*/
func ^(lhs: String, rhs: String) -> String {

    var result = String()
    let start = min(lhs.unicodeScalars.startIndex, rhs.unicodeScalars.startIndex)
    let end = min(lhs.unicodeScalars.endIndex, rhs.unicodeScalars.endIndex)
    for idx in start..<end {
        let char = UnicodeScalar(lhs.unicodeScalars[idx].value ^ rhs.unicodeScalars[idx].value)
        result.append(char)
    }

    return result
}