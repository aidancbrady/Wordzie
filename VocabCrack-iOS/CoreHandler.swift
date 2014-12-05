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
        let str = "LOGIN:" + username + ":" + password
        
        var net = NetHandler()
        var ret = net.sendData(str)
        
        if let response = ret
        {
            let array:[String] = Utilities.trim(response).componentsSeparatedByString(":")
            
            if(array[0] == "ACCEPT")
            {
                let acct:Account = Account(username:username, email:array[1], password:password)
                acct.setGamesWon(array[2].toInt()!)
                println(array[3].endIndex)
                acct.setGamesLost(array[3].toInt()!)
                
                Constants.CORE.account = acct
                
                return (true, nil)
            }
            
            return (false, array[1])
        }
        
        return (false, nil)
    }
    
    func register() -> (Bool, String?)
    {
        return (false, nil)
    }
    
    func changePassword() -> (Bool, String?)
    {
        return (false, nil)
    }
}