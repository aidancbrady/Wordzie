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
    static let dataFile:String = (WordListHandler.getDocumentsDir() as NSString).appendingPathComponent("ListData.txt")
    static let wordFile:String = (WordListHandler.getDocumentsDir() as NSString).appendingPathComponent("WordData.txt")
    static let defaultList:String = WordListHandler.getDefaultList()
}

class WordListHandler
{
    class func populateDefaults(_ array:inout [(String, String)])
    {
        array.append(("Default", "DefaultURL"))
    }
    
    class func loadList(_ list:(String, String), controller:WeakWrapper<UIViewController>)
    {
        Constants.CORE.listData = nil
        Constants.CORE.activeList.removeAll(keepingCapacity: false)
        
        if list.0 == "Default"
        {
            loadDefaultList(controller)
        }
        else {
            loadCustomList(list, controller: controller)
        }
    }
    
    class func loadCustomList(_ list:(String, String), controller:WeakWrapper<UIViewController>)
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
                    Constants.CORE.activeList.removeAll(keepingCapacity: false)
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
    
    class func listLoaded(_ controller: UIViewController?, success:Bool)
    {
        if controller != nil && controller! is ListLoader
        {
            (controller as! ListLoader).listLoaded(success)
        }
    }
    
    class func loadListForEdit(_ list:(String, String), controller:WeakWrapper<CreateListController>)
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
                    
                    terms.append((split[0], split[1]))
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
                table.saveButton.isEnabled = true
                
                if table.activity.isAnimating
                {
                    table.activity.stopAnimating()
                }
                
