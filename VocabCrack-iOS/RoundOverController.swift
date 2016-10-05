//
//  RoundOverController.swift
//  Wordzie
//
//  Created by aidancbrady on 12/25/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class RoundOverController: UIViewController
{
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var standingsLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    
    var game:Game!
    var singleplayer = false
    
    @IBAction func continuePressed(_ sender: AnyObject)
    {
        let game:UIViewController = self.storyboard?.instantiateViewController(withIdentifier: "GameController") as UIViewController!
        
        (game as! GameController).game = self.game
        (game as! GameController).singleplayer = singleplayer
        
        navigationController!.pushViewController(game, animated: true)
    }
    
    @IBAction func returnPressed(_ sender: AnyObject)
    {
        if singleplayer
        {
            if game.userPoints.count < GameType.getType(game.gameType).getWinningScore()
            {
                Utilities.displayYesNo(self, title: "Confirm", msg: "Are you sure you want to exit this game? Your progress will be lost.", action: {action in
                    self.dismiss(animated: true, completion: nil)
                }, cancel: nil)
            }
            else {
                dismiss()
            }
        }
        else {
            dismiss()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        roundLabel.text = "Round \(game.userPoints.count)"
        
        returnButton.isHidden = false
        roundLabel.isHidden = false
        
        let userIndex = game.userPoints.count
        
        if singleplayer
        {
            if game.userPoints.count < GameType.getType(game.gameType).getWinningScore()
            {
                continueButton.isHidden = false
            }
            
            let roundsRemaining = GameType.getType(game.gameType).getWinningScore()-game.userPoints.count
            
            primaryLabel.text = "Your score: \(game.userPoints[userIndex-1])/10"
            secondaryLabel.text = "\(roundsRemaining) round" + (roundsRemaining == 1 ? "" : "s") + " remaining"
        }
        else {
            if userIndex == game.opponentPoints.count
            {
                if game.userPoints[userIndex-1] == game.opponentPoints[game.opponentPoints.count-1]
                {
                    primaryLabel.text = "Tie Round!"
                }
                else {
                    if game.userPoints[userIndex-1] > game.opponentPoints[game.opponentPoints.count-1]
                    {
                        primaryLabel.text = "You won the round!"
                    }
                    else {
                        primaryLabel.text = "You lost the round!"
                    }
                }
                
                secondaryLabel.text = "Round score: \(game.userPoints[userIndex-1])-\(game.opponentPoints[game.opponentPoints.count-1])"
            }
            else {
                primaryLabel.text = "Awaiting opponent..."
                secondaryLabel.text = "Your score: \(game.userPoints[userIndex-1])/10"
            }
            
            standingsLabel.text = "Standings: \(game.getUserScore())-\(game.getOpponentScore())"
            standingsLabel.isHidden = false
        }
        
        primaryLabel.isHidden = false
        secondaryLabel.isHidden = false
        
        if !singleplayer
        {
            returnButton.isEnabled = false
            returnButton.setTitle("Uploading...", for: UIControlState())
            
            activityIndicator.startAnimating()
            
            if game.isRequest
            {
                Handlers.gameHandler.newGame(WeakWrapper(value: self))
            }
            else {
                Handlers.gameHandler.compGame(WeakWrapper(value: self))
            }
        }
    }
    
    override var prefersStatusBarHidden : Bool
    {
        return true
    }
    
    func dismiss()
    {
        let superNav = navigationController!.presentingViewController as! UINavigationController
        var newControllers = superNav.viewControllers
        let count = newControllers.count
        
        for i in stride(from: (count-1), through: 0, by: -1)
        {
            let controller = newControllers[i] as UIViewController
            
            if controller is GamesController
            {
                if game.hasWinner()
                {
                    let detail:GameDetailController = storyboard!.instantiateViewController(withIdentifier: "GameDetailController") as! GameDetailController
                    detail.game = game
                    
                    newControllers.append(detail)
                }
                
                break
            }
            else if controller is MenuController
            {
                let games:GamesController = storyboard!.instantiateViewController(withIdentifier: "GamesController") as! GamesController
                newControllers.append(games)
                
                break
            }
            else {
                newControllers.remove(at: i)
            }
        }
        
        superNav.setViewControllers(newControllers, animated: false)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func confirmResponse(_ success:Bool)
    {
        activityIndicator.stopAnimating()
        
        if success
        {
            returnButton.isEnabled = true
            returnButton.setTitle("Return", for: UIControlState())
        }
        else {
            Utilities.displayDialog(self, title: "Error", msg: "Couldn't send game data to server.", actions: ActionButton(button: "Try Again", action: {action in
                self.activityIndicator.startAnimating()
                
                if self.game.isRequest
                {
                    Handlers.gameHandler.newGame(WeakWrapper(value: self))
                }
                else {
                    Handlers.gameHandler.compGame(WeakWrapper(value: self))
                }
            }), ActionButton(button: "Exit", action: {action in
                self.dismiss()
            }))
        }
    }
}
