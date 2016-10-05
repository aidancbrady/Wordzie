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
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    func setUser(_ user:String)
    {
        definedUser = user
        changeButton.setTitle("Change", for: UIControlState())
        playLabel.text = "Playing against " + definedUser! + "..."
        playButton.isEnabled = false
    }
    
    func setList(_ list:(String, String))
    {
        listChange.isEnabled = false
        loadingLabel.text = "Loading list..."
        
        if loadingLabel.isHidden
        {
            show(nil, views: loadingLabel)
        }
        
        activityIndicator.startAnimating()
        WordListHandler.loadList(list, controller: WeakWrapper(value: self))
    }
    
    func confirmGame(_ success:Bool, response:String?)
    {
        continueButton.isEnabled = true
        
        if success
        {
            let game:UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "GameNavigation") as! UINavigationController
            
            let controller = game.viewControllers[0] as UIViewController
            
            (controller as! GameController).game = createGame()
            (controller as! GameController).singleplayer = definedUser == nil
            
            self.present(game, animated: true, completion: nil)
        }
        else {
            Utilities.displayAlert(self, title: "Error", msg: response!, action: nil)
        }
    }
    
    func listLoaded(_ success:Bool)
    {
        if activityIndicator.isAnimating
        {
            activityIndicator.stopAnimating()
            listChange.isEnabled = true
            
            if !listLabel.isHidden
            {
                if success
                {
                    loadingLabel.text = "Loaded list! (\(Constants.CORE.activeList.count) terms)"
                    listLabel.text = "Using '\(Constants.CORE.listData!.0)' list..."
                    listChange.setTitle("Change", for: UIControlState())
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
    
    @IBAction func changePressed(_ sender: AnyObject)
    {
        if !playButton.isEnabled
        {
            UIView.transition(with: view, duration: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: {() in
                self.changeButton.setTitle("Choose", for: UIControlState())
                self.playLabel.text = "Choose a way to play..."
                self.playButton.isEnabled = true
                self.hidePastPlay()
            }, completion: {b in
                self.definedUser = nil
            })
        }
        else {
            let friends:SimpleFriendsController = self.storyboard?.instantiateViewController(withIdentifier: "SimpleFriendsController") as! SimpleFriendsController
            
            friends.newController = self
            
            navigationController?.pushViewController(friends, animated: true)
        }
    }
    
    @IBAction func listChangePressed(_ sender: AnyObject)
    {
        if Constants.CORE.listData == nil
        {
            let friends:WordListsController = self.storyboard?.instantiateViewController(withIdentifier: "WordListsController") as! WordListsController
            
            friends.newController = self
            
            navigationController?.pushViewController(friends, animated: true)
        }
        else {
            hidePastList()
        }
    }
    
    @IBAction func typePressed(_ sender: AnyObject)
    {
        if definedUser != nil
        {
            playLabel.text = "Playing against " + definedUser! + "..."
            playButton.isEnabled = false
            playButton.selectedSegmentIndex = 1
            changeButton.setTitle("Change", for: UIControlState())
        }
        else {
            changeButton.setTitle("Choose", for: UIControlState())
        }
        
        if playLabel.isHidden
        {
            show({
                if self.definedUser != nil
                {
                    self.show(nil, views: self.changeButton)
                    
                    if self.listLabel.isHidden
                    {
                        self.show(nil, views: self.listLabel, self.listChange)
                    }
                }
            }, views: playLabel, playButton)
        }
    }
    
    
    @IBAction func playPressed(_ sender: AnyObject)
    {
        changeButton.setTitle("Choose", for: UIControlState())
        
        if (playButton.selectedSegmentIndex == 0)
        {
            if listLabel.isHidden
            {
                show(nil, views: listLabel, listChange)
            }
        }
        else if playButton.selectedSegmentIndex == 1
        {
            hidePastPlay()
        }
        
        if self.playButton.selectedSegmentIndex != 1 && !self.changeButton.isHidden
        {
            hide(nil, views: changeButton)
        }
        else if self.playButton.selectedSegmentIndex == 1 && self.changeButton.isHidden
        {
            show(nil, views: changeButton)
        }
    }
    
    @IBAction func continuePressed(_ sender: AnyObject)
    {
        if playButton.selectedSegmentIndex == 0
        {
            confirmGame(true, response: nil)
        }
        else if playButton.selectedSegmentIndex == 1 && definedUser != nil
        {
            continueButton.isEnabled = false
            Handlers.gameHandler.confirmGame(WeakWrapper(value: self), friend: definedUser!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if firstDisplay
        {
            show(nil, views: typeLabel, typeButton)
            
            firstDisplay = false
        }
        else {
            if !playButton.isHidden && !playButton.isEnabled
            {
                if listLabel.isHidden
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
        Constants.CORE.activeList.removeAll(keepingCapacity: false)
        
        listChange.setTitle("Choose", for: UIControlState())
        listLabel.text = ("Choose a word list...")
        
        if !loadingLabel.isHidden
        {
            hide(nil, views: loadingLabel)
        }
        
        if activityIndicator.isAnimating
        {
            activityIndicator.stopAnimating()
        }
        
        if !loadingLabel.isHidden
        {
            hide(nil, views: loadingLabel)
        }
        
        if !confirmImage.isHidden
        {
            hide(nil, views: confirmImage)
        }
        
        if !continueButton.isHidden
        {
            hide(nil, views: continueButton)
        }
    }
    
    func hidePastPlay()
    {
        if !listLabel.isHidden
        {
            hide(nil, views: listLabel)
        }
        
        if !listChange.isHidden
        {
            hide(nil, views: listChange)
        }
        
        hidePastList()
    }
    
    func hide(_ completion: (() -> Void)?, views: UIView...)
    {
        UIView.transition(with: view, duration: 0.4, options: UIViewAnimationOptions.curveEaseOut, animations: {() in
            for view in views
            {
                view.alpha = 0
            }
        }, completion: {b in
            for view in views
            {
                view.isHidden = true
            }
            
            completion?()
        })
    }
    
    func show(_ completion: (() -> Void)?, views: UIView...)
    {
        for view in views
        {
            view.isHidden = false
            view.alpha = 0.1
        }
        
        UIView.transition(with: view, duration: 0.4, options: UIViewAnimationOptions.curveEaseOut, animations: {() in
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
