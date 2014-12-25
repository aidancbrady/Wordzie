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
    var timeLeft = 20
    var amountCorrect = 0
    var correctDef = -1
    
    var animations = 0
    
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
        primaryLabel.text = "Round \(game.userPoints.count+1)"
        
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
    
    func onAnswer(correct:Bool)
    {
        if animations > 0
        {
            return
        }
        
        if correct
        {
            amountCorrect++
        }
        
        complete = true
        
        timerLabel.textColor = UIColor.blackColor()
        timerLabel.layer.removeAnimationForKey("flash")
        
        remainingLabel.text = "Score: \(amountCorrect)/10"
        
        view.backgroundColor = correct ? UIColor.greenColor() : UIColor.redColor()
        
        slideOut(wordLabel)
        slideOut(definitionView)
        
        primaryLabel.text = correct ? "Correct" : "Incorrect"
        secondaryLabel.text = "Tap to continue"
        
        let split = Utilities.split(getCurrentTerm(), separator: Constants.LIST_SPLITTER)
        correctLabel.text = split[0] + ": " + split[1]
        
        slideIn(primaryLabel)
        slideIn(secondaryLabel)
        slideIn(correctLabel)
        
        timeLeft = 20
        timer.invalidate()
        
        fadeOut({() in
            self.timerLabel.text = "Timer: 20s"
        }, views: timerLabel)
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
        if animations > 0
        {
            return
        }
        
        if wordIndex < 9 && complete //Called when the user needs to advance to a new question
        {
            if wordIndex == -1 //If the game hasn't yet started
            {
                fadeIn(nil, views: remainingLabel)
            }
            
            wordIndex++
            complete = false
            
            setTermData()
            
            view.backgroundColor = UIColor.whiteColor()
            
            slideIn(wordLabel)
            slideIn(definitionView)
            
            slideOut(primaryLabel)
            slideOut(secondaryLabel)
            slideOut(correctLabel)
            
            fadeIn(nil, views: timerLabel)
            
            if !timer.valid
            {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            }
        }
        else if wordIndex == 9 && complete //Called after last response view
        {
            finalizeGameData()
            
            let roundOver:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RoundOverController") as UIViewController
            
            (roundOver as RoundOverController).game = game
            (roundOver as RoundOverController).singleplayer = singleplayer
            
            navigationController!.pushViewController(roundOver, animated: true)
        }
    }
    
    func finalizeGameData()
    {
        game.userPoints.append(amountCorrect)
    }
    
    func updateTime()
    {
        timeLeft--
        
        if timeLeft == -1
        {
            timerLabel.textColor = UIColor.blackColor()
            timerLabel.layer.removeAnimationForKey("flash")
            
            onAnswer(false)
            
            return
        }
        
        timerLabel.text = "Timer: \(timeLeft)s"
        
        if timeLeft > 10
        {
            timerLabel.textColor = UIColor.blackColor()
            timerLabel.layer.removeAnimationForKey("flash")
        }
        else if timeLeft <= 10
        {
            timerLabel.textColor = UIColor.redColor()
            
            if timeLeft == 5
            {
                var anim:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
                anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                anim.fromValue = NSNumber(float: 0.5)
                anim.toValue = NSNumber(float: 1)
                anim.autoreverses = true
                anim.duration = 0.5
                anim.repeatCount = 1e100
                timerLabel.layer.addAnimation(anim, forKey: "flash")
            }
            else if timeLeft > 5
            {
                timerLabel.layer.removeAnimationForKey("flash")
            }
        }
    }
    
    @IBAction func onDef1(sender: AnyObject)
    {
        onAnswer(correctDef == 0)
    }
    
    @IBAction func onDef2(sender: AnyObject)
    {
        onAnswer(correctDef == 1)
    }
    
    @IBAction func onDef3(sender: AnyObject)
    {
        onAnswer(correctDef == 2)
    }
    
    @IBAction func onDef4(sender: AnyObject)
    {
        onAnswer(correctDef == 3)
    }
    
    func slideOut(view:UIView)
    {
        let transform:CGAffineTransform = CGAffineTransformMake(1, 0, 0, 1, -view.frame.width-view.frame.minX, 0)
        
        animations++
        
        UIView.transitionWithView(view, duration: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            view.transform = transform
        }, completion: {finished in
            view.hidden = true
            view.transform = CGAffineTransformIdentity
            
            self.animations--
        })
    }
    
    func slideIn(view:UIView)
    {
        let prevRect = view.frame
        
        view.frame = CGRectMake(definitionView.frame.width, view.frame.minY, view.frame.width, view.frame.height)
        view.hidden = false
        
        animations++
        
        UIView.transitionWithView(view, duration: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            view.frame = prevRect
        }, completion: {b in
            self.animations--
            return
        })
    }
    
    func fadeOut(completion: (() -> Void)?, views: UIView...)
    {
        animations += views.count
        
        UIView.transitionWithView(view, duration: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            for view in views
            {
                view.alpha = 0
            }
        }, completion: {b in
            for view in views
            {
                view.hidden = true
            }
            
            self.animations -= views.count
            
            completion?()
        })
    }
    
    func fadeIn(completion: (() -> Void)?, views: UIView...)
    {
        for view in views
        {
            view.hidden = false
            view.alpha = 0.1
        }
        
        animations += views.count
        
        UIView.transitionWithView(view, duration: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            for view in views
            {
                view.alpha = 1
            }
        }, completion: {finished in
            self.animations -= views.count
            completion?()
            return
        })
    }
}
