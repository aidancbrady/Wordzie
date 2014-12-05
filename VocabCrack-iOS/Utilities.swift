//
//  Utilities.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class Utilities
{
    class func displayAlert(controller:UIViewController, title:String, msg:String, action:((UIAlertAction!) -> Void)?)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: action)
        
        alertController.addAction(okAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func isValidCredential(creds: String...) -> Bool
    {
        for s:String in creds
        {
            for c:Character in Constants.BAD_CHARS
            {
                if contains(s, c)
                {
                    return false
                }
            }
        }
    
        return true
    }
    
    class func trim(s:String) -> String
    {
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    class func loadData()
    {
        
    }
}