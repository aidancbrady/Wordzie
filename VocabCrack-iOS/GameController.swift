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
    var timer:Timer = Timer()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initDefinition(definition1)
        initDefinition(definition2)
        initDefinition(definition3)
        initDefinition(definition4)
        
        Utilities.roundButtons(definitionView)
        
        setNeedsStatusBarAppearanceUpdate()
        
        initGame()
        
        let anim:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.fromValue = NSNumber(value: 0.5 as Float)
        anim.toValue = NSNumber(value: 1 as Float)
        anim.autoreverses = true
        anim.duration = 0.5
        anim.repeatCount = 1e100
        secondaryLabel.layer.add(anim, forKey: "flash")
        
        primaryLabel.isHidden = false
        secondaryLabel.isHidden = false
        
        leftLabel.isHidden = false
        rightLabel.isHidden = false
    }
    
    override var prefersStatusBarHidden : Bool
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
        else {
            rightLabel.text = "Singleplayer"
        }
        
        if game.userPoints.count == game.opponentPoints.count
        {
            game.activeWords = WordDataHandler.createWordSet()
        }
    }
    
    func initDefinition(_ definition:UIButton)
    {
        definition.titleLabel!.numberOfLines = 3
        definition.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        definition.titleLabel!.textAlignment = NSTextAlignment.left
        definition.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    
    func setTermData()
    {
        correctDef = Int(arc4random_uniform(4))
        let defs = createDefs()
        
        wordLabel.text = Utilities.split(getCurrentTerm(), separator: Constants.LIST_SPLITTER)[0]
        
        definition1.setTitle(defs[0], for: UIControlState())
        definition2.setTitle(defs[1], for: UIControlState())
        definition3.setTitle(defs[2], for: UIControlState())
        definition4.setTitle(defs[3], for: UIControlState())
    }
    
    func onAnswer(_ correct:Bool)
    {
        if animations > 0
        {
            return
        }
        
        if correct
        {
            amountCorrect += 1
            
            let prev:String = Utilities.split(game.activeWords[wordIndex-1], separator: Constants.LIST_SPLITTER)[0];
            Constants.CORE.learnedWords.append(prev);
            WordDataHandler.save();
        }
        
        complete = true
        
        timerLabel.textColor = UIColor.black
        timerLabel.layer.removeAnimation(forKey: "flash")
        
        remainingLabel.text = "Score: \(amountCorrect)/10"
        
        view.backgroundColor = correct ? UIColor.green : UIColor.red
        
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
    
    @IBAction func viewTapped(_ sender: AnyObject)
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
            
            wordIndex += 1
            complete = false
            
            setTermData()
            
            view.backgroundColor = UIColor.white
            
            slideIn(wordLabel)
            slideIn(definitionView)
            
            slideOut(primaryLabel)
            slideOut(secondaryLabel)
            slideOut(correctLabel)
            
            fadeIn(nil, views: timerLabel)
            
            if !timer.isValid
            {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameController.updateTime), userInfo: nil, repeats: true)
            }
        }
        else if wordIndex == 9 && complete //Called after last response view
        {
            finalizeGameData()
            
            let roundOver:UIViewController = self.storyboard?.instantiateViewController(withIdentifier: "RoundOverController") as UIViewController!
            
            (roundOver as! RoundOverController).game = game
            (roundOver as! RoundOverController).singleplayer = singleplayer
            
            navigationController!.pushViewController(roundOver, animated: true)
        }
    }
    
    func finalizeGameData()
    {
        game.userPoints.append(amountCorrect)
    }
    
    func updateTime()
    {
        timeLeft -= 1
        
        if timeLeft == -1
        {
            timerLabel.textColor = UIColor.black
            timerLabel.layer.removeAnimation(forKey: "flash")
            
            onAnswer(false)
            
            return
        }
        
        timerLabel.text = "Timer: \(timeLeft)s"
        
        if timeLeft > 10
        {
            timerLabel.textColor = UIColor.black
            timerLabel.layer.removeAnimation(forKey: "flash")
        }
        else if timeLeft <= 10
        {
            timerLabel.textColor = UIColor.red
            
            if timeLeft == 5
            {
                let anim:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
                anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                anim.fromValue = NSNumber(value: 0.5 as Float)
                anim.toValue = NSNumber(value: 1 as Float)
                anim.autoreverses = true
                anim.duration = 0.5
                anim.repeatCount = 1e100
                timerLabel.layer.add(anim, forKey: "flash")
            }
            else if timeLeft > 5
            {
                timerLabel.layer.removeAnimation(forKey: "flash")
            }
        }
    }
    
    @IBAction func onDef1(_ sender: AnyObject)
    {
        onAnswer(correctDef == 0)
    }
    
    @IBAction func onDef2(_ sender: AnyObject)
    {
        onAnswer(correctDef == 1)
    }
    
    @IBAction func onDef3(_ sender: AnyObject)
    {
        onAnswer(correctDef == 2)
    }
    
    @IBAction func onDef4(_ sender: AnyObject)
    {
        onAnswer(correctDef == 3)
    }
    
    func slideOut(_ view:UIView)
    {
        let transform:CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: -view.frame.width-view.frame.minX, ty: 0)
        
        animations += 1
        
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            view.transform = transform
        }, completion: {finished in
            view.isHidden = true
            view.transform = CGAffineTransform.identity
            
            self.animations -= 1
        })
    }
    
    func slideIn(_ view:UIView)
    {
        let prevRect = view.frame
        
        view.frame = CGRect(x: definitionView.frame.width, y: view.frame.minY, width: view.frame.width, height: view.frame.height)
        view.isHidden = false
        
        animations += 1
        
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            view.frame = prevRect
        }, completion: {b in
            self.animations -= 1
            return
        })
    }
    
    func fadeOut(_ completion: (() -> Void)?, views: UIView...)
    {
        animations += views.count
        
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            for view in views
            {
                view.alpha = 0
            }
        }, completion: {b in
            for view in views
            {
                view.isHidden = true
            }
            
            self.animations -= views.count
            
            completion?()
        })
    }
    
    func fadeIn(_ completion: (() -> Void)?, views: UIView...)
    {
        for view in views
        {
            view.isHidden = false
            view.alpha = 0.1
        }
        
        animations += views.count
        
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
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
