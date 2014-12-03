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

        // Do any additional setup after loading the view.
        
        loginButton.addTarget(self, action: "onLogin", forControlEvents: .TouchUpInside)
        
        loginSpinner.hidden = false
        loginSpinner.hidesWhenStopped = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
            println(response)
            dispatch_async(dispatch_get_main_queue(), {
                Operations.loggingIn = false
                self.loginSpinner.stopAnimating()
                
                let menu:MenuController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuController") as MenuController
                
                self.presentViewController(menu, animated: true, completion: nil)
            });
        });
    }
}
