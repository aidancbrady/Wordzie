//
//  MenuController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class MenuController: UIViewController
{
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        userLabel.text = "Welcome, " + Constants.CORE.account.username + "!"
        Utilities.loadAvatar(WeakWrapper(value: userAvatar), email: Constants.CORE.account.email!)
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func logoutButton(sender: AnyObject)
    {
        Constants.CORE.account = Defaults.ACCOUNT
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
