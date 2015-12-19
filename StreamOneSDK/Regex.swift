//
//  Regex.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 08-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

// This file is based on: http://benscheirman.com/2014/06/regex-in-swift/

import Foundation

/**
    Helper struct that can be used to extract regex matches from a string
*/
internal struct Regex {
    /**
        The regular expression to use to match the regex
    */
    private let internalExpression: NSRegularExpression

    /**
        Construct a new Regex struct with the given pattern
        
        - Parameter pattern: the pattern to use
    */
    init(_ pattern: String) throws {
        self.internalExpression = try NSRegularExpression(pattern: pattern,
            options: NSRegularExpressionOptions.CaseInsensitive)
    }

    /**
        Return the matches for a given string
    
        This will only return the matches of the first occurrence of the regex

        - Parameter input: The input to match
        - Returns: the resulting matches
    */
    func matches(input: String) -> [String] {
        let matches = internalExpression.matchesInString(input, options: [], range: NSMakeRange(0, (input as NSString).length))

        if matches.count == 0 {
            return []
        }

        let match = matches[0]

        var result = [String]()
        result.reserveCapacity(match.numberOfRanges)

        for i in 0..<match.numberOfRanges {
            let range = match.rangeAtIndex(i)
            if range.location == NSNotFound {
                result.append("")
            } else {
                result.append((input as NSString).substringWithRange(range))
            }
        }

        return result
    }
}