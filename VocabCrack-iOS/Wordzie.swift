//
//  VocabCrack.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class Wordzie
{
    var account:Account = Defaults.ACCOUNT
    var avatars:[String: UIImage] = [String: UIImage]()
    
    var learnedWords:[String] = [String]()
    
    var listData:(String, String)? = nil
    var activeList:[String] = [String]()
    
    var listURLs:[String: String] = [String: String]()
    
    var dataState:Bool?
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
    static var IP:String = "server.aidancbrady.com"
    static var PORT:Int = 26830
    
    static let VERSION:String = "1.0.0"
    static let DATA_URL:URL = URL(string: "http://aidancbrady.com/data/versions/Wordzie.txt")!
    static let BAD_CHARS:[String] = [SPLITTER_1, SPLITTER_2, "&", " ", "|", LIST_SPLITTER]
    static let BANNED_CHARS:[String] = [SPLITTER_1, SPLITTER_2, "&", "|", LIST_SPLITTER]
    static let CORE:Wordzie = Wordzie()
    
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
