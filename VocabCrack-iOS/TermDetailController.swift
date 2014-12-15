//
//  TermDetailController.swift
//  Wordzie
//
//  Created by aidancbrady on 12/15/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class TermDetailController: UIViewController
{
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    
    var term:(String, String)?
    var index:Int?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if term != nil
        {
            updateTerm()
        }
    }
    
    func updateTerm()
    {
        wordLabel.text = term!.0
        definitionLabel.text = term!.1
        
        (getParent() as CreateListController).terms[index!] = term!
        (getParent() as CreateListController).tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    func getParent() -> UIViewController
    {
        return navigationController!.viewControllers[navigationController!.viewControllers.count-2] as UIViewController
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.destinationViewController is UINavigationController
        {
            let controller: AnyObject = (segue.destinationViewController as UINavigationController).viewControllers[0]
            (controller as EditTermController).term = term
        }
    }
}
