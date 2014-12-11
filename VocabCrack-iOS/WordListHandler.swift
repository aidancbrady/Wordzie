//
//  WordListHandler.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/10/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class WordListHandler
{
    class func getURL(name:String) -> String?
    {
        if(Constants.CORE.listURLs[Utilities.trim(name)] == nil)
        {
            return nil
        }
    
        return Constants.CORE.listURLs[Utilities.replace(Utilities.trim(name), find: "|", replace: ":")]
    }
    
    class func convertURL(url:String, fromCompiled:Bool) -> String
    {
        return fromCompiled ? Utilities.replace(url, find: "|", replace: ":") : Utilities.replace(url, find: ":", replace: "|")
    }
    
    class func listNames() -> [String]
    {
        return Array(Constants.CORE.listURLs.keys)
    }
    
    class func addList(name:String, url:String)
    {
        Constants.CORE.listURLs[name] = convertURL(url, fromCompiled: false)
        //saveListData()
    }
    
    class func deleteList(name:String)
    {
        Constants.CORE.listURLs.removeValueForKey(name)
        //saveListData();
    }
    
    class func getDocumentsDir() -> NSString
    {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.objectAtIndex(0) as NSString
    }
}