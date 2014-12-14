//
//  WordDataHandler.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/10/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class WordDataHandler
{
    class func load()
    {
        let manager:NSFileManager = NSFileManager()
        
        println("Loading word data...");
        
        if !manager.fileExistsAtPath(CoreFiles.wordFile)
        {
            return;
        }
        
        Constants.CORE.learnedWords.removeAll(keepCapacity: false)
        
        let content:String = NSString(contentsOfFile: CoreFiles.wordFile, encoding: NSUTF8StringEncoding, error: nil)!
        let split = content.componentsSeparatedByString(",")
        
        for str in split
        {
            Constants.CORE.learnedWords.append(Utilities.trim(str))
        }
    }
    
    class func save()
    {
        let manager:NSFileManager = NSFileManager()
        
        println("Saving word data...");
    
        if manager.fileExistsAtPath(CoreFiles.wordFile)
        {
            manager.removeItemAtPath(CoreFiles.wordFile, error: nil)
        }
        
        manager.createFileAtPath(CoreFiles.wordFile, contents: nil, attributes: nil)
        
        var str = NSMutableString()
        
        for word in Constants.CORE.learnedWords
        {
            str.appendString(word)
            str.appendString(",")
        }
        
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)!
        data.writeToFile(CoreFiles.wordFile, atomically: true)
    }
}