//
//  RegisterController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class RegisterController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var registerSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        registerButton.addTarget(self, action: "onRegister", forControlEvents: .TouchUpInside)
        
        registerSpinner.hidden = false
        registerSpinner.hidesWhenStopped = true
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmField.delegate = self
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == usernameField
        {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            confirmField.becomeFirstResponder()
        }
        else if textField == confirmField
        {
            confirmField.resignFirstResponder()
            
            doRegister()
        }
        
        return true
    }
    
    @IBAction func backButton(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onRegister()
    {
        doRegister()
    }
    
    func doRegister()
    {
        if Operations.registering
        {
            return
        }
        
        registerSpinner.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.registering = true
            
            var (success, response) = Handlers.coreHandler.register()
            
            if success
            {
                Utilities.displayAlert(self, title: "Success", msg: "Successfully registered account!", action:{() -> Void in self.dismissViewControllerAnimated(true, completion: nil)})
            }
            else {
                Utilities.displayAlert(self, title: "Error", msg:   "Couldn't register account.", action:{() -> Void in})
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.registering = false
                self.registerSpinner.stopAnimating()
            });
        });
    }
}
