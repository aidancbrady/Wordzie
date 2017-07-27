//
//  OptionsController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/5/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class OptionsController: ResponsiveTextFieldViewController
{
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var oldField: UITextField!
    @IBOutlet weak var newField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        confirmButton.addTarget(self, action: #selector(OptionsController.onPasswordChange), for: .touchUpInside)
        
        oldField.delegate = self
        newField.delegate = self
        confirmField.delegate = self
    }
    
    @IBAction func onAvatarEdit(_ sender: AnyObject)
    {
        UIApplication.shared.open(URL(string: "http://en.gravatar.com")!)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
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
    
    @objc func onPasswordChange()
    {
        if !oldField.text!.isEmpty && !newField.text!.isEmpty && !confirmField.text!.isEmpty
        {
            if oldField.text == Constants.CORE.account.password
            {
                if newField.text == confirmField.text
                {
                    if newField.text != Constants.CORE.account.password
                    {
                        if Utilities.isValidCredential(newField.text!)
                        {
                            doPasswordChange(newField.text!)
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
    
    func doPasswordChange(_ password:String)
    {
        if Operations.passwordChanging
        {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            Operations.passwordChanging = true
            
            let (success, response) = Handlers.coreHandler.changePassword(password)
            
            DispatchQueue.main.async {
                Operations.passwordChanging = false
                
                if success
                {
                    Utilities.displayAlert(self, title: "Success", msg: "Password successfully changed!", action: {(action) -> Void in
                        print(self.navigationController!.dismiss(animated: true, completion: nil))
                    })
                }
                else {
                    let alertMsg:String = response != nil ? response! : "Unable to connect."
                    
                    Utilities.displayAlert(self, title: "Couldn't change password", msg: alertMsg, action: nil)
                }
            }
        }
    }
}
