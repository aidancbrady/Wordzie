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
            
            onRegister()
        }
        
        return true
    }
    
    @IBAction func backButton(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onRegister()
    {
        if !usernameField.text.isEmpty && !emailField.text.isEmpty && !passwordField.text.isEmpty
        {
            if passwordField.text == confirmField.text
            {
                if Utilities.isValidCredential(usernameField.text, emailField.text, passwordField.text)
                {
                    doRegister(usernameField.text, email:emailField.text, password:passwordField.text)
                }
                else {
                    Utilities.displayAlert(self, title: "Warning", msg: "Invalid characters.", action: nil)
                }
            }
            else {
                Utilities.displayAlert(self, title: "Warning", msg: "Passwords don't match.", action: nil)
            }
        }
    }
    
    func doRegister(username:String, email:String, password:String)
    {
        if Operations.registering
        {
            return
        }
        
        registerSpinner.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.registering = true
            
            var (success, response) = Handlers.coreHandler.register(username, email:email, password:password)
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.registering = false
                self.registerSpinner.stopAnimating()
                
                if success
                {
                    Utilities.displayAlert(self, title: "Success", msg: "Successfully registered account!", action:{(act) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
                else {
                    let alertMsg = response != nil ? response! : "Unable to connect."
                    Utilities.displayAlert(self, title: "Couldn't register", msg: alertMsg, action: nil)
                }
            })
        })
    }
}
