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
        let manager:FileManager = FileManager()
        
        print("Loading word data...");
        
        if !manager.fileExists(atPath: CoreFiles.wordFile)
        {
            return;
        }
        
        Constants.CORE.learnedWords.removeAll(keepingCapacity: false)
        
        let content:String = try! String(contentsOfFile: CoreFiles.wordFile, encoding: String.Encoding.utf8)
        let split = content.components(separatedBy: ",")
        
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
        let manager:FileManager = FileManager()
        
        print("Saving word data...");
    
        if manager.fileExists(atPath: CoreFiles.wordFile)
        {
            do {
                try manager.removeItem(atPath: CoreFiles.wordFile)
            } catch _ {
            }
        }
        
        manager.createFile(atPath: CoreFiles.wordFile, contents: nil, attributes: nil)
        
        let str = NSMutableString()
        
        for word in Constants.CORE.learnedWords
        {
            str.append(word)
            str.append(",")
        }
        
        let data = str.data(using: String.Encoding.utf8.rawValue)!
        try? data.write(to: URL(fileURLWithPath: CoreFiles.wordFile), options: [.atomic])
    }
    
    class func createWordSet() -> [String]
    {
        var list = [String]()
        
        if Constants.CORE.activeList.count-Constants.CORE.learnedWords.count < 10
        {
            Constants.CORE.learnedWords.removeAll(keepingCapacity: false)
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
