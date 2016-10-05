//
//  Account.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class Account
{
    var username:String
    var email:String?
    var password:String?
    
    var isRequest:Bool = false
    
    var gamesWon:Int = 0
    var gamesLost:Int = 0
    
    var lastLogin:Int64 = 0
    
    var friends:[Account] = [Account]()
    var requests:[Account] = [Account]()
    var requested:[Account] = [Account]()
    
    var activeGames:[Game] = [Game]()
    var requestGames:[Game] = [Game]()
    var pastGames:[Game] = [Game]()
    
    init(username:String, isRequest:Bool)
    {
        self.username = username
        self.isRequest = isRequest
    }
    
    init(username:String, email:String, password:String)
    {
        self.username = username
        self.email = email
        self.password = password
    }
    
    func setFriendData(_ friends:[Account], requests:[Account], requested:[Account]) -> Account
    {
        self.friends = friends
        self.requests = requests
        self.requested = requested
        
        return self
    }
    
    func setUsername(_ username:String) -> Account
    {
        self.username = username
        
        return self
    }
    
    func setEmail(_ email:String) -> Account
    {
        self.email = email
        
        return self
    }
    
    func setPassword(_ password:String) -> Account
    {
        self.password = password
        
        return self
    }
    
    func setGamesWon(_ gamesWon:Int) -> Account
    {
        self.gamesWon = gamesWon
        
        return self
    }
    
    func setGamesLost(_ gamesLost:Int) -> Account
    {
        self.gamesLost = gamesLost
        
        return self
    }
    
    func setLastLogin(_ lastLogin:Int64) -> Account
    {
        self.lastLogin = lastLogin
        
        return self
    }
}
