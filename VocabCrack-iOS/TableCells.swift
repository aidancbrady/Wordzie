//
//  FriendCell.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/6/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

var remoteDelete = true

class FriendCell: UITableViewCell
{
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    
    var controller:UITableViewController?
    var user:Account?

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if user != nil && selected
        {
            if controller is FriendsController
            {
                let friends = controller! as! FriendsController
                
                if friends.modeButton.selectedSegmentIndex == 1
                {
                    Utilities.displayYesNo(controller!, title: "Confirm", msg: "Accept request from " + user!.username + "?", action: {(action) -> Void in
                        Handlers.friendHandler.acceptRequest(WeakWrapper(value: friends), friend: self.user!.username)
                        
                        let path = self.controller!.tableView.indexPath(for: self)
                        remoteDelete = false
                        self.controller!.tableView(self.controller!.tableView, commit: .delete, forRowAt: path!)
                        remoteDelete = true
                        Handlers.friendHandler.updateData(WeakWrapper(value: friends))
                        
                        if friends.requests.count == 0
                        {
                            friends.modeButton.selectedSegmentIndex = 0
                            friends.tableView.reloadData()
                        }
                        
                        return
                    }, cancel: {(action) -> Void in
                        self.setSelected(false, animated: true)
                    })
                }
                else {
                    if !user!.isRequest
                    {
                        let detail:UserDetailController = controller!.storyboard?.instantiateViewController(withIdentifier: "UserDetailController") as! UserDetailController
                        
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
                let parent = (controller! as! SimpleFriendsController).newController!
                parent.setUser(user!.username)
                controller!.navigationController!.popViewController(animated: true)
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
    
    override func setSelected(_ selected: Bool, animated: Bool)
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
                            let path = self.controller!.tableView.indexPath(for: self)
                            remoteDelete = false
                            self.controller!.tableView(self.controller!.tableView, commit: .delete, forRowAt: path!)
                            remoteDelete = true
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
                    let detail:GameDetailController = controller!.storyboard?.instantiateViewController(withIdentifier: "GameDetailController") as! GameDetailController
                    
                    Handlers.gameHandler.getInfo(WeakWrapper(value: detail), friend: opponent)
                    
                    controller!.navigationController!.pushViewController(detail, animated: true)
                }
            }
            else {
                let detail:GameDetailController = controller!.storyboard?.instantiateViewController(withIdentifier: "GameDetailController") as! GameDetailController
                
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
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if controller != nil && selected
        {
            Utilities.displayYesNo(controller!, title: "Confirm", msg: ("Send friend request to " + usernameLabel.text! + "?"), action: {(action) -> Void in
                Handlers.friendHandler.sendRequest(WeakWrapper(value: self.controller!), friend: self.usernameLabel.text!)
                self.controller!.navigationController!.popViewController(animated: true)
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
    
    override func setSelected(_ selected: Bool, animated: Bool)
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
    var owned = false
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        if controller != nil && selected
        {
            controller!.navigationController!.popViewController(animated: true)
            controller!.newController!.setList(list!)
        }
    }
    
    @IBAction func onLongPress(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.began
        {
            if controller != nil && identifierLabel.text != "Default"
            {
                if !owned
                {
                    Utilities.displayAction(self.controller!, actions: ActionButton(button: "Copy URL", action: {action in
                        UIPasteboard.general.string = self.list!.1
                    }))
                }
                else {
                    Utilities.displayAction(self.controller!, actions: ActionButton(button: "Edit List", action: {action in
                        let createList:UINavigationController = self.controller!.storyboard?.instantiateViewController(withIdentifier: "CreateListNavigation") as! UINavigationController
                        (createList.viewControllers[0] as! CreateListController).editingList = self.list
                        
                        self.controller!.present(createList, animated: true, completion: nil)
                        return
                    }), ActionButton(button: "Copy URL", action: {action in
                        UIPasteboard.general.string = self.list!.1
                    }))
                }
            }
        }
    }
}

class TermCell:UITableViewCell
{
    @IBOutlet weak var wordLabel: UILabel!
}
