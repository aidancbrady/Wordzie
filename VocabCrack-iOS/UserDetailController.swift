//
//  UserDetailController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/9/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class UserDetailController: UIViewController
{
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var gamesWon: UILabel!
    @IBOutlet weak var gamesLost: UILabel!
    @IBOutlet weak var lastLogin: UILabel!
    
    var acct:Account?
    
    func setAccountData()
    {
        Utilities.loadAvatar(WeakWrapper(value: userAvatar), email: acct!.email!)
        
        usernameLabel.text = acct!.username
        gamesWon.text = String("Games Won: \(acct!.gamesWon)")
        gamesLost.text = String("Games Lost: \(acct!.gamesLost)")
        lastLogin.text = "Last Login: " + Utilities.interpretLogin(acct!.lastLogin)
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    @IBAction func newGame(sender: AnyObject)
    {
        let controller:NewGameController = storyboard?.instantiateViewControllerWithIdentifier("NewGameController") as NewGameController
        
        controller.definedUser = acct!.username
        
        navigationController!.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Handlers.friendHandler.getInfo(WeakWrapper(value: self), friend:acct!.username)
        setAccountData()
    }
}
