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
    
    @IBAction func modeChanged(_ sender: AnyObject)
    {
        tableView.reloadData()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func receiveData(_ obj: Any, type: Int)
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
        if refresher.isRefreshing
        {
            refresher.endRefreshing()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(FriendsController.onRefresh), for: UIControlEvents.valueChanged)
        refreshControl = refresher
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        Handlers.friendHandler.updateData(WeakWrapper(value: self))
    }
    
    func updateModeTitle()
    {
        if requests.count > 0
        {
            modeButton.setTitle("Requests (\(requests.count))", forSegmentAt: 1)
        }
        else {
            modeButton.setTitle("Requests", forSegmentAt: 1)
        }
    }
    
    func onRefresh()
    {
        Handlers.friendHandler.updateData(WeakWrapper(value: self))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return modeButton.selectedSegmentIndex == 0 ? friends.count : requests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:FriendCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        
        let account:Account = modeButton.selectedSegmentIndex == 0 ? friends[(indexPath as NSIndexPath).row] : requests[(indexPath as NSIndexPath).row]
        
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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            if !Operations.loadingFriends && !Operations.loadingRequests
            {
                var type = 0
                let username = modeButton.selectedSegmentIndex == 0 ? friends[(indexPath as NSIndexPath).row].username : requests[(indexPath as NSIndexPath).row].username
                
                if modeButton.selectedSegmentIndex == 0
                {
                    type = friends[(indexPath as NSIndexPath).row].isRequest ? 2 : 0
                    friends.remove(at: (indexPath as NSIndexPath).row)
                }
                else {
                    type = 1
                    requests.remove(at: (indexPath as NSIndexPath).row)
                }
                
                updateModeTitle()
                
                if remoteDelete
                {
                    Handlers.friendHandler.deleteFriend(username, type: type)
                }
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
