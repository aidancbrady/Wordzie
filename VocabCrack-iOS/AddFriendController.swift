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
        
        activity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activity.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        activity.hidesWhenStopped = true
        activity.stopAnimating()
        
        let barButton:UIBarButtonItem = UIBarButtonItem(customView: activity)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        searchBar.text = ""
        Handlers.friendHandler.updateSearch(WeakWrapper(value: self), query: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        Handlers.friendHandler.updateSearch(WeakWrapper(value: self), query: searchBar.text!)
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell

        cell.usernameLabel.text = users[(indexPath as NSIndexPath).row]
        
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
