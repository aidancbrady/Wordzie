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
    var terms:[(String, String)] = [(String, String)]()
    
    @IBAction func doneButton(sender: AnyObject)
    {
        
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController!.setToolbarHidden(false, animated: false)
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
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
