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
    
    var controller:UITableViewController?
    var user:Account?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if user != nil && selected
        {
            if controller is FriendsController
            {
                if (controller! as FriendsController).modeButton.selectedSegmentIndex == 1
                {
                    Utilities.displayYesNo(controller!, title: "Confirm", msg: "Accept request from " + user!.username + "?", action: {(action) -> Void in
                        Handlers.friendHandler.acceptRequest(WeakWrapper(value: self.controller! as FriendsController), friend: self.user!.username)
                        
                        var path = self.controller!.tableView.indexPathForCell(self)
                        self.controller!.tableView(self.controller!.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: path!)
                        Handlers.friendHandler.updateData(WeakWrapper(value: self.controller! as FriendsController))
                        (self.controller! as FriendsController).modeButton.selectedSegmentIndex = 0
                        (self.controller! as FriendsController).tableView.reloadData()
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
            else if controller is SimpleFriendsController
            {
                var parent = (controller! as SimpleFriendsController).newController!
                parent.setDefinedUser(user!.username)
                controller!.navigationController!.popViewControllerAnimated(true)
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
            let opponent:String = Utilities.getRemoteUser(game!)
            
            if controller!.modeButton.selectedSegmentIndex == 0
            {
                if game!.isRequest
                {
                    if !game!.activeRequested
                    {
                        Utilities.displayYesNo(controller!, title: "Confirm", msg: "Accept request from " + opponent + "?", action: {(action) -> Void in
                            Handlers.gameHandler.acceptRequest(WeakWrapper(value: self.controller!), friend: opponent, handler: {() in Handlers.gameHandler.updateData(WeakWrapper(value: self.controller!))})
                            var path = self.controller!.tableView.indexPathForCell(self)
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
                let detail:GameDetailController = controller!.storyboard?.instantiateViewControllerWithIdentifier("GameDetailController") as GameDetailController
                
                detail.game = game
                
                controller!.navigationController!.pushViewController(detail, animated: true)
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
    @IBOutlet weak var roundLabel: UILabel!
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

class ListCell:UITableViewCell
{
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    var list:(String, String)?
    var controller:WordListsController?
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if controller != nil && selected
        {
            controller!.navigationController!.popViewControllerAnimated(true)
            controller!.newController!.setList(list!)
        }
    }
}

class TermCell:UITableViewCell
{
    @IBOutlet weak var wordLabel: UILabel!
}
