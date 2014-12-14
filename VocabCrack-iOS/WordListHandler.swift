//
//  WordListHandler.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/10/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

struct CoreFiles
{
    static let dataFile:NSString = WordListHandler.getDocumentsDir().stringByAppendingPathComponent("ListData.txt")
    static let wordFile:NSString = WordListHandler.getDocumentsDir().stringByAppendingPathComponent("WordData.txt")
    static let defaultList:NSString = WordListHandler.getDefaultList()
}

class WordListHandler
{
    class func loadList(id:String, controller:WeakWrapper<NewGameController>)
    {
        Constants.CORE.listID = nil
        Constants.CORE.activeList.removeAll(keepCapacity: false)
        
        if id == "Default"
        {
            loadDefaultList(controller);
        }
        else {
            loadCustomList(id, controller: controller);
        }
    }
    
    class func loadCustomList(id:String, controller:WeakWrapper<NewGameController>)
    {
        println("Loading '" + id + "' word list...");
        
        let url = Constants.CORE.listURLs[id]!
        
        let reader:Utilities.HTTPReader = Utilities.HTTPReader()
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        var returned = false
        
        reader.getHTTP(request)
        {
            (response:String?) -> Void in
            if let str = response
            {
                let array:[String] = str.componentsSeparatedByString("\n")
                
                if array.count == 1 && array[0] == "null"
                {
                    controller.value?.listLoaded(false)
                    returned = true
                    return
                }
                
                var failed:Bool = false
                
                for s in array
                {
                    let split:[String] = Utilities.split(s, separator: String(Constants.LIST_SPLITTER))
                    
                    if split.count != 2
                    {
                        failed = true
                        
                        break
                    }
                    
                    Constants.CORE.activeList.append(Utilities.trim(s))
                }
                
                if !failed && Constants.CORE.activeList.count >= 10
                {
                    Constants.CORE.listID = id
                    controller.value?.listLoaded(true)
                }
                else {
                    Constants.CORE.activeList.removeAll(keepCapacity: false)
                    controller.value?.listLoaded(false)
                }
                
                returned = true
            }
            else {
                println("Failed to load '" + id + "' word list.")
            }
            
            return
        }
        
        if !returned
        {
            controller.value?.listLoaded(false)
        }
    }
    
    class func loadDefaultList(controller:WeakWrapper<NewGameController>)
    {
        let manager:NSFileManager = NSFileManager()
        
        println("Loading default word list...");
        
        if manager.fileExistsAtPath(CoreFiles.defaultList)
        {
            let content:String = NSString(contentsOfFile: CoreFiles.defaultList, encoding: NSUTF8StringEncoding, error: nil)!
            let split = content.componentsSeparatedByString("\n")
            
            var failed = false
            
            for str in split
            {
                let dataSplit = Utilities.split(str, separator: String(Constants.LIST_SPLITTER))
                
                if(dataSplit.count != 2)
                {
                    failed = true
                    
                    break
                }
                
                Constants.CORE.activeList.append(Utilities.trim(str));
            }
            
            if !failed && Constants.CORE.activeList.count >= 10
            {
                Constants.CORE.listID = "Default"
                controller.value?.listLoaded(true)
            }
            else {
                Constants.CORE.activeList.removeAll(keepCapacity: false)
                controller.value?.listLoaded(false)
            }
        }
        else {
            controller.value?.listLoaded(false)
        }
    }
    
    class func loadListData()
    {
        let manager:NSFileManager = NSFileManager()
        
        println("Loading word list data...")
        if manager.fileExistsAtPath(CoreFiles.dataFile)
        {
            let content:String = NSString(contentsOfFile: CoreFiles.dataFile, encoding: NSUTF8StringEncoding, error: nil)!
            let split = content.componentsSeparatedByString("\n")
            
            for str in split
            {
                let dataSplit = Utilities.split(str, separator: ":")
                
                if dataSplit.count == 2
                {
                    if dataSplit[0] != "Default" && dataSplit[1] != "DefaultURL"
                    {
                        Constants.CORE.listURLs[dataSplit[0]] = dataSplit[1]
                    }
                }
            }
        }
    
        Constants.CORE.listURLs["Default"] = "DefaultURL"
    }
    
    class func saveListData()
    {
        let manager:NSFileManager = NSFileManager()
        
        println("Saving word list data...")
        
        if manager.fileExistsAtPath(CoreFiles.dataFile)
        {
            manager.removeItemAtPath(CoreFiles.dataFile, error: nil)
        }
        
        manager.createFileAtPath(CoreFiles.dataFile, contents: nil, attributes: nil)
        
        var str = NSMutableString()
        
        for entry in Constants.CORE.listURLs
        {
            str.appendString("\(entry.0):\(entry.1)\n")
        }
        
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)!
        data.writeToFile(CoreFiles.dataFile, atomically: true)
    }
    
    class func listNames() -> [String]
    {
        return Array(Constants.CORE.listURLs.keys)
    }
    
    class func addList(name:String, url:String)
    {
        Constants.CORE.listURLs[name] = url
        saveListData()
    }
    
    class func deleteList(name:String)
    {
        Constants.CORE.listURLs.removeValueForKey(name)
        saveListData();
    }
    
    class func getDocumentsDir() -> NSString
    {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        return paths.objectAtIndex(0) as NSString
    }
    
    class func getDefaultList() -> NSString
    {
        return NSBundle.mainBundle().pathForResource("DefaultList", ofType: "txt")!
    }
}