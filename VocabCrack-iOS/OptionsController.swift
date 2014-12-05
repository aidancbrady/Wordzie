//
//  OptionsController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/5/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class OptionsController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func backButton(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
