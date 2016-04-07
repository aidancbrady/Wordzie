//
//  WordListHandler.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/10/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

struct CoreFiles
{
    static let dataFile:String = WordListHandler.getDocumentsDir().stringByAppendingPathComponent("ListData.txt")
    static let wordFile:String = WordListHandler.getDocumentsDir().stringByAppendingPathComponent("WordData.txt")
    static let defaultList:String = WordListHandler.getDefaultList()
}

class WordListHandler
{
    class func populateDefaults(inout array:[(String, String)])
    {
        array.append("Default", "DefaultURL")
    }
    
    class func loadList(list:(String, String), controller:WeakWrapper<UIViewController>)
    {
        Constants.CORE.listData = nil
        Constants.CORE.activeList.removeAll(keepCapacity: false)
        
        if list.0 == "Default"
        {
            loadDefaultList(controller)
        }
        else {
            loadCustomList(list, controller: controller)
        }
    }
    
    class func loadCustomList(list:(String, String), controller:WeakWrapper<UIViewController>)
    {
        print("Loading '" + list.0 + "' word list...")
        
        loadForeignList(list, handler: {response in
            var returned = false
            
            if let array = response
            {
                if array.count == 1 && array[0] == "null"
                {
                    WordListHandler.listLoaded(controller.value, success: false)
                    returned = true
                    return
                }
                
                for s in array
                {
                    let split:[String] = Utilities.split(s, separator: Constants.LIST_SPLITTER)
                    
                    if split.count != 2
                    {
                        continue
                    }
                    
                    Constants.CORE.activeList.append(Utilities.trim(s))
                }
                
                if Constants.CORE.activeList.count >= 10
                {
                    Constants.CORE.listData = list
                    WordListHandler.listLoaded(controller.value, success: true)
                }
                else {
                    Constants.CORE.activeList.removeAll(keepCapacity: false)
                    WordListHandler.listLoaded(controller.value, success: false)
                }
                
                returned = true
            }
            else {
                print("Failed to load '" + list.0 + "' word list.")
            }
            
            if !returned
            {
                WordListHandler.listLoaded(controller.value, success: false)
            }
            
            return
        })
    }
    
    class func listLoaded(controller: UIViewController?, success:Bool)
    {
        if controller != nil && controller! is ListLoader
        {
            (controller as! ListLoader).listLoaded(success)
        }
    }
    
    class func loadListForEdit(list:(String, String), controller:WeakWrapper<CreateListController>)
    {
        print("Loading '" + list.0 + "' word list for editing...")
        
        loadForeignList(list, handler: {response in
            var terms:[(String, String)] = [(String, String)]()
            var failed = false
            
            if let array = response
            {
                if array.count == 1 && array[0] == "null"
                {
                    failed = true
                    return
                }
                
                for s in array
                {
                    let split:[String] = Utilities.split(s, separator: Constants.LIST_SPLITTER)
                    
                    if split.count != 2
                    {
                        continue
                    }
                    
                    terms.append(split[0], split[1])
                }
                
                if terms.count < 10
                {
                    failed = true
                }
            }
            else {
                print("Failed to load '" + list.0 + "' word list.")
                failed = true
            }
            
            if let table = controller.value
            {
                table.saveButton.enabled = true
                
                if table.activity.isAnimating()
                {
                    table.activity.stopAnimating()
                }
                
                if failed
                {
                    Utilities.displayAlert(table, title: "Error", msg: "Couldn't load word list form server.", action: {action in
                        table.dismissViewControllerAnimated(true, completion: nil)
                        return
                    })
                }
                else {
                    table.terms = terms
                    table.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                }
            }
        })
    }
    
    class func loadForeignList(list:(String, String), handler:([String]?) -> Void)
    {
        let reader:Utilities.HTTPReader = Utilities.HTTPReader()
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: list.1)!)
        
        var array:[String]?
        
        reader.getHTTP(request, action: {(response:String?) -> Void in
            if let str = response
            {
                array = str.componentsSeparatedByString("\n")
            }
            
            handler(array)
            return
        })
    }
    
    class func loadDefaultList(controller:WeakWrapper<UIViewController>)
    {
        let manager:NSFileManager = NSFileManager()
        
        print("Loading default word list...")
        
        if manager.fileExistsAtPath(CoreFiles.defaultList)
        {
            var content:String?
            var failed = false
            
            do {
                try content = String(contentsOfFile: CoreFiles.defaultList, encoding: NSUTF8StringEncoding)
            } catch {}
            
            if content != nil
            {
                let split = content!.componentsSeparatedByString("\n")
                
                for str in split
                {
                    let dataSplit = Utilities.split(str, separator: Constants.LIST_SPLITTER)
                    
                    if(dataSplit.count != 2)
                    {
                        failed = true
                        
                        break
                    }
                    
                    Constants.CORE.activeList.append(Utilities.trim(str))
                }
            }
            else {
                failed = true
            }
            
            if !failed && Constants.CORE.activeList.count >= 1
            {
                Constants.CORE.listData = ("Default", "DefaultURL")
                WordListHandler.listLoaded(controller.value, success: true)
            }
            else {
                Constants.CORE.activeList.removeAll(keepCapacity: false)
                WordListHandler.listLoaded(controller.value, success: false)
            }
        }
        else {
            WordListHandler.listLoaded(controller.value, success: false)
        }
    }
    
    class func loadListData()
    {
        let manager:NSFileManager = NSFileManager()
        
        print("Loading word list data...")
        if manager.fileExistsAtPath(CoreFiles.dataFile)
        {
            var content:String?
            
            do {
                try content = String(contentsOfFile: CoreFiles.dataFile, encoding: NSUTF8StringEncoding)
            } catch {}
            
            if content != nil
            {
                let split = content!.componentsSeparatedByString("\n")
                
                for str in split
                {
                    let dataSplit = Utilities.split(str, separator: ":")
                    
                    if dataSplit.count == 2
                    {
                        Constants.CORE.listURLs[dataSplit[0]] = dataSplit[1]
                    }
                }
            }
        }
    }
    
    class func saveListData()
    {
        let manager:NSFileManager = NSFileManager()
        
        print("Saving word list data...")
        
        if manager.fileExistsAtPath(CoreFiles.dataFile)
        {
            do {
                try manager.removeItemAtPath(CoreFiles.dataFile)
            } catch {}
        }
        
        manager.createFileAtPath(CoreFiles.dataFile, contents: nil, attributes: nil)
        
        let str = NSMutableString()
        
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
        saveListData()
    }
    
    class func getDocumentsDir() -> String
    {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        return paths.objectAtIndex(0) as! String
    }
    
    class func getDefaultList() -> String
    {
        return NSBundle.mainBundle().pathForResource("DefaultList", ofType: "txt")!
    }
}

