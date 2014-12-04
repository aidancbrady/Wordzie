//
//  VocabCrack.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class VocabCrack
{

}

struct Handlers
{
    static var coreHandler:CoreHandler = CoreHandler()
    static var friendHandler:FriendHandler = FriendHandler()
    static var gameHandler:GameHandler = GameHandler()
}

struct Constants
{
    static var IP:String = "104.236.13.142"
    static var PORT:Int = 26830
}

struct Defaults
{
    static var ACCOUNT:Account = Account(username: "Guest", email: "guest@test.com", password: "password")
    static var GAME:Game = Game(user: "Guest1", opponent: "Guest2")
}