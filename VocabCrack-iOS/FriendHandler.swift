//
//  FriendHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class FriendHandler
{
    func updateData(_ controller:WeakWrapper<TableDataReceiver>)
    {
        updateFriends(controller)
        updateRequests(controller)
    }
    
    func updateFriends(_ controller:WeakWrapper<TableDataReceiver>)
    {
        if Operations.loadingGames
        {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            Operations.loadingGames = true
            
            let str = compileMsg("LFRIENDS", Constants.CORE.account.username)
            let ret = NetHandler.sendData(str, retLines:2)
            
            DispatchQueue.main.async {
                Operations.loadingGames = false
                
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response[0], separator: Constants.SPLITTER_1)
                        let array1:[String] = Utilities.split(response[1], separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            var accounts:[Account] = [Account]()
                            
                            for i in 1 ..< array.count
                            {
                                var split:[String] = array[i].components(separatedBy: Constants.SPLITTER_2)
                                accounts.append(Account(username:split[0], isRequest:false).setEmail(split[1]).setLastLogin(NSString(string: split[2]).longLongValue))
                            }
                            
                            for i in 1 ..< array1.count
                            {
                                accounts.append(Account(username:array1[i], isRequest:true))
                            }
                            
                            table.receiveData(accounts, type: 0)
                            table.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        }
                    }
                    
                    if !Operations.loadingPast
                    {
                        table.endRefresh()
                    }
                }
            }
        }
    }
    
    func updateRequests(_ controller:WeakWrapper<TableDataReceiver>)
    {
        if Operations.loadingPast
        {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            Operations.loadingPast = true
            
            let str = compileMsg("LREQUESTS", Constants.CORE.account.username)
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
                Operations.loadingPast = false
                
                if let table = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            var accounts:[Account] = [Account]()
                            
                            for i in 1 ..< array.count
                            {
                                var split:[String] = array[i].components(separatedBy: Constants.SPLITTER_2)
                                accounts.append(Account(username:split[0], isRequest:false).setEmail(split[1]))
                            }
                            
                            table.receiveData(accounts, type: 1)
                            table.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                            
                            if table is FriendsController
                            {
                                (table as! FriendsController).updateModeTitle()
                            }
                        }
                    }
                    
                    if !Operations.loadingGames
                    {
                        table.endRefresh()
                    }
                }
            }
        }
    }
    
    func deleteFriend(_ friend:String, type:Int)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("DELFRIEND", Constants.CORE.account.username, friend, String(type))
            NetHandler.sendData(str)
        }
    }
    
    func updateSearch(_ controller:WeakWrapper<AddFriendController>, query:String)
    {
        if !Utilities.isValidCredential(query)
        {
            return
        }
        
        controller.value!.activity.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("LUSERS", Constants.CORE.account.username, Utilities.trim(query))
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
                if let table = controller.value
                {
                    table.activity.stopAnimating()
                    
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            table.users.removeAll(keepingCapacity: false)
                            
                            if array.count > 1
                            {
                                table.users = Utilities.split(array[1], separator: Constants.SPLITTER_2)
                            }
                            
                            table.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func sendRequest(_ controller:WeakWrapper<AddFriendController>, friend:String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("FRIENDREQ", Constants.CORE.account.username, friend)
            NetHandler.sendData(str)
        }
    }
    
    func acceptRequest(_ controller:WeakWrapper<FriendsController>, friend:String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("REQCONF", Constants.CORE.account.username, friend)
            NetHandler.sendData(str)
        }
    }
    
    func getInfo(_ controller:WeakWrapper<UserDetailController>, friend:String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("GETINFO", Constants.CORE.account.username, friend)
            let ret = NetHandler.sendData(str)
            
            DispatchQueue.main.async {
                if let detail = controller.value
                {
                    if let response = ret
                    {
                        let array:[String] = Utilities.split(response, separator: Constants.SPLITTER_1)
                        
                        if array[0] == "ACCEPT"
                        {
                            let won = Int(array[2])!
                            let lost = Int(array[3])!
                            let login = NSString(string: array[4]).longLongValue

                            detail.acct = Account(username: friend, email: array[1], password: "password").setGamesWon(won).setGamesLost(lost).setLastLogin(login)
                            detail.setAccountData()
                        }
                    }
                }
            }
        }
    }
}
