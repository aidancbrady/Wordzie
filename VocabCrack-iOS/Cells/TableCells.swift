//
//  FriendCell.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/6/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell
{
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    
    var controller:FriendsController?
    var user:Account?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if controller != nil && user != nil && selected
        {
            if controller!.modeButton.selectedSegmentIndex == 1
            {
                Utilities.displayYesNo(controller!, title: "Confirm", msg: "Accept request from " + user!.username + "?", action: {(action) -> Void in
                    Handlers.friendHandler.acceptRequest(WeakWrapper(value: self.controller!), friend: self.user!.username)
                    
                    var path = self.controller!.tableView.indexPathForCell(self)
                    self.controller!.tableView(self.controller!.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: path!)
                    Handlers.friendHandler.updateData(WeakWrapper(value: self.controller!))
                    return
                }, cancel: {(action) -> Void in
                    self.setSelected(false, animated: true)
                })
            }
            else {
                if !user!.isRequest
                {
                    let detail:UserDetailController = controller!.storyboard?.instantiateViewControllerWithIdentifier("UserDetailController") as UserDetailController
                    
                    detail.acct = user
                    
                    controller!.navigationController!.pushViewController(detail, animated: true)
                }
                else {
                    self.setSelected(false, animated: true)
                }
            }
        }
    }
}

class GameCell: UITableViewCell
{
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    
    var controller:GamesController?
    var game:Game?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if controller != nil && game != nil && selected
        {
            let opponent:String = game!.getOtherUser(Constants.CORE.account.username)
            
            if controller!.modeButton.selectedSegmentIndex == 0
            {
                if game!.isRequest
                {
                    if !game!.activeRequested
                    {
                        Utilities.displayYesNo(controller!, title: "Confirm", msg: "Accept request from " + opponent + "?", action: {(action) -> Void in
                            Handlers.gameHandler.acceptRequest(WeakWrapper(value: self.controller!), friend: opponent)
                            var path = self.controller!.tableView.indexPathForCell(self)
                            self.controller!.tableView(self.controller!.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: path!)
                            Handlers.gameHandler.updateData(WeakWrapper(value: self.controller!))
                            return
                        }, cancel: {(action) -> Void in
                            self.setSelected(false, animated: true)
                        })
                    }
                    else {
                        self.setSelected(false, animated: true)
                    }
                }
                else {
                    let detail:GameDetailController = controller!.storyboard?.instantiateViewControllerWithIdentifier("GameDetailController") as GameDetailController
                    
                    detail.game = game
                    
                    controller!.navigationController!.pushViewController(detail, animated: true)
                }
            }
            else {
                Utilities.displayYesNo(controller!, title: "New Game", msg: "Start new game with " + opponent + "?", action: {(action) -> Void in
                    Handlers.gameHandler.acceptRequest(WeakWrapper(value: self.controller!), friend: opponent)
                    var path = self.controller!.tableView.indexPathForCell(self)
                    self.controller!.tableView(self.controller!.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: path!)
                    Handlers.gameHandler.updateData(WeakWrapper(value: self.controller!))
                    
                    //Open new game controller
                    return
                }, cancel: {(action) -> Void in
                    self.setSelected(false, animated: true)
                })
            }
        }
    }
}

class UserCell:UITableViewCell
{
    @IBOutlet weak var usernameLabel: UILabel!
    
    var controller:AddFriendController?

    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if controller != nil && selected
        {
            Utilities.displayYesNo(controller!, title: "Confirm", msg: ("Send friend request to " + usernameLabel.text! + "?"), action: {(action) -> Void in
                Handlers.friendHandler.sendRequest(WeakWrapper(value: self.controller!), friend: self.usernameLabel.text!)
                self.controller!.navigationController!.popViewControllerAnimated(true)
            }, cancel: {(action) -> Void in
                self.setSelected(false, animated: true)
            })
        }
    }
}

class ScoreCell:UITableViewCell
{
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if selected
        {
            self.setSelected(false, animated: true)
        }
    }
}
