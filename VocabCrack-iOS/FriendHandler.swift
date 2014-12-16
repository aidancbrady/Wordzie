//
//  FriendHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class FriendHandler
{
    func updateData(controller:WeakWrapper<TableDataReceiver>)
    {
        updateFriends(controller)
        updateRequests(controller)
    }
    
    func updateFriends(controller:WeakWrapper<TableDataReceiver>)
    {
        if Operations.loadingGames
        {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.loadingGames = true
            
            let str = compileMsg("LFRIENDS", Constants.CORE.account.username)
            let ret = NetHandler.sendData(str, retLines:2)
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.loadingGames = false
                
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response[0], separator: Constants.SPLITTER_1)
                        let array1:[String] = Utilities.split(response[1], separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            var accounts:[Account] = [Account]()
                            
                            for var i = 1; i < array.count; i++
                            {
                                var split:[String] = array[i].componentsSeparatedByString(Constants.SPLITTER_2)
                                accounts.append(Account(username:split[0], isRequest:false).setEmail(split[1]).setLastLogin(NSString(string: split[2]).longLongValue))
                            }
                            
                            for var i = 1; i < array1.count; i++
                            {
                                accounts.append(Account(username:array1[i], isRequest:true))
                            }
                            
                            table.receiveData(accounts, type: 0)
                            table.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                        }
                    }
                    
                    if !Operations.loadingPast
                    {
                        table.endRefresh()
                    }
                }
            })
        })
    }
    
    func updateRequests(controller:WeakWrapper<TableDataReceiver>)
    {
        if Operations.loadingPast
        {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.loadingPast = true
            
            let str = compileMsg("LREQUESTS", Constants.CORE.account.username)
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.loadingPast = false
                
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            var accounts:[Account] = [Account]()
                            
                            for var i = 1; i < array.count; i++
                            {
                                var split:[String] = array[i].componentsSeparatedByString(Constants.SPLITTER_2)
                                accounts.append(Account(username:split[0], isRequest:false).setEmail(split[1]))
                            }
                            
                            table.receiveData(accounts, type: 1)
                            table.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                            
                            if table is FriendsController
                            {
                                if accounts.count > 0
                                {
                                    (table as FriendsController).modeButton.setTitle("Requests (\(accounts.count))", forSegmentAtIndex: 1)
                                }
                                else {
                                    (table as FriendsController).modeButton.setTitle("Requests", forSegmentAtIndex: 1)
                                }
                            }
                        }
                    }
                    
                    if !Operations.loadingGames
                    {
                        table.endRefresh()
                    }
                }
            })
        })
    }
    
    func deleteFriend(friend:String, type:Int)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("DELFRIEND", Constants.CORE.account.username, friend, String(type))
            NetHandler.sendData(str)
        })
    }
    
    func updateSearch(controller:WeakWrapper<AddFriendController>, query:String)
    {
        if !Utilities.isValidCredential(query)
        {
            return
        }
        
        controller.value!.activity.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("LUSERS", Constants.CORE.account.username, Utilities.trim(query))
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let table = controller.value
                {
                    table.activity.stopAnimating()
                    
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            table.users.removeAll(keepCapacity: false)
                            
                            if array.count > 1
                            {
                                table.users = Utilities.split(array[1], separator: Constants.SPLITTER_2)
                            }
                            
                            table.tableView.reloadData()
                        }
                    }
                }
            })
        })
    }
    
    func sendRequest(controller:WeakWrapper<AddFriendController>, friend:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("FRIENDREQ", Constants.CORE.account.username, friend)
            NetHandler.sendData(str)
        })
    }
    
    func acceptRequest(controller:WeakWrapper<FriendsController>, friend:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("REQCONF", Constants.CORE.account.username, friend)
            NetHandler.sendData(str)
        })
    }
    
    func getInfo(controller:WeakWrapper<UserDetailController>, friend:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("GETINFO", Constants.CORE.account.username, friend)
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let detail = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            let won = array[2].toInt()!
                            let lost = array[3].toInt()!
                            let login = NSString(string: array[4]).longLongValue
                            
                            detail.acct = Account(username: friend, email: array[1], password: "password").setGamesWon(won).setGamesLost(lost).setLastLogin(login)
                        }
                    }
                }
            })
        })
    }
}