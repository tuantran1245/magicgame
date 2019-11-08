//
//  Level5-intro.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 4/17/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class Level5_Intro: SKScene {
    var viewController : GameViewController!
        override func didMove(to view: SKView) {
        //    var startGameTimer: Timer!
            _ = Timer.scheduledTimer(timeInterval: 9, target: self, selector:  #selector(presentGameScene), userInfo: nil, repeats: false)
            SKTAudio.sharedInstance().playBackgroundMusic("Level5_Background.wav")
            
        }
    @objc func presentGameScene(){
        // gameViewController -> menuScene -> gameScene
        let gameScene = GameScene(size: self.size, chosenLevel: 5 )
        // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
        gameScene.viewController = self.viewController
        // Player touched the start text oe button node:
        self.view?.presentScene(gameScene)
    }

}
