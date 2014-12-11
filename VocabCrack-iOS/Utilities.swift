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
    
    class func displayYesNo(controller:UIViewController, title:String, msg:String, action:((UIAlertAction!) -> Void)?, cancel:((UIAlertAction!) -> Void)?)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: action)
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler: cancel)
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func isValidCredential(creds: String...) -> Bool
    {
        for s in creds
        {
            for c in Constants.BAD_CHARS
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
        str.appendString("&default=404")
        
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
    
    class func replace(s:String, find:String, replace:String) -> String
    {
        return s.stringByReplacingOccurrencesOfString(find, withString: replace, options: nil, range: nil)
    }
    
    /// Trims and splits a String with a specified separator
    class func split(s:String, separator:String) -> [String]
    {
        if s.rangeOfString(separator) == nil
        {
            return [s]
        }
        
        var split = trim(s).componentsSeparatedByString(separator)
        
        for var i = 0; i < split.count; i++
        {
            if split[i] == ""
            {
                split.removeAtIndex(i)
            }
        }
        
        return split
    }
    
    class func readRemote(url:NSURL) -> String?
    {
        let task = NSURLSession.sharedSession().dataTaskWithURL(Constants.DATA_URL);
        
        return nil
    }
    
    class func getRemoteUser(g:Game) -> String
    {
        return g.getOtherUser(Constants.CORE.account.username);
    }
    
    class func readBool(s:String) -> Bool
    {
        return s == "true"
    }
    
    class func interpretLogin(millis:Int64) -> String
    {
        let date:NSDate = NSDate(timeIntervalSince1970: Double(millis/1000))
        let current:NSDate = NSDate()
        
        let diffMillis: Int64  = Int64((current.timeIntervalSince1970-date.timeIntervalSince1970)*1000)
        let diffSeconds: Int64  = diffMillis/1000
        let diffMinutes: Int64 = diffSeconds/60
        let diffHours: Int64  = diffMinutes/60
        let diffDays: Int64  = diffHours/24
        let diffMonths: Int64 = diffDays/30
        let diffYears: Int64 = diffMonths/12
        
        if diffSeconds < 60
        {
            return "seconds ago"
        }
        else if diffMinutes == 1
        {
            return "a minute ago"
        }
        else if diffMinutes < 60
        {
            return "\(diffMinutes) minutes ago"
        }
        else if diffHours == 1
        {
            return "an hour ago"
        }
        else if diffHours < 72
        {
            return "\(diffHours) hours ago"
        }
        else if diffDays < 31
        {
            return "\(diffDays) days ago"
        }
        else if diffMonths < 12
        {
            return "\(diffMonths) months ago"
        }
        else if diffYears == 1
        {
            return "a year ago"
        }
        else {
            return "\(diffYears) years ago"
        }
    }
    
    class func loadData()
    {
        println(WordListHandler.getDocumentsDir())
        let reader:HTTPReader = HTTPReader()
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: Constants.DATA_URL)
        
        reader.getHTTP(request)
        {
            (response:String?) -> Void in
            if let str = response
            {
                let array:[String] = str.componentsSeparatedByString("\n")
                
                Constants.IP = array[0]
                Constants.PORT = array[1].toInt()!
            
                println("Loaded data")
            }
            else {
                println("Failed to load data")
            }
            
            return
        }
    }
    
    class func loadAvatar(view:WeakWrapper<UIImageView>, email:String)
    {
        if Constants.CORE.avatars[email] != nil
        {
            view.value!.image = Constants.CORE.avatars[email]
            return
        }
        
        Operations.loadingAvatars.addObject(email)
        
        let url:NSURL = Utilities.buildGravatarURL(email, size: 512)
        var request: NSURLRequest = NSURLRequest(URL: url)
        
        var image:UIImage? = nil
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            image = UIImage(data: data)
            
            if view.value != nil
            {
                if image != nil
                {
                    view.value!.image = image
                    Constants.CORE.avatars[email] = image
                }
            }
            
            Operations.loadingAvatars.removeObject(email)
        })
    }
    
    class HTTPReader: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate
    {
        func getHTTP(request: NSMutableURLRequest!, action:(String?) -> Void)
        {
            var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            var session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
            
            var task = session.dataTaskWithRequest(request)
            {
                (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                if error == nil
                {
                    action(NSString(data: data, encoding:NSUTF8StringEncoding))
                }
                else {
                    action(nil)
                }
                
                return
            }
            
            task.resume()
        }
        
        func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)
        {
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void)
        {
            var newRequest: NSURLRequest? = request
            completionHandler(newRequest)
        }
    }
    
    class func max(num1:Int, num2:Int) -> Int
    {
        return num1 > num2 ? num1 : num2
    }
    
    class func min(num1:Int, num2:Int) -> Int
    {
        return num1 < num2 ? num1 : num2
    }
}

class TableDataReceiver: UITableViewController
{
    func receiveData(obj:AnyObject, type:Int) {}
    
    func endRefresh() {}
}

struct WeakWrapper<T: AnyObject>
{
    weak var value: T?
    
    init(value:T)
    {
        self.value = value
    }
}