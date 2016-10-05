//
//  NewListController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/13/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class NewListController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var identifierEntry: UITextField!
    @IBOutlet weak var urlEntry: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBAction func referenceButton(_ sender: AnyObject)
    {
        onCreate()
    }
    
    @IBAction func createButton(_ sender: AnyObject)
    {
        activityIndicator.startAnimating()
        Handlers.listHandler.confirmList(WeakWrapper(value: self), identifier: nil)
    }
    
    @IBAction func cancelButton(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == identifierEntry
        {
            urlEntry.becomeFirstResponder()
        }
        else if textField == urlEntry
        {
            urlEntry.resignFirstResponder()
        }
        
        return true
    }
    
    func onCreate()
    {
        if !identifierEntry.text!.isEmpty && !urlEntry.text!.isEmpty
        {
            if identifierEntry.text == "Default" || urlEntry.text == "DefaultURL"
            {
                Utilities.displayAlert(self, title: "Error", msg: "Can't redefine default word list.", action: nil)
                return
            }
            else if Constants.CORE.listURLs[identifierEntry.text!] != nil
            {
                Utilities.displayAlert(self, title: "Error", msg: "Word list already exists!", action: nil)
                return
            }
            
            WordListHandler.addList(Utilities.trim(identifierEntry.text!), url: Utilities.trim(urlEntry.text!))
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.navigationController!.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        identifierEntry.delegate = self
        urlEntry.delegate = self
    }
}
