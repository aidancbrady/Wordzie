//
//  GameDetailController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/9/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class GameDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var opponentAvatar: UIImageView!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreTable: UITableView!
    
    var game:Game?
    
    func setGameData()
    {
        Utilities.loadAvatar(WeakWrapper(value: userAvatar), email: Constants.CORE.account.email!)
        Utilities.loadAvatar(WeakWrapper(value: opponentAvatar), email: game!.opponentEmail!)
        
        matchLabel.text = game!.user + " vs " + game!.opponent
        scoreLabel.text = "\(game!.getUserScore()) - \(game!.getOpponentScore())"
        
        scoreTable.reloadData()
    }
    
    @IBAction func gameButton(sender: AnyObject)
    {
        
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
