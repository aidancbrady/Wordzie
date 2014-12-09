//
//  GameHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class GameHandler
{
    func updateData(controller:WeakWrapper<GamesController>)
    {
        updateGames(controller)
        updatePast(controller)
    }
    
    func updateGames(controller:WeakWrapper<GamesController>)
    {
        if Operations.loadingGames
        {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.loadingGames = true
            
            let str = "LGAMES:" + Constants.CORE.account.username
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
                            var games:[Game] = [Game]()
                            
                            for var i = 1; i < array.count; i+=2
                            {
                                var g:Game = Game.readDefault(array[i], splitter: ",")!
                                g.opponentEmail = array[i+1]
                                games.append(g)
                            }
                                
                            for var i = 1; i < array1.count; i+=2
                            {
                                var g:Game = Game.readRequest(array1[i], splitter: ",")!
                                g.opponentEmail = array1[i+1]
                                games.append(g)
                            }
                            
                            table.activeGames = games
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
    
    func updatePast(controller:WeakWrapper<GamesController>)
    {
        if Operations.loadingPast
        {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            Operations.loadingPast = true
            
            let str = "LPAST:" + Constants.CORE.account.username
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
                            var games:[Game] = [Game]()
                            
                            for var i = 1; i < array.count; i+=2
                            {
                                var g:Game = Game.readDefault(array[i], splitter: ",")!
                                g.opponentEmail = array[i+1]
                                games.append(g)
                            }
                            
                            table.pastGames = games
                            table.tableView.reloadData()
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
    
    func acceptRequest(controller:WeakWrapper<GamesController>, friend:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = "GAMEREQCONF:" + Constants.CORE.account.username + ":" + friend
            NetHandler.sendData(str)
        })
    }
    
    func deleteGame(controller:WeakWrapper<GamesController>, friend:String, type:Int, index:Int...)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var str = "DELGAME:" + Constants.CORE.account.username
            str += ":" + friend + ":\(type)"
            
            if type == 1
            {
                str += String(index[0])
            }
            
            NetHandler.sendData(str)
        })
    }
}