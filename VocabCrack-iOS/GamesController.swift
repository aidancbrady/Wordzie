//
//  GamesController.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/6/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class GamesController: UITableViewController
{
    var activeGames:[Game] = [Game]()
    var pastGames:[Game] = [Game]()
    
    var refresher:UIRefreshControl!
    
    @IBOutlet weak var modeButton: UISegmentedControl!
    
    @IBAction func modeChanged(sender: AnyObject)
    {
        tableView.reloadData()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl = refresher
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        Handlers.gameHandler.updateData(WeakWrapper(value: self))
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    func onRefresh()
    {
        Handlers.gameHandler.updateData(WeakWrapper(value: self))
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return modeButton.selectedSegmentIndex == 0 ? activeGames.count : pastGames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath) as! GameCell
        
        var game = modeButton.selectedSegmentIndex == 0 ? activeGames[indexPath.row] : pastGames[indexPath.row]
        
        if modeButton.selectedSegmentIndex == 0
        {
            if game.isRequest
            {
                if game.user == Constants.CORE.account.username
                {
                    cell.usernameLabel.text = "Request to \(Utilities.getRemoteUser(game))"
                }
                else {
                    cell.usernameLabel.text = "Request from \(Utilities.getRemoteUser(game))"
                }
                
                cell.turnLabel.text = "Awaiting approval"
                cell.scoreLabel.text = "Tied 0-0"
            }
            else {
                cell.usernameLabel.text = "Game with \(Utilities.getRemoteUser(game))"
                cell.scoreLabel.text = "\(game.getUserScore()) to \(game.getOpponentScore())"
                cell.turnLabel.text = game.userTurn ? "Your turn!" : "Opponent's turn"
            }
        }
        else {
            cell.usernameLabel.text = "Game with \(Utilities.getRemoteUser(game))"
            var scoreText = game.isTied() ? "Tied " : (game.getWinning() == game.user ? "Won " : "Lost ")
            scoreText += "\(game.getUserScore()) to \(game.getOpponentScore())"
            cell.scoreLabel.text = scoreText
            cell.turnLabel.hidden = true
        }
        
        Utilities.loadAvatar(WeakWrapper(value: cell.userAvatar), email: game.opponentEmail!)
        
        cell.game = game
        cell.controller = self
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if !Operations.loadingGames && !Operations.loadingPast
        {
            var type = 0
            let username = Utilities.getRemoteUser(modeButton.selectedSegmentIndex == 0 ? activeGames[indexPath.row] : pastGames[indexPath.row])
            
            if modeButton.selectedSegmentIndex == 0
            {
                if activeGames[indexPath.row].isRequest
                {
                    type = activeGames[indexPath.row].activeRequested ? 2 : 3
                }
                else {
                    type = 0
                }
                
                activeGames.removeAtIndex(indexPath.row)
            }
            else {
                type = 1
                pastGames.removeAtIndex(indexPath.row)
            }
            
            if remoteDelete
            {
                if type == 1
                {
                    Handlers.gameHandler.deleteGame(WeakWrapper(value: self), friend: username, type: type, index: indexPath.row)
                }
                else {
                    Handlers.gameHandler.deleteGame(WeakWrapper(value: self), friend: username, type: type)
                }
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}