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
        
        print("Loading word data...");
        
        if !manager.fileExistsAtPath(CoreFiles.wordFile)
        {
            return;
        }
        
        Constants.CORE.learnedWords.removeAll(keepCapacity: false)
        
        let content:String = try! String(contentsOfFile: CoreFiles.wordFile, encoding: NSUTF8StringEncoding)
        let split = content.componentsSeparatedByString(",")
        
        for str in split
        {
            if !str.isEmpty
            {
                Constants.CORE.learnedWords.append(Utilities.trim(str))
            }
        }
    }
    
    class func save()
    {
        let manager:NSFileManager = NSFileManager()
        
        print("Saving word data...");
    
        if manager.fileExistsAtPath(CoreFiles.wordFile)
        {
            do {
                try manager.removeItemAtPath(CoreFiles.wordFile)
            } catch _ {
            }
        }
        
        manager.createFileAtPath(CoreFiles.wordFile, contents: nil, attributes: nil)
        
        let str = NSMutableString()
        
        for word in Constants.CORE.learnedWords
        {
            str.appendString(word)
            str.appendString(",")
        }
        
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)!
        data.writeToFile(CoreFiles.wordFile, atomically: true)
    }
    
    class func createWordSet() -> [String]
    {
        var list = [String]()
        
        if Constants.CORE.activeList.count-Constants.CORE.learnedWords.count < 10
        {
            Constants.CORE.learnedWords.removeAll(keepCapacity: false)
            save()
        }
        
        while list.count < 10
        {
            let word = Constants.CORE.activeList[Int(arc4random_uniform(UInt32(Constants.CORE.activeList.count)))]

            if(!list.contains(word) && !Constants.CORE.learnedWords.contains(Utilities.split(word, separator: String(Constants.LIST_SPLITTER))[0]))
            {
                list.append(word)
            }
        }
        
        return list;
    }
}