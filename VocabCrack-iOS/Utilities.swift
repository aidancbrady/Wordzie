//
//  Utilities.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit
import UserNotifications

class Utilities
{
    class func displayAlert(_ controller:UIViewController, title:String, msg:String, action:((UIAlertAction?) -> Void)?)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: action)
        
        alertController.addAction(okAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func displayYesNo(_ controller:UIViewController, title:String, msg:String, action:((UIAlertAction?) -> Void)?, cancel:((UIAlertAction?) -> Void)?)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: action)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: cancel)
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func displayAction(_ controller:UIViewController, actions:ActionButton...)
    {
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        
        for action in actions
        {
            alertController.addAction(UIAlertAction(title: action.button, style: action.style, handler: action.action))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func displayDialog(_ controller:UIViewController, title:String, msg:String, actions:ActionButton...)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        for action in actions
        {
            alertController.addAction(UIAlertAction(title: action.button, style: action.style, handler: action.action))
        }
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func displayInput(_ controller:UIViewController, title:String, msg:String, placeholder:String?, handler:((String?) -> Void)?)
    {
        var textField: UITextField?
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            handler?(textField!.text)
            return
        }))
        alertController.addTextField(configurationHandler: {(text: UITextField!) in
            text.placeholder = placeholder
            textField = text
        })
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func isValidCredential(_ creds: String...) -> Bool
    {
        for s in creds
        {
            for c in Constants.BAD_CHARS
            {
                if s.range(of: c) != nil
                {
                    return false
                }
            }
        }
    
        return true
    }
    
    class func isValidMsg(_ msgs: String...) -> Bool
    {
        for s in msgs
        {
            for c in Constants.BANNED_CHARS
            {
                if s.range(of: c) != nil
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Whether or not the two strings in their lowercase formats equal each other (trimmed)
    class func trimmedEqual(_ str1:String, str2:String) -> Bool
    {
        return Utilities.trim(str1.lowercased()) == Utilities.trim(str2.lowercased())
    }
    
    class func buildGravatarURL(_ email:String, size:Int) -> URL
    {
        let str:NSMutableString = NSMutableString(format:"http://gravatar.com/avatar/%@?", buildMD5(email))
        str.append("&size=\(size)")
        str.append("&default=404")
        
        return URL(string: str as String)!
    }
    
    class func buildMD5(_ email:String) -> String
    {
        let str = email.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(email.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        
        for i in 0..<digestLen
        {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deinitialize(count: digestLen)
        
        return String(format: hash as String)
    }
    
    class func trim(_ s:String) -> String
    {
        return s.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    class func replace(_ s:String, find:String, replace:String) -> String
    {
        return s.replacingOccurrences(of: find, with: replace, options: [], range: nil)
    }
    
    /// Trims and splits a String with a specified separator
    class func split(_ s:String, separator:String) -> [String]
    {
        if s.range(of: separator) == nil
        {
            return [trim(s)]
        }
        
        var split = trim(s).components(separatedBy: separator)
        
        for i in 0 ..< split.count
        {
            if split[i] == ""
            {
                split.remove(at: i)
            }
        }
        
        return split
    }
    
    class func readRemote(_ url:URL) -> String?
    {
        URLSession.shared.dataTask(with: Constants.DATA_URL);
        
        return nil
    }
    
    class func getRemoteUser(_ g:Game) -> String
    {
        return g.getOtherUser(Constants.CORE.account.username);
    }
    
    class func readBool(_ s:String) -> Bool
    {
        return s == "true"
    }
    
    class func interpretLogin(_ millis:Int64) -> String
    {
        let date:Date = Date(timeIntervalSince1970: Double(millis/1000))
        let current:Date = Date()
        
        let diffMillis: Int64  = Int64((current.timeIntervalSince1970-date.timeIntervalSince1970)*1000)
        let diffSeconds: Int64  = diffMillis/1000
        let diffMinutes: Int64 = diffSeconds/60
        let diffHours: Int64  = diffMinutes/60
        let diffDays: Int64  = diffHours/24
        let diffMonths: Int64 = diffDays/30
        let diffYears: Int64 = diffMonths/12
        
        if diffSeconds < 60 {
            return "seconds ago"
        } else if diffMinutes == 1 {
            return "a minute ago"
        } else if diffMinutes < 60 {
            return "\(diffMinutes) minutes ago"
        } else if diffHours == 1 {
            return "an hour ago"
        } else if diffHours < 72 {
            return "\(diffHours) hours ago"
        } else if diffDays < 31 {
            return "\(diffDays) days ago"
        } else if diffMonths < 12 {
            return "\(diffMonths) months ago"
        } else if diffYears == 1 {
            return "a year ago"
        } else {
            return "\(diffYears) years ago"
        }
    }
    
    class func loadData(_ controller:LoginController)
    {
        WordDataHandler.load()
        WordListHandler.loadListData()
        
        Constants.CORE.dataState = nil
        
        let reader:HTTPReader = HTTPReader()
        let request:URLRequest = URLRequest(url: Constants.DATA_URL as URL)
        
        reader.getHTTP(request)
        {
            (response:String?) -> Void in
            if let str = response
            {
                let array:[String] = str.components(separatedBy: "\n")
                
                Constants.SERVER_ADDRESS = array[0]
                Constants.SERVER_PORT = Int(array[1])!
            
                print("Loaded data")
                Constants.CORE.dataState = true
            }
            else {
                print("Failed to load data")
                Constants.CORE.dataState = false
            }
            
            controller.dataReceived()
            
            return
        }
    }
    
    class func loadAvatar(_ view:WeakWrapper<UIImageView>, email:String)
    {
        if Constants.CORE.avatars[email] != nil
        {
            view.value!.image = Constants.CORE.avatars[email]
            return
        }
        
        Operations.loadingAvatars.add(email)
        
        let url:URL = Utilities.buildGravatarURL(email, size: 512)
        let request: URLRequest = URLRequest(url: url)
        
        view.value!.image = UIImage(named: "user.png")
        var image:UIImage? = nil
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            image = UIImage(data: data!)
            
            if image != nil
            {
                if view.value != nil
                {
                    view.value!.image = image
                }
                
                Constants.CORE.avatars[email] = image
            }
            else {
                Constants.CORE.avatars[email] = UIImage(named: "user.png")
            }
            
            Operations.loadingAvatars.remove(email)
        })
        
        task.resume()
    }
    
    class HTTPReader: NSObject, URLSessionDelegate, URLSessionTaskDelegate
    {
        func getHTTP(_ request: URLRequest!, action:@escaping (String?) -> Void)
        {
            let configuration = URLSessionConfiguration.default
            let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue:OperationQueue.main)
            
            let task = session.dataTask(with: request, completionHandler: {
                (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if error == nil
                {
                    action(NSString(data: data!, encoding:String.Encoding.utf8.rawValue) as String?)
                }
                else {
                    action(nil)
                }
                
                return
            })            

            
            task.resume()
        }
        
        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
        {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void)
        {
            let newRequest: URLRequest? = request
            completionHandler(newRequest)
        }
    }
    
    class func max(_ num1:Int, num2:Int) -> Int
    {
        return num1 > num2 ? num1 : num2
    }
    
    class func min(_ num1:Int, num2:Int) -> Int
    {
        return num1 < num2 ? num1 : num2
    }
    
    class func registerNotifications()
    {
        let application = UIApplication.shared
        
        print("Registering for notifications...")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge], completionHandler: { (granted, error) in
        })
        application.registerForRemoteNotifications()
    }
    
    class func roundButtons(_ view:UIView)
    {
        for subview in view.subviews
        {
            if subview is UIButton
            {
                let button = subview as! UIButton
                button.layer.cornerRadius = 5
            }
        }
    }
}

class TableDataReceiver: UITableViewController
{
    func receiveData(_ obj:Any, type:Int) {}
    
    func endRefresh() {}
}

struct ActionButton
{
    var button:String!
    var action:((UIAlertAction) -> Void)?
    var style:UIAlertAction.Style = .default
    
    init(button:String)
    {
        self.button = button
    }
    
    init(button:String, action:@escaping ((UIAlertAction?) -> Void))
    {
        self.button = button
        self.action = action
    }
    
    init(button:String, action:@escaping ((UIAlertAction?) -> Void), style:UIAlertAction.Style)
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
