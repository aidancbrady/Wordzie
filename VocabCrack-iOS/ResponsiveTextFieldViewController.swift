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
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    
    weak var activeText: UIView?

    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(self, selector: #selector(ResponsiveTextFieldViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ResponsiveTextFieldViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        keyboardIsShowing = true
        
        if let info = (notification as NSNotification).userInfo
        {
            keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            if activeText != nil
            {
                arrangeViewOffsetFromKeyboard()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification)
    {
        keyboardIsShowing = false
        
        returnViewToInitialFrame()
    }
    
    func arrangeViewOffsetFromKeyboard()
    {
        let theApp: UIApplication = UIApplication.shared
        let windowView: UIView? = theApp.delegate!.window!
        
        let textFieldLowerPoint: CGPoint = CGPoint(x: activeText!.frame.origin.x, y: activeText!.frame.origin.y + activeText!.frame.size.height)
        
        let convertedTextFieldLowerPoint: CGPoint = view.convert(textFieldLowerPoint, to: windowView)
        
        let targetTextFieldLowerPoint: CGPoint = CGPoint(x: activeText!.frame.origin.x, y: keyboardFrame.origin.y - kPreferredTextFieldToKeyboardOffset)
        
        let targetPointOffset: CGFloat = targetTextFieldLowerPoint.y - convertedTextFieldLowerPoint.y
        let adjustedViewFrameCenter: CGPoint = CGPoint(x: view.center.x, y: view.center.y + targetPointOffset)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.center = adjustedViewFrameCenter
        })
    }
    
    func returnViewToInitialFrame()
    {
        let initialViewRect: CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        if !initialViewRect.equalTo(self.view.frame)
        {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame = initialViewRect
            });
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if activeText != nil
        {
            activeText?.resignFirstResponder()
            activeText = nil
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        activeText = textField
        
        if keyboardIsShowing
        {
            arrangeViewOffsetFromKeyboard()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.resignFirstResponder()
        activeText = nil
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        activeText = textView
        
        if keyboardIsShowing
        {
            arrangeViewOffsetFromKeyboard()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        textView.resignFirstResponder()
        activeText = nil
    }
}
