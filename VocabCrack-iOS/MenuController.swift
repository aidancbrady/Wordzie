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
    
    @IBOutlet weak var menuLayer: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        userLabel.text = "Welcome, " + Constants.CORE.account.username + "!"
        Utilities.loadAvatar(WeakWrapper(value: userAvatar), email: Constants.CORE.account.email!)
        
        Utilities.roundButtons(menuLayer)
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func logoutButton(_ sender: AnyObject)
    {
        Constants.CORE.account = Defaults.ACCOUNT
        navigationController!.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func helpButton(_ sender: AnyObject)
    {
        UIApplication.shared.open(URL(string: "http://aidancbrady.com/wordzie/")!)
    }
}
