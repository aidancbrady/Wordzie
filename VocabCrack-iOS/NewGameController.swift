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
    @IBOutlet weak var finishedLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var listChange: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var definedUser:String?
    var firstDisplay = true
    
    func setDefinedUser(user:String)
    {
        definedUser = user
        changeButton.setTitle("Change", forState: UIControlState.Normal)
        playLabel.text = "Playing against " + definedUser! + "..."
        playButton.enabled = false
    }
    
    func setList(list:String)
    {
        listChange.enabled = false
        loadingLabel.text = "Loading list..."
        activityIndicator.startAnimating()
        WordListHandler.loadList(list, controller: WeakWrapper(value: self))
    }
    
    func listLoaded(success:Bool)
    {
        Constants.CORE.listURLs["Default"] = "DefaultURL"
        
        if activityIndicator.isAnimating()
        {
            activityIndicator.stopAnimating()
            listChange.enabled = true
            
            if !listLabel.hidden
            {
                if success
                {
                    loadingLabel.text = "Loaded list! (\(Constants.CORE.activeList.count) terms)"
                    listLabel.text = "Using '\(Constants.CORE.listID!)' list..."
                    listChange.setTitle("Change", forState: UIControlState.Normal)
                    finishedLabel.text = "You're all set!"
                    show(nil, views: finishedLabel, continueButton)
                }
                else {
                    loadingLabel.text = "Failed to load list."
                }
                    
                show(nil, views: loadingLabel)
            }
        }
    }
    
    @IBAction func changePressed(sender: AnyObject)
    {
        if !playButton.enabled
        {
            UIView.transitionWithView(view, duration: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
                self.changeButton.setTitle("Choose", forState: UIControlState.Normal)
                self.playLabel.text = "Choose a way to play..."
                self.playButton.enabled = true
                self.hidePastPlay()
            }, completion: {b in
                self.definedUser = nil
            })
        }
        else {
            let friends:SimpleFriendsController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleFriendsController") as SimpleFriendsController
            
            friends.newController = self
            
            navigationController?.pushViewController(friends, animated: true)
        }
    }
    
    @IBAction func listChangePressed(sender: AnyObject)
    {
        if Constants.CORE.listID == nil
        {
            let friends:WordListsController = self.storyboard?.instantiateViewControllerWithIdentifier("WordListsController") as WordListsController
            
            friends.newController = self
            
            navigationController?.pushViewController(friends, animated: true)
        }
        else {
            Constants.CORE.listID = nil
            Constants.CORE.activeList.removeAll(keepCapacity: false)
            
            listChange.setTitle("Choose", forState: UIControlState.Normal)
            listLabel.text = ("Choose a word list...")
            
            hidePastList()
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
            show({
                if self.definedUser != nil
                {
                    self.show(nil, views: self.changeButton)
                    
                    if self.listLabel.hidden
                    {
                        self.show(nil, views: self.listLabel, self.listChange)
                    }
                }
            }, views: playLabel, playButton)
        }
    }
    
    
    @IBAction func playPressed(sender: AnyObject)
    {
        changeButton.setTitle("Choose", forState: UIControlState.Normal)
        
        if (playButton.selectedSegmentIndex == 0 || playButton.selectedSegmentIndex == 1)
        {
            if listLabel.hidden
            {
                show(nil, views: listLabel, listChange)
            }
        }
        else if playButton.selectedSegmentIndex == 2
        {
            hidePastPlay()
        }
        
        if self.playButton.selectedSegmentIndex != 2 && !self.changeButton.hidden
        {
            hide(nil, views: changeButton)
        }
        else if self.playButton.selectedSegmentIndex == 2 && self.changeButton.hidden
        {
            show(nil, views: changeButton)
        }
    }
    
    @IBAction func continuePressed(sender: AnyObject)
    {
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if firstDisplay
        {
            show(nil, views: typeLabel, typeButton)
            
            firstDisplay = false
        }
        else {
            if !playButton.hidden && !playButton.enabled
            {
                if listLabel.hidden
                {
                    show(nil, views: listLabel, listChange)
                }
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func hidePastList()
    {
        if !loadingLabel.hidden
        {
            hide(nil, views: loadingLabel)
        }
        
        if activityIndicator.isAnimating()
        {
            activityIndicator.stopAnimating()
        }
        
        if !loadingLabel.hidden
        {
            hide(nil, views: loadingLabel)
        }
        
        if !finishedLabel.hidden
        {
            hide(nil, views: finishedLabel)
        }
        
        if !continueButton.hidden
        {
            hide(nil, views: continueButton)
        }
    }
    
    func hidePastPlay()
    {
        if !listLabel.hidden
        {
            hide(nil, views: listLabel)
        }
        
        if !listChange.hidden
        {
            hide(nil, views: listChange)
        }
        
        hidePastList()
    }
    
    func hide(completion: (() -> Void)?, views: UIView...)
    {
        UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
            for view in views
            {
                view.alpha = 0
            }
        }, completion: {b in
            for view in views
            {
                view.hidden = true
            }
            
            completion?()
        })
    }
    
    func show(completion: (() -> Void)?, views: UIView...)
    {
        for view in views
        {
            view.hidden = false
            view.alpha = 0.1
        }
        
        UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
            for view in views
            {
                view.alpha = 1
            }
        }, completion: {b in
            completion?()
            return
        })
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
