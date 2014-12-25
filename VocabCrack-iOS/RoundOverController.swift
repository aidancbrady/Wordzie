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
    
    @IBAction func continuePressed(sender: AnyObject)
    {
        let game:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GameController") as UIViewController
        
        (game as GameController).game = self.game
        (game as GameController).singleplayer = singleplayer
        
        navigationController!.pushViewController(game, animated: true)
    }
    
    @IBAction func returnPressed(sender: AnyObject)
    {
        if singleplayer
        {
            Utilities.displayYesNo(self, title: "Confirm", msg: "Are you sure you want to exit this game? Your progress will be lost.", action: {action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }, cancel: nil)
        }
        else {
            //Send data to server
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        roundLabel.text = "Round \(game.userPoints.count)"
        
        returnButton.hidden = false
        roundLabel.hidden = false
        
        let userIndex = game.userPoints.count
        let opponentIndex = game.opponentPoints.count
        
        if singleplayer
        {
            continueButton.hidden = false
            
            let roundsRemaining = GameType.getType(game.gameType).getWinningScore()-game.userPoints.count
            
            primaryLabel.text = "Your score: \(game.userPoints[userIndex-1])/10"
            secondaryLabel.text = "\(roundsRemaining) round" + (roundsRemaining == 1 ? "s" : "") + " remaining"
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
            standingsLabel.hidden = false
        }
        
        primaryLabel.hidden = false
        secondaryLabel.hidden = false
    }
}
