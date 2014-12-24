//
//  GameController.swift
//  Wordzie
//
//  Created by aidancbrady on 12/14/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class GameController: UIViewController
{
    @IBOutlet weak var definitionView: UIView!
    @IBOutlet weak var definition1: UIButton!
    @IBOutlet weak var definition2: UIButton!
    @IBOutlet weak var definition3: UIButton!
    @IBOutlet weak var definition4: UIButton!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    
    /// -1 if game hasn't started, 0-9 if game has begun, 10 if game is over
    var wordIndex = -1
    var complete = true
    var timeLeft = 30
    var amountCorrect = 0
    var correctDef = -1
    
    var singleplayer = false
    var game:Game!
    var timer:NSTimer = NSTimer()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initDefinition(definition1)
        initDefinition(definition2)
        initDefinition(definition3)
        initDefinition(definition4)
        
        setNeedsStatusBarAppearanceUpdate()
        
        initGame()
        
        var anim:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.fromValue = NSNumber(float: 0.5)
        anim.toValue = NSNumber(float: 1)
        anim.autoreverses = true
        anim.duration = 0.5
        anim.repeatCount = 1e100
        secondaryLabel.layer.addAnimation(anim, forKey: "flash")
        
        primaryLabel.hidden = false
        secondaryLabel.hidden = false
        
        leftLabel.hidden = false
        
        if(!singleplayer)
        {
            rightLabel.hidden = false
        }
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    func initGame()
    {
        leftLabel.text = game.listName
        
        if !singleplayer
        {
            rightLabel.text = "\(game.getUserScore()) - \(game.getOpponentScore())"
        }
        
        game.activeWords = WordDataHandler.createWordSet()
    }
    
    func initDefinition(definition:UIButton)
    {
        definition.titleLabel!.numberOfLines = 3
        definition.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        definition.titleLabel!.textAlignment = NSTextAlignment.Left
        definition.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    
    func setTermData()
    {
        correctDef = Int(arc4random_uniform(4))
        let defs = createDefs()
        
        wordLabel.text = Utilities.split(getCurrentTerm(), separator: Constants.LIST_SPLITTER)[0]
        
        definition1.setTitle(defs[0], forState: UIControlState.Normal)
        definition2.setTitle(defs[1], forState: UIControlState.Normal)
        definition3.setTitle(defs[2], forState: UIControlState.Normal)
        definition4.setTitle(defs[3], forState: UIControlState.Normal)
    }
    
    func createDefs() -> [String]
    {
        var list:[String] = [String]()
        
        while list.count < 4
        {
            let term = Constants.CORE.activeList[Int(arc4random_uniform(UInt32(Constants.CORE.activeList.count)))]
            let def = Utilities.split(term, separator: Constants.LIST_SPLITTER)[1]
            
            if def != Utilities.split(getCurrentTerm(), separator: Constants.LIST_SPLITTER)[1]
            {
                list.append(def)
            }
        }
        
        list[correctDef] = Utilities.split(getCurrentTerm(), separator: Constants.LIST_SPLITTER)[1]
        
        return list
    }
    
    func getCurrentTerm() -> String
    {
        return game.activeWords[wordIndex]
    }
    
    @IBAction func viewTapped(sender: AnyObject)
    {
        if wordIndex < 9 && complete //Called when the user needs to advance to a new question
        {
            if wordIndex == -1 //If the game hasn't yet started
            {
                slideOut(primaryLabel)
                slideOut(secondaryLabel)
                
                fadeIn(remainingLabel)
                
                wordIndex = 0
            }
            
            complete = false
            
            setTermData()
            
            slideIn(wordLabel)
            slideIn(definitionView)
            
            fadeIn(timerLabel)
            
            if !timer.valid
            {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            }
        }
        else if wordIndex == 9 && complete //Called after last response view
        {
            fadeOut(remainingLabel)
            fadeOut(timerLabel)
        }
    }
    
    func updateTime()
    {
        timeLeft--
        timerLabel.text = "Timer: \(timeLeft)s"
    }
    
    func slideOut(view:UIView)
    {
        let prevRect = view.frame
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            view.frame = CGRectMake(-self.view.frame.width, prevRect.minY, prevRect.width, prevRect.height)
        }, completion: {finished in
            view.hidden = true
            view.frame = prevRect
        })
    }
    
    func slideIn(view:UIView)
    {
        let prevRect = view.frame
        
        view.frame = CGRectMake(self.definitionView.frame.width, view.frame.minY, view.frame.width, view.frame.height)
        view.hidden = false
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            view.frame = prevRect
        }, completion: nil)
    }
    
    func fadeOut(views: UIView...)
    {
        UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
            for view in views
            {
                view.alpha = 0
            }
        }, completion: {b in
            for view in views
            {
                view.hidden = true
            }
        })
    }
    
    func fadeIn(views: UIView...)
    {
        for view in views
        {
            view.hidden = false
            view.alpha = 0.1
        }
        
        UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
            for view in views
            {
                view.alpha = 1
            }
        }, completion: nil)
    }
}
