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

    init(user:String, opponent:String)
    {
        self.user = user
        self.opponent = opponent
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
        
        static var SINGLE = GameType(maxGames: 1, description: "Single Game")
        static var BEST_OF_3 = GameType(maxGames: 2, description: "Best of 3")
        static var BEST_OF_5 = GameType(maxGames: 3, description: "Best of 5")
    }
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