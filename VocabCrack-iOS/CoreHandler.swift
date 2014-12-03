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
    func login() -> (Bool, [String]?)
    {
        let str = "LOGIN:aidancbrady:aidan1"
        
        var net = NetHandler()
        var ret = net.sendData(str)
        
        if let response = ret
        {
            let array:[String] = response.componentsSeparatedByString(":")
            
            return (array[0] == "ACCEPT", array)
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