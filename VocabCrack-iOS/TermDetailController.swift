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
        
        navigationController!.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        navigationController!.setToolbarHidden(true, animated: true)
    }
    
    func updateTerm()
    {
        wordLabel.text = term!.0
        definitionLabel.text = term!.1
        
        (getParent() as! CreateListController).terms[index!] = term!
        (getParent() as! CreateListController).tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func getParent() -> UIViewController
    {
        return navigationController!.viewControllers[navigationController!.viewControllers.count-2] as UIViewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is UINavigationController
        {
            let controller: AnyObject = (segue.destination as! UINavigationController).viewControllers[0]
            (controller as! EditTermController).term = term
        }
    }
}
