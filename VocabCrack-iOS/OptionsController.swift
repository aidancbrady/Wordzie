//
//  OptionsController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/5/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class OptionsController: ResponsiveTextFieldViewController, UITextFieldDelegate
{
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var oldField: UITextField!
    @IBOutlet weak var newField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        confirmButton.addTarget(self, action: "onPasswordChange", forControlEvents: .TouchUpInside)
        
        oldField.delegate = self
        newField.delegate = self
        confirmField.delegate = self
    }
    
    @IBAction func onAvatarEdit(sender: AnyObject)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://en.gravatar.com")!)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == oldField
        {
            newField.becomeFirstResponder()
        }
        else if textField == newField
        {
            confirmField.becomeFirstResponder()
        }
        else if textField == confirmField
        {
            confirmField.resignFirstResponder()
            
            onPasswordChange()
        }
        
        return true
    }
    
    func onPasswordChange()
    {
        if !oldField.text.isEmpty && !newField.text.isEmpty && !confirmField.text.isEmpty
        {
            if oldField.text == Constants.CORE.account.password
            {
                if newField.text == confirmField.text
                {
                    if newField.text != Constants.CORE.account.password
                    {
                        if Utilities.isValidCredential(newField.text)
                        {
                            doPasswordChange(newField.text)
                        }
                        else {
                            Utilities.displayAlert(self, title: "Warning", msg: "Invalid characters.", action: nil)
                        }
                    }
                    else {
                        Utilities.displayAlert(self, title: "Warning", msg: "New password can't match existing.", action: nil)
                    }
                }
                else {
                    Utilities.displayAlert(self, title: "Warning", msg: "Passwords don't match.", action: nil)
                }
            }
            else {
                Utilities.displayAlert(self, title: "Warning", msg: "Unable to authenticate.", action: nil)
            }
        }
    }
    
    func doPasswordChange(password:String)
    {
        if Operations.passwordChanging
        {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.passwordChanging = true
            
            var (success, response) = Handlers.coreHandler.changePassword(password)
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.passwordChanging = false
                
                if success
                {
                    Utilities.displayAlert(self, title: "Success", msg: "Password successfully changed!", action: {(action) -> Void in
                        println(self.navigationController!.dismissViewControllerAnimated(true, completion: nil))
                    })
                }
                else {
                    var alertMsg:String = response != nil ? response! : "Unable to connect."
                    
                    Utilities.displayAlert(self, title: "Couldn't change password", msg: alertMsg, action: nil)
                }
            });
        });
    }
}
