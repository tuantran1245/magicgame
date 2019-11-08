//
//  Level1_Intro.swift
//  Magic cat academy
//
//  Created by Tran Quoc Tuan on 4/26/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class Level1_Intro: SKScene {
    var viewController : GameViewController!
    let viewBounds = UIScreen.main.bounds
    override func didMove(to view: SKView) {
        
        
       // var startGameTimer: Timer!
        _ = Timer.scheduledTimer(timeInterval: 16.5, target: self, selector:  #selector(presentGameScene), userInfo: nil, repeats: false)
        SKTAudio.sharedInstance().playBackgroundMusic("level1_intro.mp3")
        
        let hud = HUD()
        self.addChild(hud)
        hud.showSkipButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*let touch = touches.first
        let location = touch!.location(in: self)
        let nodeTouched = atPoint(location)
        */
        self.presentGameScene()
       /* if nodeTouched.name == "skipBtn" {
            self.presentGameScene()
        }*/
    }
    
    @objc func presentGameScene(){
            // gameViewController -> menuScene -> gameScene
            let gameScene = GameScene(size: self.size, chosenLevel: 1 )
            // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
            gameScene.viewController = self.viewController
            // Player touched the start text oe button node:
            self.view?.presentScene(gameScene)
    }
    
}
