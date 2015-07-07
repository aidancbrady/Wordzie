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
            
            let str = compileMsg("LGAMES_S", Constants.CORE.account.username)
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
                            var games:[Game] = [Game]()
                            
                            for var i = 1; i < array.count; i++
                            {
                                let gameData:[String] = Utilities.split(array[i], separator: Constants.SPLITTER_2)
                                let g:Game = Game(user: Constants.CORE.account.username, opponent: gameData[0])
                                g.isSimple = true
                                g.userTurn = Utilities.readBool(gameData[1])
                                g.simpleUserScore = Int(gameData[2])!
                                g.simpleOpponentScore = Int(gameData[3])!
                                g.opponentEmail = gameData[4]
                                
                                games.append(g)
                            }
                                
                            for var i = 1; i < array1.count; i++
                            {
                                let gameData:[String] = Utilities.split(array1[i], separator: Constants.SPLITTER_2)
                                let opponent = gameData[0]
                                let userTurn = Utilities.readBool(gameData[1])
                                let g:Game = userTurn ? Game(user: opponent, opponent: Constants.CORE.account.username, activeRequested: false) : Game(user: Constants.CORE.account.username, opponent: opponent, activeRequested: true)
                                g.isSimple = true
                                g.simpleUserScore = Int(gameData[2])!
                                g.opponentEmail = gameData[3]
                                
                                games.append(g)
                            }
                            
                            table.activeGames = games
                            table.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
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
            
            let str = compileMsg("LPAST", Constants.CORE.account.username)
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
                            var games:[Game] = [Game]()
                            
                            for var i = 1; i < array.count; i+=2
                            {
                                let g:Game? = Game.readDefault(array[i], splitter: Constants.SPLITTER_2)
                                
                                g!.opponentEmail = array[i+1]
                                games.append(g!)
                            }
                            
                            table.pastGames = games
                            table.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
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
    
    func acceptRequest(controller:WeakWrapper<GamesController>, friend:String, handler:(() -> Void)?)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("GAMEREQCONF", Constants.CORE.account.username, friend)
            NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                handler?()
                return
            })
        })
    }
    
    func deleteGame(controller:WeakWrapper<GamesController>, friend:String, type:Int, index:Int...)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var str = compileMsg("DELGAME", Constants.CORE.account.username, friend, String(type))
            
            if type == 1
            {
                str += Constants.SPLITTER_1
                str += String(index[0])
            }
            
            NetHandler.sendData(str)
        })
    }
    
    func confirmGame(controller:WeakWrapper<NewGameController>, friend:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("CONFGAME", Constants.CORE.account.username, friend)
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let newGame = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            newGame.confirmGame(true, response: nil)
                        }
                        else {
                            newGame.confirmGame(false, response: array[1])
                        }
                    }
                    else {
                        newGame.confirmGame(false, response: "Unable to connect.")
                    }
                }
            })
        })
    }
    
    func newGame(controller:WeakWrapper<RoundOverController>)
    {
        let game = controller.value!.game
        
        let listData = NSMutableString()
        game.writeWordList(listData)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("NEWGAME", Constants.CORE.account.username, game.getRequestReceiver(), String(game.gameType), String(game.userPoints[game.userPoints.count-1]), game.getListName()!, game.getListURL()!, listData as String)
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let roundOver = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            roundOver.confirmResponse(true)
                        }
                        else {
                            roundOver.confirmResponse(false)
                        }
                    }
                    else {
                        roundOver.confirmResponse(false)
                    }
                }
            })
        })
    }
    
    func compGame(controller:WeakWrapper<RoundOverController>)
    {
        let game = controller.value!.game
        
        var listData: NSMutableString?
        
        if game.userPoints.count != game.opponentPoints.count
        {
            listData = NSMutableString()
            game.writeWordList(listData!)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var str = compileMsg("COMPGAME", Constants.CORE.account.username, game.getRequestReceiver(), String(game.userPoints[game.userPoints.count-1]))
            
            if listData != nil
            {
                str = compileMsg(str, listData! as String)
            }
            
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let roundOver = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            roundOver.confirmResponse(true)
                        }
                        else {
                            roundOver.confirmResponse(false)
                        }
                    }
                    else {
                        roundOver.confirmResponse(false)
                    }
                }
            })
        })
    }
    
    func getInfo(controller:WeakWrapper<GameDetailController>, friend:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("GETGAME", Constants.CORE.account.username, friend)
            let ret = NetHandler.sendData(str)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let detail = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            let game = Game.readDefault(array[1], splitter: Constants.SPLITTER_2)
                            game!.opponentEmail = array[2]
                            
                            if game != nil
                            {
                                detail.game = game
                                detail.setGameData()
                            }
                        }
                    }
                }
            })
        })
    }
}