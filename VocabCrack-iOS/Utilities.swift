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
    
    class func displayAction(controller:UIViewController, actions:ActionButton...)
    {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .ActionSheet)
        
        for action in actions
        {
            alertController.addAction(UIAlertAction(title: action.button, style: action.style, handler: action.action))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func displayDialog(controller:UIViewController, title:String, msg:String, actions:ActionButton...)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        
        for action in actions
        {
            alertController.addAction(UIAlertAction(title: action.button, style: action.style, handler: action.action))
        }
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func displayInput(controller:UIViewController, title:String, msg:String, placeholder:String?, handler:(String? -> Void)?)
    {
        var textField: UITextField?
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            handler?(textField!.text)
            return
        }))
        alertController.addTextFieldWithConfigurationHandler({(text: UITextField!) in
            text.placeholder = placeholder
            textField = text
        })
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func isValidCredential(creds: String...) -> Bool
    {
        for s in creds
        {
            for c in Constants.BAD_CHARS
            {
                if s.rangeOfString(c) != nil
                {
                    return false
                }
            }
        }
    
        return true
    }
    
    class func isValidMsg(msgs: String...) -> Bool
    {
        for s in msgs
        {
            for c in Constants.BANNED_CHARS
            {
                if s.rangeOfString(c) != nil
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Whether or not the two strings in their lowercase formats equal each other (trimmed)
    class func trimmedEqual(str1:String, str2:String) -> Bool
    {
        return Utilities.trim(str1.lowercaseString) == Utilities.trim(str2.lowercaseString)
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
            return [trim(s)]
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
        WordDataHandler.load()
        WordListHandler.loadListData()
        
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
    
    class func registerNotifications()
    {
        let application = UIApplication.sharedApplication()
        
        if application.respondsToSelector("isRegisteredForRemoteNotifications") // iOS 8
        {
            println("Registering for notifications...")
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge, categories: nil))
            application.registerForRemoteNotifications()
        }
        else { // iOS 7 or below
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound)
        }
    }
}

class TableDataReceiver: UITableViewController
{
    func receiveData(obj:AnyObject, type:Int) {}
    
    func endRefresh() {}
}

struct ActionButton
{
    var button:String!
    var action:((UIAlertAction!) -> Void)?
    var style:UIAlertActionStyle = .Default
    
    init(button:String)
    {
        self.button = button
    }
    
    init(button:String, action:((UIAlertAction!) -> Void))
    {
        self.button = button
        self.action = action
    }
    
    init(button:String, action:((UIAlertAction!) -> Void), style:UIAlertActionStyle)
    {
        self.button = button
        self.action = action
        self.style = style
    }
}

struct WeakWrapper<T: AnyObject>
{
    weak var value: T?
    
    init(value:T)
    {
        self.value = value
    }
}