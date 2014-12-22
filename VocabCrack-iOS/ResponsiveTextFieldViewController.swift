//
//  ResponsiveTextFieldViewController.swift
//  Swift version of: VBResponsiveTextFieldViewController
//  Original code: https://github.com/ttippin84/VBResponsiveTextFieldViewController
//
//  Created by David Sandor on 9/27/14.
//  Copyright (c) 2014 David Sandor. All rights reserved.
//

import Foundation
import UIKit

class ResponsiveTextFieldViewController : UIViewController, UITextFieldDelegate, UITextViewDelegate
{
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 20.0
    var keyboardFrame: CGRect = CGRect.nullRect
    var keyboardIsShowing: Bool = false
    
    weak var activeText: UIView?

    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        keyboardIsShowing = true
        
        if let info = notification.userInfo
        {
            keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            if activeText != nil
            {
                arrangeViewOffsetFromKeyboard()
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        keyboardIsShowing = false
        
        returnViewToInitialFrame()
    }
    
    func arrangeViewOffsetFromKeyboard()
    {
        var theApp: UIApplication = UIApplication.sharedApplication()
        var windowView: UIView? = theApp.delegate!.window!
        
        var textFieldLowerPoint: CGPoint = CGPointMake(activeText!.frame.origin.x, activeText!.frame.origin.y + activeText!.frame.size.height)
        
        var convertedTextFieldLowerPoint: CGPoint = view.convertPoint(textFieldLowerPoint, toView: windowView)
        
        var targetTextFieldLowerPoint: CGPoint = CGPointMake(activeText!.frame.origin.x, keyboardFrame.origin.y - kPreferredTextFieldToKeyboardOffset)
        
        var targetPointOffset: CGFloat = targetTextFieldLowerPoint.y - convertedTextFieldLowerPoint.y
        var adjustedViewFrameCenter: CGPoint = CGPointMake(view.center.x, view.center.y + targetPointOffset)
        
        UIView.animateWithDuration(0.2, animations: {
            self.view.center = adjustedViewFrameCenter
        })
    }
    
    func returnViewToInitialFrame()
    {
        var initialViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        
        if !CGRectEqualToRect(initialViewRect, self.view.frame)
        {
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame = initialViewRect
            });
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        if activeText != nil
        {
            activeText?.resignFirstResponder()
            activeText = nil
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeText = textField
        
        if keyboardIsShowing
        {
            arrangeViewOffsetFromKeyboard()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        textField.resignFirstResponder()
        activeText = nil
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        println("BEGAN")
        activeText = textView
        
        if keyboardIsShowing
        {
            arrangeViewOffsetFromKeyboard()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        textView.resignFirstResponder()
        activeText = nil
    }
}