class ListHandler
{
    func confirmList(controller:WeakWrapper<UIViewController>, identifier:String?)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = identifier != nil ? compileMsg("CONFLIST", Constants.CORE.account.username, identifier!) : compileMsg("CONFLIST", Constants.CORE.account.username, Constants.NULL)
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let newList = controller.value
                {
                    var uploaded:Bool = false
                    
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            if newList.isKindOfClass(NewListController)
                            {
                                let createList:UINavigationController = newList.storyboard?.instantiateViewControllerWithIdentifier("CreateListNavigation") as! UINavigationController
                                
                                newList.presentViewController(createList, animated: true, completion: nil)
                            }
                            else {
                                self.uploadList(WeakWrapper(value: newList as! CreateListController), identifier: identifier!)
                                uploaded = true
                            }
                        }
                        else {
                            Utilities.displayAlert(newList, title: "Error", msg: array[1], action: nil)
                        }
                    }
                    else {
                        Utilities.displayAlert(newList, title: "Error", msg: "Unable to connect.", action: nil)
                    }
                    
                    let activity:UIActivityIndicatorView = newList.isKindOfClass(NewListController) ? (newList as! NewListController).activityIndicator : (newList as! CreateListController).activity
                    
                    if !uploaded && activity.isAnimating()
                    {
                        activity.stopAnimating()
                    }
                }
            })
        })
    }
    
    func uploadList(controller:WeakWrapper<CreateListController>, identifier:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("UPLOAD", Constants.CORE.account.username, identifier, controller.value!.compileList())
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            let amount = Int(array[1])
                            
                            Utilities.displayAlert(table, title: "Success", msg: "Successfully created and uploaded word list. You now have \(amount) out of 5 word lists.", action: {action in
                                table.dismissViewControllerAnimated(true, completion: nil)
                                table.navigationController!.presentingViewController!.dismissViewControllerAnimated(false, completion: nil)
                                return
                            })
                        }
                        else {
                            Utilities.displayAlert(table, title: "Error", msg: array[1], action: nil)
                        }
                    }
                    else {
                        Utilities.displayAlert(table, title: "Error", msg: "Unable to connect.", action: nil)
                    }
                    
                    table.saveButton.enabled = true
                    
                    if table.activity.isAnimating()
                    {
                        table.activity.stopAnimating()
                    }
                }
            })
        })
    }
    
    func editList(controller:WeakWrapper<CreateListController>)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("EDITLIST", Constants.CORE.account.username, controller.value!.editingList!.0, controller.value!.compileList())
            NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let table = controller.value
                {
                    table.dismissViewControllerAnimated(true, completion: nil)
                    
                    table.saveButton.enabled = true
                    
                    if table.activity.isAnimating()
                    {
                        table.activity.stopAnimating()
                    }
                }
            })
        })
    }
    
    func deleteList(controller:WeakWrapper<WordListsController>, identifier:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("DELLIST", Constants.CORE.account.username, identifier)
            NetHandler.sendData(str)
        })
    }
    
    func updateLists(controller:WeakWrapper<WordListsController>)
    {
        if Operations.loadingLists
        {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.loadingLists = true
            
            let str = compileMsg("LLISTS", Constants.CORE.account.username)
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.loadingLists = false
                
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            var urlArray:[(String, String)] = [(String, String)]()
                            
                            for i in 1 ..< array.count
                            {
                                let split:[String] = Utilities.split(array[i], separator: Constants.SPLITTER_2)
                                
                                if split.count == 2
                                {
                                    urlArray.append(split[0], split[1])
                                }
                            }
                            
                            table.serverArray = urlArray
                            table.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
                        }
                    }
                    
                    if table.refresher.refreshing
                    {
                        table.refresher.endRefreshing()
                    }
                }
            })
        })
    }
}

@objc protocol ListLoader : class
{
    func listLoaded(success:Bool)
}