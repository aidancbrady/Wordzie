//
//  WordListsController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/13/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class WordListsController: UITableViewController
{
    var newController:NewGameController?
    
    var defaultArray:[(String, String)] = [(String, String)]()
    var serverArray:[(String, String)] = [(String, String)]()
    var urlArray:[(String, String)] = [(String, String)]()
    
    var refresher:UIRefreshControl!
    
    func compileArray()
    {
        defaultArray.removeAll(keepingCapacity: false)
        WordListHandler.populateDefaults(&defaultArray)
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        
        urlArray.removeAll(keepingCapacity: false)
        
        for index in Constants.CORE.listURLs
        {
            urlArray.append((index.0, index.1))
        }
        
        tableView.reloadSections(IndexSet(integer: 2), with: .none)
        
        Handlers.listHandler.updateLists(WeakWrapper(value: self))
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        compileArray()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(WordListsController.onRefresh), for: UIControl.Event.valueChanged)
        refreshControl = refresher
        
        compileArray()
    }
    
    @objc func onRefresh()
    {
        compileArray()
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return section == 0 ? defaultArray.count : (section == 1 ? serverArray.count : urlArray.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:ListCell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        
        let array:[(String, String)] = (indexPath as NSIndexPath).section == 0 ? defaultArray : ((indexPath as NSIndexPath).section == 1 ? serverArray : urlArray)
        
        cell.identifierLabel.text = array[(indexPath as NSIndexPath).row].0
        cell.urlLabel.text = array[(indexPath as NSIndexPath).row].1
        cell.controller = self
        cell.list = array[(indexPath as NSIndexPath).row]
        
        if (indexPath as NSIndexPath).section == 0
        {
            cell.urlLabel.text = "embedded"
        }
        else if (indexPath as NSIndexPath).section == 1
        {
            cell.urlLabel.text = "uploaded"
            cell.owned = true
        }
        
        let recognizer = UILongPressGestureRecognizer()
        recognizer.addTarget(cell, action: #selector(ListCell.onLongPress))
        cell.addGestureRecognizer(recognizer)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 && defaultArray.count > 0
        {
            return "Default Lists"
        }
        else if section == 1 && serverArray.count > 0
        {
            return "Uploaded Lists"
        }
        else if section == 2 && urlArray.count > 0
        {
            return "Referenced Lists"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return (indexPath as NSIndexPath).section != 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            if (indexPath as NSIndexPath).section == 1
            {
                Handlers.listHandler.deleteList(WeakWrapper(value: self), identifier: serverArray[(indexPath as NSIndexPath).row].0)
                serverArray.remove(at: (indexPath as NSIndexPath).row)
            }
            else if (indexPath as NSIndexPath).section == 2
            {
                WordListHandler.deleteList(urlArray[(indexPath as NSIndexPath).row].0)
                urlArray.remove(at: (indexPath as NSIndexPath).row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
