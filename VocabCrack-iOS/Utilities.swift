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
    
    class func buildGravatarURL(email:String, size:Int) -> NSURL
    {
        var str:NSMutableString = NSMutableString(format:"http://gravatar.com/avatar/%@?", buildMD5(email))
        str.appendString("&size=\(size)")
        
        return NSURL(string: str)!
    }
    
    class func buildMD5(email:String) -> String
    {
        let str = email.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(email.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        
        for i in 0..<digestLen
        {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        
        return String(format: hash)
    }
    
    class func trim(s:String) -> String
    {
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    class func loadData()
    {
        
    }
}