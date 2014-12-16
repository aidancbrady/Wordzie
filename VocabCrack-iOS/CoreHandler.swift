//
//  LoginHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/1/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class CoreHandler : NSObject, NSStreamDelegate
{
    func login(username:String, password:String) -> (Bool, String?)
    {
        let str = compileMsg("LOGIN", username, password)
        var ret = NetHandler.sendData(str)
        
        if let response = ret
        {
            let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
            
            if array[0] == "ACCEPT"
            {
                let acct:Account = Account(username:username, email:array[1], password:password)
                acct.setGamesWon(array[2].toInt()!)
                acct.setGamesLost(array[3].toInt()!)
                
                Constants.CORE.account = acct
                
                return (true, nil)
            }
            
            return (false, array[1])
        }
        
        return (false, nil)
    }
    
    func register(username:String, email:String, password:String) -> (Bool, String?)
    {
        let str = compileMsg("REGISTER", username, email, password)
        var ret = NetHandler.sendData(str)
        
        if let response = ret
        {
            let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
            
            if array[0] == "ACCEPT"
            {
                return (true, nil)
            }
            
            return (false, array[1])
        }
     
        return (false, nil)
    }
    
    func changePassword(password:String) -> (Bool, String?)
    {
        var str:String = compileMsg("CHANGEPASS", Constants.CORE.account.username, Constants.CORE.account.password!, password)
        
        var ret = NetHandler.sendData(str)
        
        if let response = ret
        {
            let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
            
            if array[0] == "ACCEPT"
            {
                return (true, nil)
            }
            
            return (false, array[1])
        }
        
        return (false, nil)
    }
}