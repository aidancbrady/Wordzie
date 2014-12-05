//
//  VocabCrack.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class VocabCrack
{
    var account:Account = Defaults.ACCOUNT
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
    static var VERSION:String = "1.0.0"
    static var BAD_CHARS:[Character] = [",", ":", "&", " ", "|", ">"]
    static var CORE:VocabCrack = VocabCrack()
}

struct Defaults
{
    static var ACCOUNT:Account = Account(username: "Guest", email: "guest@test.com", password: "password")
    static var GAME:Game = Game(user: "Guest1", opponent: "Guest2")
}