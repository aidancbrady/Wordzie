//
//  EditTermController.swift
//  Wordzie
//
//  Created by aidancbrady on 12/15/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class EditTermController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var wordField: UITextField!
    @IBOutlet weak var definitionField: UITextView!
    
    var prevData:(String, String)?
    
    func textViewDidChange(textView:UITextView)
    {
        let maxNumberOfLines:CGFloat = 3
        let numLines = textView.contentSize.height/textView.font.lineHeight
        
        println("\(numLines) \(maxNumberOfLines)")
        
        if numLines > maxNumberOfLines
        {
            textView.text = textView.text.substringToIndex(textView.text.endIndex.predecessor())
        }
    }
    
    @IBAction func cancelButton(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButton(sender: AnyObject)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if prevData == nil
        {
            self.navigationItem.title = "New Term"
        }
        
        definitionField.delegate = self
    }
}
