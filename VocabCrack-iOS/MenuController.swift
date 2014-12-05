//
//  MenuController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class MenuController: UIViewController
{
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        userLabel.text = "Welcome, " + Constants.CORE.account.username + "!"
        loadAvatar(Constants.CORE.account.email!)
    }
    
    @IBAction func logoutButton(sender: AnyObject)
    {
        Constants.CORE.account = Defaults.ACCOUNT
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadAvatar(email:String)
    {
        Operations.needsAvatar = self
        
        let url:NSURL = Utilities.buildGravatarURL(email, size: 512)
        var request: NSURLRequest = NSURLRequest(URL: url)
        
        var image:UIImage? = nil
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            image = UIImage(data: data)
            
            if Operations.needsAvatar === self
            {
                Operations.needsAvatar = nil
                
                if image != nil
                {
                    self.userAvatar.image = image
                }
            }
        })
    }
}
