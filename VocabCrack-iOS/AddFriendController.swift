//
//  AddFriendController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/7/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class AddFriendController: UITableViewController, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    
    var activity:UIActivityIndicatorView!
    
    var users:[String] = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activity.frame = CGRectMake(0, 0, 20, 20)
        activity.hidesWhenStopped = true
        activity.stopAnimating()
        
        let barButton:UIBarButtonItem = UIBarButtonItem(customView: activity)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        searchBar.text = ""
        Handlers.friendHandler.updateSearch(WeakWrapper(value: self), query: searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        Handlers.friendHandler.updateSearch(WeakWrapper(value: self), query: searchBar.text!)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserCell

        cell.usernameLabel.text = users[indexPath.row]
        
        cell.controller = self

        return cell
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
