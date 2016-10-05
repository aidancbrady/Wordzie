//
//  GameDetailController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/9/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class GameDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource, ListLoader
{
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var opponentAvatar: UIImageView!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreTable: UITableView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var wordListLabel: UILabel!
    
    var game:Game?
    
    func setGameData()
    {
        Utilities.loadAvatar(WeakWrapper(value: userAvatar), email: Constants.CORE.account.email!)
        Utilities.loadAvatar(WeakWrapper(value: opponentAvatar), email: game!.opponentEmail!)
        
        matchLabel.text = game!.user + " vs " + game!.opponent
        scoreLabel.text = "\(game!.getUserScore()) - \(game!.getOpponentScore())"
        gameTypeLabel.text = GameType.getType(game!.gameType).description
        wordListLabel.text = game!.getListName()
        
        scoreTable.reloadData()
        
        if !game!.hasWinner()
        {
            if !game!.userTurn
            {
                playButton.setTitle("Opponent's Turn", for: UIControlState())
                playButton.isEnabled = false
            }
            else {
                playButton.setTitle("Play", for: UIControlState())
                playButton.isEnabled = true
            }
        }
        else {
            playButton.setTitle("New Game", for: UIControlState())
            playButton.isEnabled = true
        }
    }
    
    func listLoaded(_ success: Bool)
    {
        playButton.isEnabled = false
        
        if success
        {
            let game:UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "GameNavigation") as! UINavigationController
            
            let controller = game.viewControllers[0] as UIViewController
            
            (controller as! GameController).game = self.game!
            
            self.present(game, animated: true, completion: nil)
        }
        else {
            Utilities.displayAlert(self, title: "Error", msg: "Couldn't load word list.", action: nil)
        }
    }
    
    @IBAction func gameButton(_ sender: AnyObject)
    {
        if game != nil
        {
            if !game!.hasWinner() && game!.userTurn
            {
                playButton.isEnabled = false
                WordListHandler.loadList(game!.getList(), controller: WeakWrapper(value: self))
            }
            else if game!.hasWinner()
            {
                let newGame:NewGameController = storyboard?.instantiateViewController(withIdentifier: "NewGameController") as! NewGameController
                
                newGame.definedUser = Utilities.getRemoteUser(game!)
                
                navigationController!.pushViewController(newGame, animated: true)
            }
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        scoreTable.delegate = self
        scoreTable.dataSource = self
        
        playButton.isEnabled = false
        playButton.setTitle("Loading...", for: UIControlState())
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if game == nil
        {
            return 0
        }
        
        return Utilities.max(game!.userPoints.count, num2: game!.opponentPoints.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
        
        let userStr = (indexPath as NSIndexPath).row <= game!.userPoints.count-1 ? String(game!.userPoints[(indexPath as NSIndexPath).row]) : "N/A"
        let opponentStr = (indexPath as NSIndexPath).row <= game!.opponentPoints.count-1 ? String(game!.opponentPoints[(indexPath as NSIndexPath).row]) : "N/A"
        
        cell.roundLabel.text = "Round \((indexPath as NSIndexPath).row+1)"
        cell.scoreLabel.text = userStr + " - " + opponentStr
        
        return cell
    }
}
