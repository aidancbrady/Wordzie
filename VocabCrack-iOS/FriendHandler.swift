//
//  FriendHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class FriendHandler
{
    func updateData(controller:WeakWrapper<FriendsController>)
    {
        updateFriends(controller)
        updateRequests(controller)
    }
    
    func updateFriends(controller:WeakWrapper<FriendsController>)
    {
        if Operations.loadingGames
        {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.loadingGames = true
            
            let str = "LFRIENDS:" + Constants.CORE.account.username
            let ret = NetHandler.sendData(str, retLines:2)
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.loadingGames = false
                
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response[0], separator: ":")
                        let array1:[String] = Utilities.split(response[1], separator: ":")
                        
                        if array[0] == "ACCEPT"
                        {
                            var accounts:[Account] = [Account]()
                            
                            for var i = 1; i < array.count; i++
                            {
                                var split:[String] = array[i].componentsSeparatedByString(",")
                                accounts.append(Account(username:split[0], isRequest:false).setEmail(split[1]))
                            }
                            
                            for var i = 1; i < array1.count; i++
                            {
                                accounts.append(Account(username:array1[i], isRequest:true))
                            }
                            
                            table.friends = accounts
                            table.tableView.reloadData()
                        }
                    }
                    
                    if !Operations.loadingPast && table.refresher.refreshing
                    {
                        table.refresher.endRefreshing()
                    }
                }
            })
        })
    }
    
    func updateRequests(controller:WeakWrapper<FriendsController>)
    {
        if Operations.loadingPast
        {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.loadingPast = true
            
            let str = "LREQUESTS:" + Constants.CORE.account.username
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                Operations.loadingPast = false
                
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: ":")
                        
                        if array[0] == "ACCEPT"
                        {
                            var accounts:[Account] = [Account]()
                            
                            for var i = 1; i < array.count; i++
                            {
                                var split:[String] = array[i].componentsSeparatedByString(",")
                                accounts.append(Account(username:split[0], isRequest:false).setEmail(split[1]))
                            }
                            
                            table.requests = accounts
                            table.tableView.reloadData()
                            
                            if accounts.count > 0
                            {
                                table.modeButton.setTitle("Requests (\(accounts.count)", forSegmentAtIndex: 1)
                            }
                            else {
                                table.modeButton.setTitle("Requests", forSegmentAtIndex: 1)
                            }
                        }
                    }
                    
                    if !Operations.loadingGames && table.refresher.refreshing
                    {
                        table.refresher.endRefreshing()
                    }
                }
            })
        })
    }
}