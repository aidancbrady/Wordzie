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
    func updateData(_ controller:WeakWrapper<GamesController>)
    {
        updateGames(controller)
        updatePast(controller)
    }
    
    func updateGames(_ controller:WeakWrapper<GamesController>)
    {
        if Operations.loadingGames
        {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            Operations.loadingGames = true
            
            let str = compileMsg("LGAMES_S", Constants.CORE.account.username)
            let ret = NetHandler.sendData(str, retLines:2)
            
            DispatchQueue.main.async {
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
                            
                            for i in 1 ..< array.count
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
                                
                            for i in 1 ..< array1.count
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
                            table.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        }
                    }
                    
                    if !Operations.loadingPast && table.refresher.isRefreshing
                    {
                        table.refresher.endRefreshing()
                    }
                }
            }
        }
    }
    
    func updatePast(_ controller:WeakWrapper<GamesController>)
    {
        if Operations.loadingPast
        {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            Operations.loadingPast = true
            
            let str = compileMsg("LPAST", Constants.CORE.account.username)
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
                Operations.loadingPast = false
                
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            var games:[Game] = [Game]()
                            
                            for i in stride(from: 1, to: array.count, by: 2)
                            {
                                let g:Game? = Game.readDefault(array[i], splitter: Constants.SPLITTER_2)
                                
                                g!.opponentEmail = array[i+1]
                                games.append(g!)
                            }
                            
                            table.pastGames = games
                            table.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        }
                    }
                    
                    if !Operations.loadingGames && table.refresher.isRefreshing
                    {
                        table.refresher.endRefreshing()
                    }
                }
            }
        }
    }
    
    func acceptRequest(_ controller:WeakWrapper<GamesController>, friend:String, handler:(() -> Void)?)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("GAMEREQCONF", Constants.CORE.account.username, friend)
            NetHandler.sendData(str)
            
            DispatchQueue.main.async {
                handler?()
                return
            }
        }
    }
    
    func deleteGame(_ controller:WeakWrapper<GamesController>, friend:String, type:Int, index:Int...)
    {
        DispatchQueue.global(qos: .background).async {
            var str = compileMsg("DELGAME", Constants.CORE.account.username, friend, String(type))
            
            if type == 1
            {
                str += Constants.SPLITTER_1
                str += String(index[0])
            }
            
            NetHandler.sendData(str)
        }
    }
    
    func confirmGame(_ controller:WeakWrapper<NewGameController>, friend:String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("CONFGAME", Constants.CORE.account.username, friend)
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
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
            }
        }
    }
    
    func newGame(_ controller:WeakWrapper<RoundOverController>)
    {
        let game = controller.value!.game!
        
        let listData = NSMutableString()
        game.writeWordList(listData)
        
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("NEWGAME", Constants.CORE.account.username, game.getRequestReceiver(), String(game.gameType), String(game.userPoints[game.userPoints.count-1]), game.getListName()!, game.getListURL()!, listData as String)
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
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
            }
        }
    }
    
    func compGame(_ controller:WeakWrapper<RoundOverController>)
    {
        let game = controller.value!.game!
        
        var listData: NSMutableString?
        
        if game.userPoints.count != game.opponentPoints.count
        {
            listData = NSMutableString()
            game.writeWordList(listData!)
        }
        
        DispatchQueue.global(qos: .background).async {
            var str = compileMsg("COMPGAME", Constants.CORE.account.username, game.getRequestReceiver(), String(game.userPoints[game.userPoints.count-1]))
            
            if listData != nil
            {
                str = compileMsg(str, listData! as String)
            }
            
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
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
            }
        }
    }
    
    func getInfo(_ controller:WeakWrapper<GameDetailController>, friend:String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("GETGAME", Constants.CORE.account.username, friend)
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
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
            }
        }
    }
}