                if failed
                {
                    Utilities.displayAlert(table, title: "Error", msg: "Couldn't load word list form server.", action: {action in
                        table.dismiss(animated: true, completion: nil)
                        return
                    })
                }
                else {
                    table.terms = terms
                    table.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                }
            }
        })
    }
    
    class func loadForeignList(_ list:(String, String), handler:@escaping ([String]?) -> Void)
    {
        let reader:Utilities.HTTPReader = Utilities.HTTPReader()
        let request:URLRequest = URLRequest(url: URL(string: list.1)!)
        
        var array:[String]?
        
        reader.getHTTP(request, action: {(response:String?) -> Void in
            if let str = response
            {
                array = str.components(separatedBy: "\n")
            }
            
            handler(array)
            return
        })
    }
    
    class func loadDefaultList(_ controller:WeakWrapper<UIViewController>)
    {
        let manager:FileManager = FileManager()
        
        print("Loading default word list...")
        
        if manager.fileExists(atPath: CoreFiles.defaultList)
        {
            var content:String?
            var failed = false
            
            do {
                try content = String(contentsOfFile: CoreFiles.defaultList, encoding: String.Encoding.utf8)
            } catch {}
            
            if content != nil
            {
                let split = content!.components(separatedBy: "\n")
                
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
                Constants.CORE.activeList.removeAll(keepingCapacity: false)
                WordListHandler.listLoaded(controller.value, success: false)
            }
        }
        else {
            WordListHandler.listLoaded(controller.value, success: false)
        }
    }
    
    class func loadListData()
    {
        let manager:FileManager = FileManager()
        
        print("Loading word list data...")
        if manager.fileExists(atPath: CoreFiles.dataFile)
        {
            var content:String?
            
            do {
                try content = String(contentsOfFile: CoreFiles.dataFile, encoding: String.Encoding.utf8)
            } catch {}
            
            if content != nil
            {
                let split = content!.components(separatedBy: "\n")
                
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
        let manager:FileManager = FileManager()
        
        print("Saving word list data...")
        
        if manager.fileExists(atPath: CoreFiles.dataFile)
        {
            do {
                try manager.removeItem(atPath: CoreFiles.dataFile)
            } catch {}
        }
        
        manager.createFile(atPath: CoreFiles.dataFile, contents: nil, attributes: nil)
        
        let str = NSMutableString()
        
        for entry in Constants.CORE.listURLs
        {
            str.append("\(entry.0):\(entry.1)\n")
        }
        
        let data = str.data(using: String.Encoding.utf8.rawValue)!
        try? data.write(to: URL(fileURLWithPath: CoreFiles.dataFile), options: [.atomic])
    }
    
    class func listNames() -> [String]
    {
        return Array(Constants.CORE.listURLs.keys)
    }
    
    class func addList(_ name:String, url:String)
    {
        Constants.CORE.listURLs[name] = url
        saveListData()
    }
    
    class func deleteList(_ name:String)
    {
        Constants.CORE.listURLs.removeValue(forKey: name)
        saveListData()
    }
    
    class func getDocumentsDir() -> String
    {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        
        return paths.object(at: 0) as! String
    }
    
    class func getDefaultList() -> String
    {
        return Bundle.main.path(forResource: "DefaultList", ofType: "txt")!
    }
}

class ListHandler
{
    func confirmList(_ controller:WeakWrapper<UIViewController>, identifier:String?)
    {
        DispatchQueue.main.async {
            let str = identifier != nil ? compileMsg("CONFLIST", Constants.CORE.account.username, identifier!) : compileMsg("CONFLIST", Constants.CORE.account.username, Constants.NULL)
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
                if let newList = controller.value
                {
                    var uploaded:Bool = false
                    
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            if newList.isKind(of: NewListController.self)
                            {
                                let createList:UINavigationController = newList.storyboard?.instantiateViewController(withIdentifier: "CreateListNavigation") as! UINavigationController
                                
                                newList.present(createList, animated: true, completion: nil)
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
                    
                    let activity:UIActivityIndicatorView = newList.isKind(of: NewListController.self) ? (newList as! NewListController).activityIndicator : (newList as! CreateListController).activity
                    
                    if !uploaded && activity.isAnimating
                    {
                        activity.stopAnimating()
                    }
                }
            }
        }
    }
    
    func uploadList(_ controller:WeakWrapper<CreateListController>, identifier:String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("UPLOAD", Constants.CORE.account.username, identifier, controller.value!.compileList())
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            let amount = Int(array[1])
                            
                            Utilities.displayAlert(table, title: "Success", msg: "Successfully created and uploaded word list. You now have \(amount!) out of 5 word lists.", action: {action in
                                table.dismiss(animated: true, completion: nil)
                                table.navigationController!.presentingViewController!.dismiss(animated: false, completion: nil)
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
                    
                    table.saveButton.isEnabled = true
                    
                    if table.activity.isAnimating
                    {
                        table.activity.stopAnimating()
                    }
                }
            }
        }
    }
    
    func editList(_ controller:WeakWrapper<CreateListController>)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("EDITLIST", Constants.CORE.account.username, controller.value!.editingList!.0, controller.value!.compileList())
            NetHandler.sendData(str)
            
            DispatchQueue.main.async {
                if let table = controller.value
                {
                    table.dismiss(animated: true, completion: nil)
                    
                    table.saveButton.isEnabled = true
                    
                    if table.activity.isAnimating
                    {
                        table.activity.stopAnimating()
                    }
                }
            }
        }
    }
    
    func deleteList(_ controller:WeakWrapper<WordListsController>, identifier:String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("DELLIST", Constants.CORE.account.username, identifier)
            NetHandler.sendData(str)
        }
    }
    
    func updateLists(_ controller:WeakWrapper<WordListsController>)
    {
        if Operations.loadingLists
        {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            Operations.loadingLists = true
            
            let str = compileMsg("LLISTS", Constants.CORE.account.username)
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
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
                                    urlArray.append((split[0], split[1]))
                                }
                            }
                            
                            table.serverArray = urlArray
                            table.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                        }
                    }
                    
                    if table.refresher.isRefreshing
                    {
                        table.refresher.endRefreshing()
                    }
                }
            }
        }
    }
}

@objc protocol ListLoader : class
{
    func listLoaded(_ success:Bool)
}
