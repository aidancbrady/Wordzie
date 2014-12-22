//
//  EditTermController.swift
//  Wordzie
//
//  Created by aidancbrady on 12/15/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class EditTermController: ResponsiveTextFieldViewController, UITextViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var wordField: UITextField!
    @IBOutlet weak var definitionField: UITextView!
    
    var term:(String, String)?
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        let currentText = textView.text as NSString
        let proposedText = currentText.stringByReplacingCharactersInRange(range, withString: text)
        
        if countElements(proposedText) > 120
        {
            return false
        }
        else if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let currentText = textField.text as NSString
        let proposedText = currentText.stringByReplacingCharactersInRange(range, withString: string)
        
        if countElements(proposedText) > 24
        {
            return false
        }
        
        return true
    }
    
    @IBAction func cancelButton(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButton(sender: AnyObject)
    {
        if wordField.hasText() && definitionField.hasText()
        {
            if Utilities.isValidMsg(wordField.text, definitionField.text)
            {
                if existsCheck(wordField.text)
                {
                    if boundsCheck()
                    {
                        let newTerm = (Utilities.trim(wordField.text), Utilities.trim(definitionField.text))
                        
                        if term != nil
                        {
                            (getParent() as TermDetailController).term = newTerm
                            (getParent() as TermDetailController).updateTerm()
                            dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            (getParent() as CreateListController).terms.append(newTerm)
                            (getParent() as CreateListController).tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                            dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                    else {
                        Utilities.displayAlert(self, title: "Error", msg: "You've reached the max of 50 terms for your custom word list.", action: nil)
                    }
                }
                else {
                    Utilities.displayAlert(self, title: "Error", msg: "Word already exists!", action: nil)
                }
            }
            else {
                Utilities.displayAlert(self, title: "Error", msg: "Invalid characters.", action: nil)
            }
        }
    }
    
    func boundsCheck() -> Bool
    {
        let list = term != nil ? (getEditParent() as CreateListController) : (getParent() as CreateListController)
        
        if term == nil && list.terms.count >= 50
        {
            return false
        }
        
        return true
    }
    
    func getParent() -> UIViewController
    {
        let parentNav = navigationController!.presentingViewController! as UINavigationController
        
        return parentNav.viewControllers[parentNav.viewControllers.count-1] as UIViewController
    }
    
    func getEditParent() -> UIViewController
    {
        let detailController = getParent() as TermDetailController
        return detailController.getParent()
    }
    
    func existsCheck(word:String) -> Bool
    {
        let list = term != nil ? (getEditParent() as CreateListController) : (getParent() as CreateListController)
        
        for pair in list.terms
        {
            if term == nil && Utilities.trimmedEqual(word, str2: pair.0)
            {
                return false
            }
            else if term != nil && !Utilities.trimmedEqual(word, str2: term!.0) && Utilities.trimmedEqual(word, str2: pair.0)
            {
                return false
            }
        }
        
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if term == nil
        {
            self.navigationItem.title = "New Term"
        }
        else {
            wordField.text = term!.0
            definitionField.text = term!.1
        }
        
        wordField.delegate = self
        definitionField.delegate = self
    }
}
