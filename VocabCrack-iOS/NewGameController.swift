//
//  NewGameController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/10/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class NewGameController: UIViewController
{
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeButton: UISegmentedControl!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var playButton: UISegmentedControl!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var listButton: UISegmentedControl!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var finishedLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func typePressed(sender: AnyObject)
    {
        if playLabel.hidden
        {
            playLabel.hidden = false
            playButton.hidden = false
            playLabel.alpha = 0.1
            playButton.alpha = 0.1
            UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                self.playLabel.alpha = 1
                self.playButton.alpha = 1
            }, completion: nil)
        }
    }
    
    
    @IBAction func playPressed(sender: AnyObject)
    {
        if listLabel.hidden
        {
            listLabel.hidden = false
            listButton.hidden = false
            listLabel.alpha = 0.1
            listButton.alpha = 0.1
            UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                self.listLabel.alpha = 1
                self.listButton.alpha = 1
            }, completion: nil)
        }
    }
    
    
    @IBAction func listPressed(sender: AnyObject)
    {
        if listButton.selectedSegmentIndex == 0
        {
            if !urlField.hidden
            {
                UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                    self.urlField.alpha = 0
                }, completion: {b in
                    self.urlField.hidden = true
                    self.urlField.text = ""
                })
            }
            
            if finishedLabel.hidden
            {
                finishedLabel.hidden = false
                finishedLabel.alpha = 0.1
                UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                    self.finishedLabel.alpha = 1
                }, completion: nil)
            }
        }
        else {
            if urlField.hidden
            {
                urlField.hidden = false
                urlField.alpha = 0.1
                UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                    self.urlField.alpha = 1
                }, completion: nil)
            }
            
            if !finishedLabel.hidden
            {
                UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                    self.finishedLabel.alpha = 0
                }, completion: {b in
                    self.finishedLabel.hidden = true
                })
            }
        }
    }
    
    @IBAction func continuePressed(sender: AnyObject)
    {
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        typeLabel.hidden = false
        typeButton.hidden = false
        typeLabel.alpha = 0.1
        typeButton.alpha = 0.1
        UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
            self.typeLabel.alpha = 1
            self.typeButton.alpha = 1
        }, completion: nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
