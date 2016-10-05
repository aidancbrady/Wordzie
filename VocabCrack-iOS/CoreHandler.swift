//
//  LoginHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/1/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation

class CoreHandler : NSObject, StreamDelegate
{
    func login(_ username:String, password:String) -> (Bool, String?)
    {
        let str = compileMsg("LOGIN", username, password)
        let ret = NetHandler.sendData(str)
        
        if let response = ret
        {
            let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
            
            if array[0] == "ACCEPT"
            {
                let acct:Account = Account(username:username, email:array[1], password:password)
                acct.setGamesWon(Int(array[2])!)
                acct.setGamesLost(Int(array[3])!)
                
                Constants.CORE.account = acct
                
                let defaults = UserDefaults.standard
                
                defaults.set(acct.username, forKey: "username")
                defaults.set(acct.email, forKey: "email")
                defaults.set(acct.password, forKey: "password")
                
                defaults.synchronize()
                
                return (true, nil)
            }
            
            return (false, array[1])
        }
        
        return (false, nil)
    }
    
    func sendDeviceID(_ deviceID:String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("PUSHID", Constants.CORE.account.username, deviceID)
            NetHandler.sendData(str)
            print("Sent device ID to server")
        }
    }
    
    func register(_ username:String, email:String, password:String) -> (Bool, String?)
    {
        let str = compileMsg("REGISTER", username, email, password)
        let ret = NetHandler.sendData(str)
        
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
    
    func changePassword(_ password:String) -> (Bool, String?)
    {
        let str:String = compileMsg("CHANGEPASS", Constants.CORE.account.username, Constants.CORE.account.password!, password)
        
        let ret = NetHandler.sendData(str)
        
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
