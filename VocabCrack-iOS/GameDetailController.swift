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
    
    var game:Game?
    
    func setGameData()
    {
        Utilities.loadAvatar(WeakWrapper(value: userAvatar), email: Constants.CORE.account.email!)
        Utilities.loadAvatar(WeakWrapper(value: opponentAvatar), email: game!.opponentEmail!)
        
        matchLabel.text = game!.user + " vs " + game!.opponent
        scoreLabel.text = "\(game!.getUserScore()) - \(game!.getOpponentScore())"
        
        scoreTable.reloadData()
        
        if !game!.userTurn
        {
            playButton.enabled = false
            playButton.setTitle("Opponent's Turn", forState: UIControlState.Normal)
        }
    }
    
    func listLoaded(success: Bool)
    {
        playButton.enabled = false
        
        if success
        {
            let game:UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("GameNavigation") as UINavigationController
            
            let controller = game.viewControllers[0] as UIViewController
            
            (controller as GameController).game = self.game!
            
            self.presentViewController(game, animated: true, completion: nil)
        }
        else {
            Utilities.displayAlert(self, title: "Error", msg: "Couldn't load word list.", action: nil)
        }
    }
    
    @IBAction func gameButton(sender: AnyObject)
    {
        if game != nil && game!.userTurn
        {
            playButton.enabled = false
            WordListHandler.loadList(game!.getList(), controller: WeakWrapper(value: self))
        }
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        scoreTable.delegate = self
        scoreTable.dataSource = self

        setGameData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Utilities.max(game!.userPoints.count, num2: game!.opponentPoints.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScoreCell", forIndexPath: indexPath) as ScoreCell
        
        var userStr = indexPath.row <= game!.userPoints.count-1 ? String(game!.userPoints[indexPath.row]) : "N/A"
        var opponentStr = indexPath.row <= game!.opponentPoints.count-1 ? String(game!.opponentPoints[indexPath.row]) : "N/A"
        
        cell.roundLabel.text = "Round \(indexPath.row+1)"
        cell.scoreLabel.text = userStr + " - " + opponentStr
        
        return cell
    }
}
