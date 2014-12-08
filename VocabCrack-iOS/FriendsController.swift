//
//  FriendsController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/6/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class FriendsController: UITableViewController
{
    var friends:[Account] = [Account]()
    var requests:[Account] = [Account]()
    
    var refresher:UIRefreshControl!
    
    @IBOutlet weak var modeButton: UISegmentedControl!
    
    @IBAction func modeChanged(sender: AnyObject)
    {
        tableView.reloadData()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl = refresher
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        Handlers.friendHandler.updateData(WeakWrapper(value: self))
    }
    
    func onRefresh()
    {
        Handlers.friendHandler.updateData(WeakWrapper(value: self))
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return modeButton.selectedSegmentIndex == 0 ? friends.count : requests.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:FriendCell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as FriendCell
        
        var account:Account = modeButton.selectedSegmentIndex == 0 ? friends[indexPath.row] : requests[indexPath.row]
        
        if modeButton.selectedSegmentIndex == 0
        {
            if account.isRequest
            {
                cell.usernameLabel.text = account.username + " (Requested)"
            }
            else {
                Utilities.loadAvatar(WeakWrapper(value: cell.userAvatar), email: account.email!)
                cell.usernameLabel.text = account.username
            }
        }
        else {
            cell.usernameLabel.text = account.username
        }
        
        cell.user = account
        cell.controller = self

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
            if !Operations.loadingFriends && !Operations.loadingRequests
            {
                var type = 0
                let username = modeButton.selectedSegmentIndex == 0 ? friends[indexPath.row].username : requests[indexPath.row].username
                
                if modeButton.selectedSegmentIndex == 0
                {
                    type = friends[indexPath.row].isRequest ? 2 : 0
                    friends.removeAtIndex(indexPath.row)
                }
                else {
                    type = 1
                    requests.removeAtIndex(indexPath.row)
                }
                
                Handlers.friendHandler.deleteFriend(username, type: type)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}
