//
//  Level5-intro.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 4/17/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class Level6_Intro: SKScene {
    var viewController : GameViewController!
    override func didMove(to view: SKView) {
        self.viewController.renderView.clear()
        SKTAudio.sharedInstance().playBackgroundMusic("victory.wav")
    }
}
