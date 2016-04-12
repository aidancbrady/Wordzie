//
//  Game.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/4/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class Game: Equatable
{
    /// If this is an active or past game, this represents the active user.
    /// If this is a request, this represents the user that requested the game.
    var user:String

    /// If this is an active or past game, this represents the other user.
    /// If this is a request, this represents the user that received the request.
    var opponent:String

    /// The game type this game is following.
    var gameType:Int = 0

    var userTurn:Bool = false

    /// If this is a request, this will be the score of the requester.
    /// If this is an active game, this represents the active user's score.
    var userPoints:[Int] = [Int]()

    /// If this is a request, this will be empty.
    /// If this is an active game, this represents the other user's score.
    var opponentPoints:[Int] = [Int]()

    /// True if the active user requested this game, if this is the case then
    /// "user" represents the active user, and "opponent" represents the other
    /// player. Otherwise, "user" will represent the other player, and "opponent"
    /// will represent the active player.
    var activeRequested:Bool = false

    /// List of 10 words that were fabricated by the game host and are still in use.
    var activeWords:[String] = [String]()

    var listName:String?
    var listURL:String?

    /// Only used client-side
    var isRequest:Bool = false

    /// Only used client-side
    var opponentEmail:String?
    
    //If this game only contains enough data for a game list
    var isSimple:Bool = false
    
    //Values for efficient networking
    var simpleUserScore:Int = 0
    var simpleOpponentScore:Int = 0

    init(user:String, opponent:String)
    {
        self.user = user
        self.opponent = opponent
    }
    
    init(user:String, opponent:String, activeRequested:Bool)
    {
        self.user = user
        self.opponent = opponent
        self.activeRequested = activeRequested
        
        isRequest = true
    }
    
    func getNewRequestPair() -> Game
    {
        let g:Game = Game(user:user, opponent:opponent, activeRequested:!activeRequested)
        
        g.gameType = gameType
        g.listName = listName
        g.listURL = listURL
        g.activeWords = activeWords
        g.userTurn = !userTurn
        g.userPoints = [Int]()
        
        return g
    }
    
    func getNewPair() -> Game
    {
        let g:Game = Game(user:opponent, opponent:user)
        
        let temp:String = opponent
        g.opponent = user
        g.user = temp
        
        g.opponentPoints = [Int]()
        g.userPoints = [Int]()
        
        g.userTurn = !userTurn
        g.activeWords = activeWords
        g.listName = listName
        g.listURL = listURL
        
        return g
    }
    
    func convertToActive(userPerspective:String) -> Game
    {
        if(user != userPerspective) //If requesting user equals perspective user
        {
            let temp:String = opponent
            opponent = user
            user = temp
            
            opponentPoints = userPoints
            userPoints = [Int]()
        }
        
        isRequest = false
        
        return self
    }
    
    func convertToPast() -> Game
    {
        activeWords.removeAll(keepCapacity:false)
        
        return self
    }
    
    class func readDefault(s:String, splitter:String) -> Game?
    {
        var split:[String] = s.componentsSeparatedByString(splitter)
        
        if(split.count < 4)
        {
            return nil
        }
        
        let g:Game = Game(user:split[0], opponent:split[1])
        
        g.gameType = Int(split[2])!
        g.userTurn = Utilities.readBool(split[3])
        g.listName = split[4]
        g.listURL = split[5]
        
        var index:Int = g.readScoreList(split, start:6, user:true)
        index = g.readScoreList(split, start:index, user:false)
        
        g.readWordList(split[index])
        
        return g
    }
    
    class func readRequest(s:String, splitter:String) -> Game?
    {
        var split:[String] = s.componentsSeparatedByString(splitter)
        
        if(split.count < 4)
        {
            return nil
        }
        
        let g:Game = Game(user:split[1], opponent:split[2], activeRequested:Utilities.readBool(split[0]))
        
        g.gameType = Int(split[3])!
        g.userTurn = Utilities.readBool(split[4])
        g.listName = split[5]
        g.listURL = split[6]
        
        let index:Int = g.readScoreList(split, start:7, user:true)
        
        g.readWordList(split[index])
        
        return g
    }
    
    func writeDefault(str:NSMutableString, splitter:String)
    {
        str.appendString(user)
        str.appendString(splitter)
        str.appendString(opponent)
        str.appendString(splitter)
        str.appendString(String(gameType))
        str.appendString(splitter)
        str.appendString(userTurn ? "true" : "false")
        str.appendString(splitter)
        str.appendString(listName!)
        str.appendString(splitter)
        str.appendString(listURL!)
        str.appendString(splitter)
        
        writeScoreList(userPoints, str:NSMutableString(string: str), splitter:splitter)
        writeScoreList(opponentPoints, str:NSMutableString(string: str), splitter:splitter)
        
        writeWordList(str)
        str.appendString(splitter)
    }
    
    func writeRequest(str:NSMutableString, splitter:String)
    {
        str.appendString(activeRequested ? "true" : "false")
        str.appendString(splitter)
        str.appendString(user)
        str.appendString(splitter)
        str.appendString(opponent)
        str.appendString(splitter)
        str.appendString(String(gameType))
        str.appendString(splitter)
        str.appendString(userTurn ? "true" : "false")
        str.appendString(splitter)
        str.appendString(listName!)
        str.appendString(splitter)
        str.appendString(listURL!)
        str.appendString(splitter)
        
        writeScoreList(userPoints, str:NSMutableString(string: str), splitter:splitter)
        
        writeWordList(str)
        str.appendString(splitter)
    }
    
    func writeScoreList(score:[Int], str:NSMutableString, splitter:String)
    {
        str.appendString(String(score.count))
        str.appendString(splitter)
        
        for i in score
        {
            str.appendString(String(i))
            str.appendString(splitter)
        }
    }
    
    func readScoreList(array:[String], start:Int, user:Bool) -> Int
    {
        var list:[Int] = [Int]()
        
        let size:Int = Int(array[start])!
        var maxIndex:Int = size+start
        
        for i in 0 ..< size
        {
            list.append(Int(array[start+1+i])!)
            maxIndex = start+1+i
        }
        
        if(user)
        {
            userPoints = list
        }
        else {
            opponentPoints = list
        }
        
        return maxIndex+1
    }
    
    func writeWordList(str:NSMutableString)
    {
        for s in activeWords
        {
            str.appendString(s)
            str.appendString("&")
        }
        
        if activeWords.isEmpty
        {
            str.appendString("null")
        }
    }
    
    func readWordList(s:String)
    {
        var split:[String] = s.componentsSeparatedByString("&");
        
        if split.count == 1 && split[0] == "null"
        {
            return
        }
        
        activeWords.removeAll(keepCapacity: false)
        
        for word in split
        {
            activeWords.append(word)
        }
    }
    
    func getWinner() -> String?
    {
        let max:Int = GameType.getType(gameType).getWinningScore()
        
        if getUserScore() == max && getOpponentScore() == max
        {
            return nil
        }
        
        return getUserScore() == max ? user : (getOpponentScore() == max ? opponent : nil)
    }
    
    func hasWinner() -> Bool
    {
        let max = GameType.getType(gameType).getWinningScore();
        
        return getUserScore() == max || getOpponentScore() == max;
    }
    
    func getListName() -> String?
    {
        return listName
    }
    
    func getListURL() -> String?
    {
        return listURL
    }
    
    func getList() -> (String, String)
    {
        return (listName!, listURL!)
    }
    
    func setList(listName:String, listUrl:String)
    {
        self.listName = listName;
        self.listURL = listUrl
    }
    
    func getRequester() -> String
    {
        return user
    }
    
    func getRequestReceiver() -> String
    {
        return opponent
    }
    
    func getOtherUser(s:String) -> String
    {
        return user == s ? opponent : user
    }
    
    func setGameType(type:GameType)
    {
        gameType = type.getIndex()
    }
    
    func getGameType() -> GameType
    {
        return GameType.getType(gameType)
    }
    
    func hasUser(name:String) -> Bool
    {
        return user == name || opponent == name
    }
    
    func getScore(name:String) -> Int
    {
        return user == name ? getUserScore() : getOpponentScore()
    }
    
    func isWinning(name:String) -> Bool
    {
        return user == name ? getUserScore() > getOpponentScore() : getOpponentScore() > getUserScore()
    }
    
    func getWinning() -> String?
    {
        return isTied() ? nil : (isWinning(user) ? user : opponent);
    }
    
    func isTied() -> Bool
    {
        return getUserScore() == getOpponentScore();
    }
    
    func getUserScore() -> Int
    {
        if isSimple
        {
            return simpleUserScore
        }
        
        var won = 0;
        
        for i in 0 ..< userPoints.count
        {
            if i <= opponentPoints.count-1
            {
                if userPoints[i] >= opponentPoints[i]
                {
                    won += 1
                }
            }
        }
        
        return won;
    }
    
    func getOpponentScore() -> Int
    {
        if isSimple
        {
            return simpleOpponentScore
        }
        
        var won = 0;
        
        for i in 0 ..< opponentPoints.count
        {
            if i <= userPoints.count-1
            {
                if opponentPoints[i] >= userPoints[i]
                {
                    won += 1
                }
            }
        }
        
        return won;
    }
}

struct GameType
{
    var maxGames:Int
    var description:String
    
    init(maxGames:Int, description:String)
    {
        self.maxGames = maxGames
        self.description = description
    }
    
    func getWinningScore() -> Int
    {
        return maxGames
    }
    
    func getDescription() -> String
    {
        return description
    }
    
    func getIndex() -> Int
    {
        return maxGames-1
    }
    
    static func getType(index:Int) -> GameType
    {
        return index == 0 ? SINGLE : (index == 1 ? BEST_OF_3 : BEST_OF_5)
    }
    
    static var SINGLE = GameType(maxGames: 1, description: "Single Game")
    static var BEST_OF_3 = GameType(maxGames: 2, description: "Best of 3")
    static var BEST_OF_5 = GameType(maxGames: 3, description: "Best of 5")
}

func ==(lhs:Game, rhs:Game) -> Bool
{
    if lhs.user != rhs.user || lhs.opponent != rhs.opponent || lhs.gameType != rhs.gameType
    {
        return false
    }
    
    if lhs.userPoints != rhs.userPoints
    {
        return false
    }
    
    return false
}