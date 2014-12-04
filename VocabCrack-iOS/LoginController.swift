//
//  LoginController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class LoginController: UIViewController
{
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
        
        loginSpinner.hidden = false
        loginSpinner.hidesWhenStopped = true
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func onLogin()
    {
        doLogin()
    }
    
    func doLogin()
    {
        if Operations.loggingIn
        {
            return
        }
        
        loginSpinner.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.loggingIn = true
            
            var (success, response) = Handlers.coreHandler.login()
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.loggingIn = false
                self.loginSpinner.stopAnimating()
                
                let menu:MenuController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuController") as MenuController
                
                self.presentViewController(menu, animated: true, completion: nil)
            });
        });
    }
}
