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
    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initDefinition(definition1)
        initDefinition(definition2)
        initDefinition(definition3)
        initDefinition(definition4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDefinition(definition:UIButton)
    {
        definition.titleLabel!.numberOfLines = 3
        definition.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        definition.titleLabel!.textAlignment = NSTextAlignment.Left
        definition.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
}
