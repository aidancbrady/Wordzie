//
//  GameDetailController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/9/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class GameDetailController: UIViewController
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
    }
    
    @IBAction func gameButton(sender: AnyObject)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setGameData()
    }
}
