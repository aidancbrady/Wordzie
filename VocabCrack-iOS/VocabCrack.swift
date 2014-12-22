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
    var avatars:[String: UIImage] = [String: UIImage]()
    
    var learnedWords:[String] = [String]()
    
    var listID:String? = nil
    var activeList:[String] = [String]()
    
    var listURLs:[String: String] = [String: String]()
}

struct Handlers
{
    static var coreHandler:CoreHandler = CoreHandler()
    static var friendHandler:FriendHandler = FriendHandler()
    static var gameHandler:GameHandler = GameHandler()
    static var listHandler:ListHandler = ListHandler()
}

struct Constants
{
    static var IP:String = "104.236.13.142"
    static var PORT:Int = 26830
    
    static let VERSION:String = "1.0.0"
    static let DATA_URL:NSURL = NSURL(string: "https://dl.dropboxusercontent.com/u/90411166/Versions/VocabCrack.txt")!
    static let BAD_CHARS:[String] = [SPLITTER_1, SPLITTER_2, "&", " ", "|", LIST_SPLITTER]
    static let BANNED_CHARS:[String] = [SPLITTER_1, SPLITTER_2, "&", "|", LIST_SPLITTER]
    static let CORE:VocabCrack = VocabCrack()
    
    static let LIST_SPLITTER:String = ">"
    static let SPLITTER_1:String = "}"
    static let SPLITTER_2:String = "]"
    static let NULL:String = "|NULL|"
}

struct Defaults
{
    static var ACCOUNT:Account = Account(username: "Guest", email: "guest@test.com", password: "password")
    static var GAME:Game = Game(user: "Guest1", opponent: "Guest2")
}