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
        defaultArray.removeAll(keepCapacity: false)
        WordListHandler.populateDefaults(&defaultArray)
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        
        urlArray.removeAll(keepCapacity: false)
        
        for index in Constants.CORE.listURLs
        {
            urlArray.append(index.0, index.1)
        }
        
        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
        
        Handlers.listHandler.updateLists(WeakWrapper(value: self))
    }
    
    @IBAction func onLongPress(sender: UILongPressGestureRecognizer)
    {
        let p:CGPoint = sender.locationInView(tableView)
        let path:NSIndexPath? = tableView!.indexPathForRowAtPoint(p)
        
        if path != nil && sender.state == UIGestureRecognizerState.Began
        {
            let cell = tableView.cellForRowAtIndexPath(path!) as! ListCell
            
            if cell.identifierLabel.text != "Default"
            {
                if path!.section != 1
                {
                    Utilities.displayAction(self, actions: ActionButton(button: "Copy URL", action: {action in
                        UIPasteboard.generalPasteboard().string = cell.list!.1
                    }))
                }
                else {
                    Utilities.displayAction(self, actions: ActionButton(button: "Edit List", action: {action in
                        let createList:UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("CreateListNavigation") as! UINavigationController
                        (createList.viewControllers[0] as! CreateListController).editingList = cell.list
                        
                        self.presentViewController(createList, animated: true, completion: nil)
                        return
                    }), ActionButton(button: "Copy URL", action: {action in
                        UIPasteboard.generalPasteboard().string = cell.list!.1
                    }))
                }
            }
        }
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidAppear(animated: Bool)
    {
        compileArray()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(WordListsController.onRefresh), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl = refresher
        
        compileArray()
    }
    
    func onRefresh()
    {
        compileArray()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return section == 0 ? defaultArray.count : (section == 1 ? serverArray.count : urlArray.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:ListCell = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as! ListCell
        
        let array:[(String, String)] = indexPath.section == 0 ? defaultArray : (indexPath.section == 1 ? serverArray : urlArray)
        
        cell.identifierLabel.text = array[indexPath.row].0
        cell.urlLabel.text = array[indexPath.row].1
        cell.controller = self
        cell.list = array[indexPath.row]
        
        if indexPath.section == 0
        {
            cell.urlLabel.text = "embedded"
        }
        else if indexPath.section == 1
        {
            cell.urlLabel.text = "uploaded"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return indexPath.section != 0
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            if indexPath.section == 1
            {
                Handlers.listHandler.deleteList(WeakWrapper(value: self), identifier: serverArray[indexPath.row].0)
                serverArray.removeAtIndex(indexPath.row)
            }
            else if indexPath.section == 2
            {
                WordListHandler.deleteList(urlArray[indexPath.row].0)
                urlArray.removeAtIndex(indexPath.row)
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
