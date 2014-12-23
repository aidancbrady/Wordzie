//
//  CreateListController.swift
//  Wordzie
//
//  Created by aidancbrady on 12/15/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class CreateListController: UITableViewController
{
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var activity:UIActivityIndicatorView!
    
    var editingList:(String, String)?
    
    var terms:[(String, String)] = [(String, String)]()
    
    @IBAction func newTermButton(sender: AnyObject)
    {
        if editingList != nil && terms.count == 0
        {
            return
        }
        
        if terms.count < 50
        {
            let editTerm:UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("EditTermNavigation") as UINavigationController
            
            self.presentViewController(editTerm, animated: true, completion: nil)
        }
        else {
            Utilities.displayAlert(self, title: "Error", msg: "List cannot contain more than 50 terms.", action: nil)
        }
    }
    
    @IBAction func saveButton(sender: AnyObject)
    {
        if editingList != nil && terms.count == 0
        {
            return
        }
        
        if terms.count < 10
        {
            if terms.count > 0
            {
                Utilities.displayAlert(self, title: "Error", msg: "List must contain at least 10 terms.", action: nil)
            }
            
            return
        }
        
        showEntry()
    }
    
    func showEntry()
    {
        if editingList == nil
        {
            Utilities.displayInput(self, title: "Upload List", msg: "Enter a unique identifier for your word list.", placeholder: "List Identifier", handler: {str in
                if str == nil || str == ""
                {
                    Utilities.displayAlert(self, title: "Error", msg: "Please enter an identifier.", action: {action in
                        self.showEntry()
                        return
                    })
                }
                else if str != nil
                {
                    if !Utilities.isValidCredential(str!)
                    {
                        Utilities.displayAlert(self, title: "Error", msg: "Invalid characters.", action: {action in
                            self.showEntry()
                            return
                        })
                    }
                    else if countElements(str!) > 18
                    {
                        Utilities.displayAlert(self, title: "Error", msg: "Too many characters.", action: {action in
                            self.showEntry()
                            return
                        })
                    }
                    else {
                        self.activity.startAnimating()
                        self.saveButton.enabled = false
                        Handlers.listHandler.confirmList(WeakWrapper(value: self), identifier: Utilities.trim(str!))
                    }
                }
            })
        }
        else {
            self.activity.startAnimating()
            self.saveButton.enabled = false
            Handlers.listHandler.editList(WeakWrapper(value: self))
        }
    }
    
    func compileList() -> String
    {
        var str:NSMutableString = NSMutableString()
        
        for term in terms
        {
            str.appendString(term.0 + Constants.SPLITTER_2 + term.1)
            str.appendString(Constants.SPLITTER_1)
        }
        
        return str
    }

    @IBAction func cancelButton(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activity.frame = CGRectMake(0, 0, 20, 20)
        activity.hidesWhenStopped = true
        activity.stopAnimating()
        activity.center = CGPoint(x: 120, y: activity.frame.height/2)
        
        var barButton:UIBarButtonItem = UIBarButtonItem(customView: activity)
        toolbarItems!.append(barButton)
        self.setToolbarItems(toolbarItems, animated: false)
        
        if editingList != nil
        {
            activity.startAnimating()
            WordListHandler.loadListForEdit(editingList!, controller: WeakWrapper(value: self))
        }
        
        self.navigationController!.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        navigationController!.setToolbarHidden(false, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return terms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TermCell", forIndexPath: indexPath) as TermCell

        cell.wordLabel.text = terms[indexPath.row].0

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
            terms.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let indexPath = tableView.indexPathForSelectedRow()
        {
            if segue.destinationViewController is TermDetailController
            {
                (segue.destinationViewController as TermDetailController).term = terms[indexPath.row]
                (segue.destinationViewController as TermDetailController).index = indexPath.row
            }
        }
    }
}
