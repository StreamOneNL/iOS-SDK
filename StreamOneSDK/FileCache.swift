//
//  FileCache.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 27-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    A caching implementation using files on disk
*/
public final class FileCache : Cache {
    /**
        Base directory to store cache files in
    */
    let baseDir: String
    
    /**
        Expiration time for cached objects
    */
    let expirationTime: NSTimeInterval
    
    /**
        Construct a FileCache

        - Parameter baseDir: Base directory to store cache files in
        - Parameter expirationTime: Expiration time for cached objects
    */
    public init(baseDir: String, expirationTime: NSTimeInterval) throws {
        self.baseDir = baseDir
        self.expirationTime = expirationTime
        
        // Create directory if it does not exist
        if !NSFileManager.defaultManager().fileExistsAtPath(self.baseDir) {
            try NSFileManager.defaultManager().createDirectoryAtPath(self.baseDir, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /**
        Get the value of a stored key
        
        - Parameter key: Key to get the cached value of
        - Returns: Cached value of the key, or nil if value not found or expired
    */
    public func getKey(key: String) -> AnyObject? {
        do {
            return try getFileContents(key)
        } catch (_) {
            return nil
        }
    }
    
    /**
        Get the age of a stored key in seconds
        
        - Parameter key: Key to get the age of
        - Returns: Age of the key in seconds, or false if value not found or expired
    */
    public func ageOfKey(key: String) -> NSTimeInterval? {
        let filename = self.filename(key)
        
        guard NSFileManager.defaultManager().fileExistsAtPath(filename) else { return nil }
        
        let attributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(filename)
        let modificationDate = attributes[NSFileModificationDate] as! NSDate
        
        return NSDate().timeIntervalSince1970 - modificationDate.timeIntervalSince1970
    }
    
    /**
        Store a value for the given key
        
        Storing a value may not guarantee it being available, so first storing a value and then
        immediately retrieving it may still not give a valid result. For example, the
        NoopCache stores nothing so get(...) will never return any value.
        
        - Parameter key: Key to cache the value for
        - Parameter value: Value to store for the given key
    */
    public func setKey(key: String, value: AnyObject) {
        // Note we write the value as a dictionary with 1 item, as NSJSONSerialization.dataWithJSONObject requires either an array
        // or dictionary as top-level element
        let valueToWrite = ["value": value]
        let content = try! NSJSONSerialization.dataWithJSONObject(valueToWrite, options: NSJSONWritingOptions(rawValue: 0))
        
        content.writeToFile(filename(key), atomically: true)
    }
    
    
    /**
        Retrieve the contents for a file given by a key

        - Parameter key: Key to get the cached value of
        - Returns: The contents of the the file for the given key or false if the file does not exist or is expired
    */
    private func getFileContents(key: String) throws -> AnyObject? {
        let filename = self.filename(key)
        
        guard NSFileManager.defaultManager().fileExistsAtPath(filename) else { return nil }
        
        let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(filename)
        let modificationDate = attributes[NSFileModificationDate] as! NSDate
        
        if modificationDate.timeIntervalSince1970 + expirationTime < NSDate().timeIntervalSince1970 {
            try NSFileManager.defaultManager().removeItemAtPath(filename)
            return nil
        }
        
        let contents = NSFileManager.defaultManager().contentsAtPath(filename)!
        
        // Unwrap the dictionary again
        if let object = try NSJSONSerialization.JSONObjectWithData(contents, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
            return object["value"]
        }
        
        return nil
    }
    
    /**
        Calculate the filename to store a given key in

        - Parameter key: Key to calculate the filename for
        - Returns: Filename to store the key's value in
    */
    private func filename(key: String) -> String {
        return (baseDir as NSString).stringByAppendingPathComponent(key)
    }
}