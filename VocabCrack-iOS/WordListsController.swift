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
    var urlArray:[(String, String)] = [(String, String)]()
    
    func compileArray()
    {
        urlArray.removeAll(keepCapacity: false)
        
        for index in Constants.CORE.listURLs
        {
            urlArray.append(index.0, index.1)
        }
        
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    @IBAction func onLongPress(sender: UILongPressGestureRecognizer)
    {
        let p:CGPoint = sender.locationInView(tableView)
        let path:NSIndexPath? = tableView!.indexPathForRowAtPoint(p)
        
        if path != nil && sender.state == UIGestureRecognizerState.Began
        {
            let cell = tableView.cellForRowAtIndexPath(path!) as ListCell
            
            if cell.identifierLabel.text != "Default"
            {
                Utilities.displayAction(self, button: "Copy URL", action: {action in
                    UIPasteboard.generalPasteboard().string = cell.urlLabel.text
                })
            }
        }
    }

    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        compileArray()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        compileArray()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return urlArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:ListCell = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as ListCell
        
        cell.identifierLabel.text = urlArray[indexPath.row].0
        cell.urlLabel.text = urlArray[indexPath.row].1
        cell.controller = self
        
        if cell.urlLabel.text == "DefaultURL"
        {
            cell.urlLabel.text = "embedded"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            WordListHandler.deleteList(urlArray[indexPath.row].0)
            urlArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
