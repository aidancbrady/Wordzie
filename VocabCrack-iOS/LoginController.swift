//
//  LoginController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    @IBOutlet weak var connectingSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var help: UIButton!
    @IBOutlet weak var refresh: UIButton!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var avatarView: UIImageView!
    
    var dataCache: (String, String, String)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Utilities.loadData(self)
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        Utilities.roundButtons(view)
        
        show(nil, views: connectingLabel)
        
        connectingSpinner.startAnimating()
    }
    
    func dataReceived()
    {
        if Constants.CORE.dataState != nil
        {
            connectingSpinner.stopAnimating()
            
            if Constants.CORE.dataState!
            {
                hide(nil, views: connectingLabel)
                show(nil, views: logo, help, refresh)
                
                if getCachedData()
                {
                    loginLabel.text = "Login as " + dataCache!.0
                    avatarView.image = UIImage(named: "user.png")
                    
                    show(nil, views: loginLabel, cancelButton, avatarView)
                    show(nil, views: loginButton)
                    
                    Utilities.loadAvatar(WeakWrapper(value: avatarView), email: dataCache!.1)
                }
                else {
                    show(nil, views: usernameField, passwordField)
                    show(nil, views: loginButton, registerButton)
                }
            }
            else {
                connectingLabel.text = "Unable to connect."
                show(nil, views: retryButton)
            }
        }
    }
    
    func getCachedData() -> Bool
    {
        let defaults = UserDefaults.standard
        
        if let user = defaults.object(forKey: "username") as? String
        {
            if let email = defaults.object(forKey: "email") as? String
            {
                if let pass = defaults.object(forKey: "password") as? String
                {
                    dataCache = (user, email, pass)
                    
                    return true
                }
            }
        }
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == usernameField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            passwordField.resignFirstResponder()
            
            onLogin()
        }
        
        return true
    }

    @IBAction func onLogin(_ sender: AnyObject)
    {
        onLogin()
    }
    
    @IBAction func helpButton(_ sender: AnyObject)
    {
        UIApplication.shared.open(URL(string: "http://aidancbrady.com/wordzie/")!)
    }
    
    @IBAction func onRetry(_ sender: AnyObject)
    {
        hide({self.dataReceived()}, views: retryButton)
        
        connectingSpinner.startAnimating()
        connectingLabel.text = "Connecting..."
        
        Utilities.loadData(self)
    }
    
    @IBAction func onRefresh(_ sender: AnyObject)
    {
        if !Operations.loggingIn
        {
            hide({self.dataReceived()}, views: logo, refresh, help)
            
            if dataCache != nil
            {
                hide({self.dataReceived()}, views: loginLabel, cancelButton, avatarView)
                hide({self.dataReceived()}, views: loginButton)
            }
            else {
                hide({self.dataReceived()}, views: usernameField, passwordField)
                hide({self.dataReceived()}, views: loginButton, registerButton)
            }
            
            show(nil, views: connectingLabel)
            connectingSpinner.startAnimating()
            
            Utilities.loadData(self)
        }
    }
    
    @IBAction func onCancel(_ sender: AnyObject)
    {
        dataCache = nil
        
        hide(nil, views: loginLabel, cancelButton, avatarView)
        show(nil, views: usernameField, passwordField)
        show(nil, views: registerButton)
        
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "password")
    }
    
    func onLogin()
    {
        if dataCache != nil || (!usernameField.text!.isEmpty && !passwordField.text!.isEmpty)
        {
            if dataCache != nil || Utilities.isValidCredential(usernameField.text!, passwordField.text!)
            {
                if dataCache != nil
                {
                    doLogin(dataCache!.0, password: dataCache!.2)
                }
                else {
                    doLogin(usernameField.text!, password:passwordField.text!)
                }
            }
            else {
                Utilities.displayAlert(self, title: "Warning", msg: "Invalid characters.", action: nil)
            }
        }
    }
    
    func doLogin(_ username:String, password:String)
    {
        if Operations.loggingIn
        {
            return
        }
        
        dataCache = nil
        loginSpinner.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            Operations.loggingIn = true
            
            let (success, response) = Handlers.coreHandler.login(username, password:password)
            
            DispatchQueue.main.async {
                Operations.loggingIn = false
                self.loginSpinner.stopAnimating()
                
                if success
                {
                    let menu:UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "MenuNavigation") as! UINavigationController
                    
                    self.present(menu, animated: true, completion: nil)
                    
                    Utilities.registerNotifications()
                }
                else {
                    let alertMsg:String = response != nil ? response! : "Unable to connect."
                    
                    Utilities.displayAlert(self, title: "Couldn't login", msg: alertMsg, action: nil)
                }
            }
        }
    }
    
    func hide(_ completion: (() -> Void)?, views: UIView...)
    {
        UIView.transition(with: view, duration: 0.4, options: UIViewAnimationOptions.curveEaseOut, animations: {() in
            for view in views
            {
                view.alpha = 0
            }
        }, completion: {b in
            for view in views
            {
                view.isHidden = true
            }
            
            completion?()
        })
    }
    
    func show(_ completion: (() -> Void)?, views: UIView...)
    {
        for view in views
        {
            view.isHidden = false
            view.alpha = 0.1
        }
        
        UIView.transition(with: view, duration: 0.4, options: UIViewAnimationOptions.curveEaseOut, animations: {() in
            for view in views
            {
                view.alpha = 1
            }
        }, completion: {b in
            completion?()
            return
        })
    }
}
