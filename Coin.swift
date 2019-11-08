//
//  Coin.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 7/6/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class Coin: SKSpriteNode {
    var screenSize = UIScreen.main.bounds
    var initialSize = CGSize(width: 26, height: 26)
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named: "Object")
    var value = 1
    
    var coinIconPosition = CGPoint()
    var moveToCoinHudAndFadeOut = SKAction()
    
    var slowDisapear = SKAction()
    
    var isRacingScene = false
    
    init(isRacingScene:Bool) {
        
        let bronzeTexture = textureAtlas.textureNamed("coin-bronze")
        super.init(texture: bronzeTexture, color: .clear, size: initialSize)
        self.name = "coin"
        //self.createPhysicBody()
        self.isRacingScene = isRacingScene
        
        var coinHudXPos:CGFloat = 0
        var coinHudYPos:CGFloat = 0
        
        if isRacingScene { // racing scene is three times bigger than gameScene
            let threeTimeWidth = screenSize.width * 3
            let threeTimeHeight = screenSize.height * 3
            self.screenSize = CGRect(origin: CGPoint.zero, size: CGSize(width: threeTimeWidth, height: threeTimeHeight))
            
            // Get coin icon in hud position
            coinHudXPos = self.screenSize.width/2 - 150 // coin icon is in screenSize.width/2 - 50 and has width/2 = 26/2 = 13
            coinHudYPos = -screenSize.height/2 + 150 // coin icon is in -screenSize.height/2 + 30 and has height/2 = 26/2 = 13
        } else {
            // Get coin icon in hud position
            coinHudXPos = self.screenSize.width/2 - 50 // coin icon is in screenSize.width/2 - 50 and has width/2 = 26/2 = 13
            coinHudYPos = -screenSize.height/2 + 50 // coin icon is in -screenSize.height/2 + 30 and has height/2 = 26/2 = 13
        }
        self.coinIconPosition = CGPoint(x: coinHudXPos, y: coinHudYPos)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawn(parentNode: SKNode, position: CGPoint, completionHandle: () -> Void) {
        parentNode.addChild(self)
        
        if isRacingScene {
            self.setScale(3)
        }
        
        self.position = position
        self.createAnimation()
        disapearAfter(time: 4) // disapear time = this time + slow disapear skaction time
        completionHandle()
    }
    
    func createPhysicBody() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = 0
        self.zPosition = 100
    }
    
    func createAnimation() {
        let moveToCoinHud = SKAction.move(to: self.coinIconPosition, duration: 0.45)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        self.moveToCoinHudAndFadeOut = SKAction.sequence([moveToCoinHud, fadeOut])
        slowDisapear = SKAction.fadeOut(withDuration: 2)
        
        /*if isRacingScene {
            
        } else {
            
        }
        */
    }
    
    func turnToGold() {
        self.texture = textureAtlas.textureNamed("coin-gold")
        self.value = 5
    }
    
    func runCode(delay timeInterval:TimeInterval, _ code:@escaping ()->(Void)) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + timeInterval,
            execute: code
        )
    }
    
    func disapearAfter(time: CGFloat) {
        runCode(delay: TimeInterval(time)) {
            self.run(self.slowDisapear) {
                self.removeFromParent()
            }
        }
    }
    func onTap() { // run animation on tap
        self.run(moveToCoinHudAndFadeOut) {
            self.removeFromParent()
        }
    }

}
