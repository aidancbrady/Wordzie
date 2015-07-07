//
//  NewGameController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/10/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class NewGameController: UIViewController, ListLoader
{
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeButton: UISegmentedControl!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var playButton: UISegmentedControl!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var confirmImage: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var listChange: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var definedUser:String?
    var firstDisplay = true
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func setUser(user:String)
    {
        definedUser = user
        changeButton.setTitle("Change", forState: UIControlState.Normal)
        playLabel.text = "Playing against " + definedUser! + "..."
        playButton.enabled = false
    }
    
    func setList(list:(String, String))
    {
        listChange.enabled = false
        loadingLabel.text = "Loading list..."
        
        if loadingLabel.hidden
        {
            show(nil, views: loadingLabel)
        }
        
        activityIndicator.startAnimating()
        WordListHandler.loadList(list, controller: WeakWrapper(value: self))
    }
    
    func confirmGame(success:Bool, response:String?)
    {
        continueButton.enabled = true
        
        if success
        {
            let game:UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("GameNavigation") as! UINavigationController
            
            let controller = game.viewControllers[0] as UIViewController
            
            (controller as! GameController).game = createGame()
            (controller as! GameController).singleplayer = definedUser == nil
            
            self.presentViewController(game, animated: true, completion: nil)
        }
        else {
            Utilities.displayAlert(self, title: "Error", msg: response!, action: nil)
        }
    }
    
    func listLoaded(success:Bool)
    {
        if activityIndicator.isAnimating()
        {
            activityIndicator.stopAnimating()
            listChange.enabled = true
            
            if !listLabel.hidden
            {
                if success
                {
                    loadingLabel.text = "Loaded list! (\(Constants.CORE.activeList.count) terms)"
                    listLabel.text = "Using '\(Constants.CORE.listData!.0)' list..."
                    listChange.setTitle("Change", forState: UIControlState.Normal)
                    show(nil, views: confirmImage, continueButton)
                }
                else {
                    loadingLabel.text = "Failed to load list."
                }
                    
                show(nil, views: loadingLabel)
            }
        }
    }
    
    func createGame() -> Game
    {
        let game:Game = Game(user: Constants.CORE.account.username, opponent: definedUser != nil ? definedUser! : "Guest", activeRequested: true)
        game.gameType = typeButton.selectedSegmentIndex
        game.setList(Constants.CORE.listData!.0, listUrl: Constants.CORE.listData!.1)
        
        return game
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
            let friends:SimpleFriendsController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleFriendsController") as! SimpleFriendsController
            
            friends.newController = self
            
            navigationController?.pushViewController(friends, animated: true)
        }
    }
    
    @IBAction func listChangePressed(sender: AnyObject)
    {
        if Constants.CORE.listData == nil
        {
            let friends:WordListsController = self.storyboard?.instantiateViewControllerWithIdentifier("WordListsController") as! WordListsController
            
            friends.newController = self
            
            navigationController?.pushViewController(friends, animated: true)
        }
        else {
            hidePastList()
        }
    }
    
    @IBAction func typePressed(sender: AnyObject)
    {
        if definedUser != nil
        {
            playLabel.text = "Playing against " + definedUser! + "..."
            playButton.enabled = false
            playButton.selectedSegmentIndex = 1
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
        
        if (playButton.selectedSegmentIndex == 0)
        {
            if listLabel.hidden
            {
                show(nil, views: listLabel, listChange)
            }
        }
        else if playButton.selectedSegmentIndex == 1
        {
            hidePastPlay()
        }
        
        if self.playButton.selectedSegmentIndex != 1 && !self.changeButton.hidden
        {
            hide(nil, views: changeButton)
        }
        else if self.playButton.selectedSegmentIndex == 1 && self.changeButton.hidden
        {
            show(nil, views: changeButton)
        }
    }
    
    @IBAction func continuePressed(sender: AnyObject)
    {
        if playButton.selectedSegmentIndex == 0
        {
            confirmGame(true, response: nil)
        }
        else if playButton.selectedSegmentIndex == 1 && definedUser != nil
        {
            continueButton.enabled = false
            Handlers.gameHandler.confirmGame(WeakWrapper(value: self), friend: definedUser!)
        }
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
        Constants.CORE.listData = nil
        Constants.CORE.activeList.removeAll(keepCapacity: false)
        
        listChange.setTitle("Choose", forState: UIControlState.Normal)
        listLabel.text = ("Choose a word list...")
        
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
        
        if !confirmImage.hidden
        {
            hide(nil, views: confirmImage)
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
}
