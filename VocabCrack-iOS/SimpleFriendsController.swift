//
//  SimpleFriendsController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/10/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class SimpleFriendsController: TableDataReceiver
{
    var friends:[Account] = [Account]()
    
    var refresher:UIRefreshControl!
    var newController:NewGameController?
    
    override func receiveData(_ obj: Any, type: Int)
    {
        if type == 0
        {
            friends = obj as! [Account]
            friends = friends.filter({element in !element.isRequest})
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
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
        refresher.addTarget(self, action: #selector(SimpleFriendsController.onRefresh), for: UIControlEvents.valueChanged)
        refreshControl = refresher
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        Handlers.friendHandler.updateFriends(WeakWrapper(value: self))
    }
    
    func onRefresh()
    {
        Handlers.friendHandler.updateFriends(WeakWrapper(value: self))
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:FriendCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        
        let account:Account = friends[(indexPath as NSIndexPath).row]
        
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
        
        cell.user = account
        cell.controller = self
        
        return cell
    }
}
