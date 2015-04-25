//
//  FriendsController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/6/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class FriendsController: TableDataReceiver
{
    var friends:[Account] = [Account]()
    var requests:[Account] = [Account]()
    
    var refresher:UIRefreshControl!
    
    @IBOutlet weak var modeButton: UISegmentedControl!
    
    @IBAction func modeChanged(sender: AnyObject)
    {
        tableView.reloadData()
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func receiveData(obj: AnyObject, type: Int)
    {
        if type == 0
        {
            friends = obj as! [Account]
        }
        else if type == 1
        {
            requests = obj as! [Account]
        }
    }
    
    override func endRefresh()
    {
        if refresher.refreshing
        {
            refresher.endRefreshing()
        }
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
    
    func updateModeTitle()
    {
        if requests.count > 0
        {
            modeButton.setTitle("Requests (\(requests.count))", forSegmentAtIndex: 1)
        }
        else {
            modeButton.setTitle("Requests", forSegmentAtIndex: 1)
        }
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
        let cell:FriendCell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        var account:Account = modeButton.selectedSegmentIndex == 0 ? friends[indexPath.row] : requests[indexPath.row]
        
        if modeButton.selectedSegmentIndex == 0
        {
            if account.isRequest
            {
                cell.usernameLabel.text = account.username + " (Requested)"
                cell.lastSeenLabel.text = "Awaiting approval"
            }
            else {
                Utilities.loadAvatar(WeakWrapper(value: cell.userAvatar), email: account.email!)
                cell.usernameLabel.text = account.username
                cell.lastSeenLabel.text = "Last Login: " + Utilities.interpretLogin(account.lastLogin)
            }
        }
        else {
            cell.usernameLabel.text = account.username
            cell.lastSeenLabel.text = "Awaiting approval"
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
                
                updateModeTitle()
                
                if remoteDelete
                {
                    Handlers.friendHandler.deleteFriend(username, type: type)
                }
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
}
