//
//  Base64.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

extension String {
    /**
        Return the base64 encoded value of a string
    */
    func base64encode() -> String {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions([])
    }
}