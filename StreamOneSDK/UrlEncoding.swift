//
//  UrlEncoding.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 08-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    We need a protocol to be able to add an extension to a typed dictionary
*/
protocol UrlEncodable {
    /**
        The string that can be URL encoded
    */
    var urlEncodableString: String { get }
}

/**
    Make UrlEncodable conform to Comparable so we can use <
*/
extension Comparable where Self: UrlEncodable {}

func ==(lhs: UrlEncodable, rhs: UrlEncodable) -> Bool {
    return lhs.urlEncodableString == rhs.urlEncodableString
}

func <(lhs: UrlEncodable, rhs: UrlEncodable) -> Bool {
    return lhs.urlEncodableString < rhs.urlEncodableString
}

/**
    Make String conform to the UrlEncodable protocol
*/
extension String : UrlEncodable {
    var urlEncodableString: String {
        return self
    }
}

/**
    Add url encodability to UrlEncodable dictionaries
*/
extension Dictionary where Key: UrlEncodable, Value: UrlEncodable {
    /**
        Encode the dictionary to URL query parameters
    
        For the order of the parameters the keys are sorted case-sensitive. This is done because
        Alamofire also does this for POST-data, so we need to mimic that here
    
        - Returns: The URL encoded string
    */
    func urlEncode() -> String {
        var result = [String]()

        // Define function that just uses <, because otherwise compiler complains that [Key] can
        // not be cast to [UrlEncodable]
        let lt: (lhs: Key, rhs: Key) -> Bool = { $0 < $1 }

        for key in keys.sort(lt) {
            // Set of characters allowed in a query parameter / value
            // Note that NSCharacterSet.URLQueryAllowedCharacterSet() also contains = and &.
            // We remove those manually from the set
            let set = NSMutableCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
            set.removeCharactersInString("=&?/+:,")
            set.addCharactersInString(" ")

            // The encoded key
            let urlKey = key.urlEncodableString.stringByAddingPercentEncodingWithAllowedCharacters(set)!
            // The encoded value
            let urlValue = self[key]!.urlEncodableString.stringByAddingPercentEncodingWithAllowedCharacters(set)!.stringByReplacingOccurrencesOfString(" ", withString: "+")

            // Append it to our result
            result.append(urlKey + "=" + urlValue)
        }

        // Join everything together with &
        return result.joinWithSeparator("&")
    }
}