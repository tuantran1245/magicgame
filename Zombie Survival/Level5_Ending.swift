//
//  Level5-intro.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 4/17/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class Level5_Ending: SKScene {
    var viewController : GameViewController!
    override func didMove(to view: SKView) {
        self.viewController.renderView.clear()
        _ = Timer.scheduledTimer(timeInterval: 18.41, target: self, selector:  #selector(presentNextLvlGameScene), userInfo: nil, repeats: false)

        SKTAudio.sharedInstance().playBackgroundMusic("victory.wav")
    }
    
    @objc func presentNextLvlGameScene(){
        // gameViewController -> menuScene -> gameScene
        let racingScene = RacingScene(fileNamed: "RacingScene")
        racingScene?.scaleMode = .aspectFill
        // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
        racingScene?.viewController = self.viewController
        // Player touched the start text oe button node:
        self.view?.presentScene(racingScene)
    }

}
