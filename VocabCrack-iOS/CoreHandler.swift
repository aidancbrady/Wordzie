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
                
                var defaults = NSUserDefaults.standardUserDefaults()
                
                defaults.setObject(acct.username, forKey: "username")
                defaults.setObject(acct.email, forKey: "email")
                defaults.setObject(acct.password, forKey: "password")
                
                defaults.synchronize()
                
                return (true, nil)
            }
            
            return (false, array[1])
        }
        
        return (false, nil)
    }
    
    func sendDeviceID(deviceID:String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let str = compileMsg("PUSHID", Constants.CORE.account.username, deviceID)
            NetHandler.sendData(str)
            println("Sent device ID to server")
        })
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