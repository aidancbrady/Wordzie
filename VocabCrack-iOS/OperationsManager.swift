//
//  OperationsManager.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

struct Operations
{
    static var loggingIn = false
    static var registering = false
    static var passwordChanging = false
    static var loadingGames = false
    static var loadingPast = false
    static var loadingFriends = false
    static var loadingRequests = false
    static var loadingAvatars:NSMutableArray = NSMutableArray()
    static var loadingLists = false
    
    static var currentOperations = 0
    
    static func setNetworkActivity(_ activity:Bool)
    {
        if activity
        {
            currentOperations += 1
        }
        else {
            currentOperations -= 1
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = currentOperations > 0
        }
    }
}
