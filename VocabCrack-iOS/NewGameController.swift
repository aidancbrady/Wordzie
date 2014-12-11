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
    @IBOutlet weak var changeButton: UIButton!
    
    var definedUser:String?
    
    @IBAction func changePressed(sender: AnyObject)
    {
        if !playButton.enabled
        {
            UIView.transitionWithView(view, duration: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                self.changeButton.alpha = 0
                self.playButton.enabled = true
            }, completion: {b in
                self.changeButton.hidden = true
                self.definedUser = nil
            })
        }
        else {
            let friends:SimpleFriendsController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleFriendsController") as SimpleFriendsController
            
            navigationController?.pushViewController(friends, animated: true)
        }
    }
    
    @IBAction func typePressed(sender: AnyObject)
    {
        if definedUser != nil
        {
            playLabel.text = "Playing against " + definedUser! + "..."
            playButton.enabled = false
            playButton.selectedSegmentIndex = 2
            changeButton.setTitle("Change", forState: UIControlState.Normal)
        }
        else {
            changeButton.setTitle("Choose", forState: UIControlState.Normal)
        }
        
        if playLabel.hidden
        {
            playLabel.hidden = false
            playButton.hidden = false
            playLabel.alpha = 0.1
            playButton.alpha = 0.1
            UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                self.playLabel.alpha = 1
                self.playButton.alpha = 1
            }, completion: {b in
                if self.definedUser != nil
                {
                    self.changeButton.hidden = false
                    self.changeButton.alpha = 0.1
                    UIView.transitionWithView(self.view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                        self.changeButton.alpha = 1
                    }, completion: nil)
                }
                
                self.playPressed(sender)
            })
        }
    }
    
    
    @IBAction func playPressed(sender: AnyObject)
    {
        changeButton.setTitle("Choose", forState: UIControlState.Normal)
        
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
        
        if self.playButton.selectedSegmentIndex != 2 && !self.changeButton.hidden
        {
            UIView.transitionWithView(self.view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                self.changeButton.alpha = 0
            }, completion: {b in
                self.changeButton.hidden = true
            })
        }
        else if self.playButton.selectedSegmentIndex == 2 && self.changeButton.hidden
        {
            self.changeButton.hidden = false
            self.changeButton.alpha = 0.1
            UIView.transitionWithView(self.view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                self.changeButton.alpha = 1
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
