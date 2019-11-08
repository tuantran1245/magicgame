//
//  Player.swift
//  Zombie Survive
//
//  Created by Tran Quoc Tuan on 2/14/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode, PlayerProtocol {
    let screenSize = UIScreen.main.bounds
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Player.atlas")
    var hud = HUD()
    // The player will be able to take 5 hits before game over:
    var health:Int = 5 {
        didSet {
            self.hud.setHealthDisplay(newHealth: self.health)
        }
    }
    var isDead = false
    var coinCollected:Int = 0
    var score:Int = 0
    
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    var victoryAnimation = SKAction()
    
    var standAnimation = SKAction()
    var scaredAnimation = SKAction()
    
    var downGestureAnimationWithSound = SKAction()
    var downArrowAnimationWithSound = SKAction()
    var rightGestureAnimationWithSound = SKAction()
    var upArrowAnimationWithSound = SKAction()
    
    var lightingAnimation = SKAction()
    var heartAnimationWithSound = SKAction()
    
    var spellRightSound = SKAction()
    var spellDownSound = SKAction()
    var spellUpArrowSound = SKAction()
    var spellDownArrowSound = SKAction()
    var spellLeftArrowSound = SKAction()
    var spellRighArrowtSound = SKAction()
    var healingSound = SKAction()
    
    var winSound = SKAction()
    var walkSound = SKAction()
    
    var walkInAnimationWithSound = SKAction()
    var walkOutAnimationWithSound = SKAction()
    
    
    func spawn(parentNode: SKNode, position: CGPoint, size: CGSize = CGSize(width: 158, height: 153), hud:HUD, completionHandler: @escaping () -> Void) {
        parentNode.addChild(self)
        let standingTexture = SKTexture(imageNamed: "cat_stand_1.png")
        self.name = "player"
        self.texture = standingTexture
        self.size = size
        self.position = position
        self.zPosition = 2
        self.createPhysicBody()
        self.createSound()
        self.createAnimation()
        self.hud = hud
        completionHandler()
    }
    
    func playWalkInCenterAnimation(completionHandler: @escaping () -> Void) {
        self.run(walkInAnimationWithSound) {
            completionHandler()
        }
    }
    
    func playStandingAnimation(completionHandler: @escaping () -> Void) {
        self.run(standAnimation)
        completionHandler()
    }
    
    func addFlyBroom() {
        let broom = SKSpriteNode()
        broom.texture = textureAtlas.textureNamed("broom.png")
        broom.position = CGPoint(x:0, y: -55)
        broom.size = CGSize(width: 159, height: 41)
        self.addChild(broom)
    }
    
    func playFlyAnimation() {
        let flyUp = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1)
        let flyDown = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1)
        let flySequence = SKAction.sequence([flyUp, flyDown])
        let flyAnimation = SKAction.repeatForever(flySequence)
        let standFlyAnimation = SKAction.group([standAnimation, flyAnimation])
        self.run(standFlyAnimation)
    }

    func scared() {
        self.run(scaredAnimation)
    }
    
    func die() {
        // Remove all animations:
        //self.removeAllActions()
        self.physicsBody = nil
        // Run the die animation:
        self.run(self.dieAnimation) {
            // Alert the GameScene:
            if let gameScene = self.parent?.parent as? GameScene {
                gameScene.gameOver()
            }
        }
    }
    
    func victory(completionHandler: @escaping () -> Void) {
        self.removeAllActions()
        let winAnimationWithSound = SKAction.group([victoryAnimation, winSound])
        self.run(winAnimationWithSound){
            self.run(self.walkOutAnimationWithSound) {
                completionHandler()
            }
        }
    }
    
   /* func playCastSpellSound() {
        self.run(spellSound)
    } */
    
    func takeDamage() {
        self.health -= 1
        if self.health == 0 && !self.isDead {
            self.isDead = true
            // If we are out of health, run the die function:
            die()
        }
        else {
            // Run the take damage animation:
            self.run(self.damageAnimation)
        }
    }
    
    func createAnimation() {
        var standSequence: [SKTexture] = [SKTexture]()
        for index in 2...10 {
            standSequence.append(textureAtlas.textureNamed("cat_stand_\(index).png"))
        }
        let standAction = SKAction.animate(with: standSequence, timePerFrame: 0.2, resize: false, restore: false)
        standAnimation = SKAction.repeatForever(standAction)

        var scaredSequence: [SKTexture] = [SKTexture]()
        for index in 1...3 {
            scaredSequence.append(textureAtlas.textureNamed("cat_scared_\(index).png"))
        }
        scaredAnimation = SKAction.animate(with: scaredSequence, timePerFrame: 0.4, resize: true, restore: true)
        
        var walkSequence: [SKTexture] = [SKTexture]()
        for index in 1...6 {
            walkSequence.append(textureAtlas.textureNamed("cat_walk_\(index).png"))
        }
        let walkAction = SKAction.animate(with: walkSequence, timePerFrame: 1/6, resize: false, restore: false)
        let moveIn = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 1)
        let moveOut = SKAction.move(to: CGPoint(x: screenSize.width/2, y: 0), duration: 1)
        self.walkInAnimationWithSound = SKAction.group([walkAction, moveIn])
        self.walkOutAnimationWithSound = SKAction.group([walkAction, moveOut, walkSound])
        
        var downGestureSequence: [SKTexture] = [SKTexture]()
        // Cast spell down gesture
        for index in 0...5 {
            downGestureSequence.append(textureAtlas.textureNamed("cat_down_gesture_\(index).png"))
        }
        let downGestureAnimation = SKAction.animate(with: downGestureSequence, timePerFrame: 0.1, resize: false, restore: false)
        self.downGestureAnimationWithSound = SKAction.group([downGestureAnimation, spellDownSound ])
        
        var downArrowSequence: [SKTexture] = [SKTexture]()
        // Cast spell down arrow gesture
        for index in 0...5 {
            downArrowSequence.append(textureAtlas.textureNamed("cat_downArrow_\(index).png"))
        }
        let downArrowAnimation = SKAction.animate(with: downArrowSequence, timePerFrame: 0.1, resize: false, restore: false)
        self.downArrowAnimationWithSound = SKAction.group([downArrowAnimation, spellDownArrowSound ])
        
        var upArrowSequence: [SKTexture] = [SKTexture]()
        // Cast spell up arrow gesture
        for index in 0...5 {
            upArrowSequence.append(textureAtlas.textureNamed("cat_upArrow_\(index).png"))
        }
        let upArrowAnimation = SKAction.animate(with: upArrowSequence, timePerFrame: 0.1, resize: false, restore: false)
        self.upArrowAnimationWithSound = SKAction.group([upArrowAnimation, spellUpArrowSound ])

        var rightGestureSequence: [SKTexture] = [SKTexture]()
        // Cast spell right gesture
        for index in 1...5 {
            rightGestureSequence.append(textureAtlas.textureNamed("cat_right_\(index).png"))
        }
        let rightGestureAnimation = SKAction.animate(with: rightGestureSequence, timePerFrame: 0.1, resize: false, restore: false)
        self.rightGestureAnimationWithSound = SKAction.group([rightGestureAnimation, spellRightSound ])
        
        var lightingSequence: [SKTexture] = [SKTexture]()
        // Cast spell lighting gesture
        for index in 1...5 {
            lightingSequence.append(textureAtlas.textureNamed("cat_lighting_\(index).png"))
        }
        lightingAnimation = SKAction.animate(with: lightingSequence, timePerFrame: 0.1, resize: false, restore: false)
        
        var heartSequence: [SKTexture] = [SKTexture]()
        // Cast spell lighting gesture
        for index in 1...5 {
            heartSequence.append(textureAtlas.textureNamed("cat_heart_\(index).png"))
        }
        let heartAnimation = SKAction.animate(with: heartSequence, timePerFrame: 0.1, resize: false, restore: false)
        heartAnimationWithSound = SKAction.group([heartAnimation, healingSound])
        
        var hurtSequence: [SKTexture] = [SKTexture]()
        // Cast spell lighting gesture
        for index in 1...4 {
            hurtSequence.append(textureAtlas.textureNamed("cat_hurt_\(index).png"))
        }
        damageAnimation = SKAction.animate(with: hurtSequence, timePerFrame: 0.1, resize: false, restore: false)
        
        // die
        var dieSequence: [SKTexture] = [SKTexture]()

        for index in 1...16 {
            dieSequence.append(textureAtlas.textureNamed("cat_die_\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.2, resize: false, restore: false)
        
        //victory
        var victorySequence: [SKTexture] = [SKTexture]()
        
        for index in 1...18 {
            victorySequence.append(textureAtlas.textureNamed("cat_victory_\(index).png"))
        }
        victoryAnimation = SKAction.animate(with: victorySequence, timePerFrame: 0.1, resize: true, restore: false)
    }
    
    func createSound() {
        spellRightSound = SKAction.playSoundFileNamed("spellRight.wav", waitForCompletion: false)
        spellDownSound = SKAction.playSoundFileNamed("spellDown.wav", waitForCompletion: false)
        spellUpArrowSound = SKAction.playSoundFileNamed("spellUpArrow.wav", waitForCompletion: false)
        spellDownArrowSound = SKAction.playSoundFileNamed("spellDownArrow.wav", waitForCompletion: false)
        spellLeftArrowSound = SKAction.playSoundFileNamed("spellLeftArrow.wav", waitForCompletion: false)
        spellRighArrowtSound = SKAction.playSoundFileNamed("spellLeftArrow.wav", waitForCompletion: false)
        
        healingSound = SKAction.playSoundFileNamed("spellHealing.wav", waitForCompletion: false)
        winSound = SKAction.playSoundFileNamed("Player_win.wav", waitForCompletion: false)
        walkSound = SKAction.playSoundFileNamed("Player_walk.wav", waitForCompletion: false)
    }
    
    
    func createPhysicBody() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 5)
        //self.physicsBody = SKPhysicsBody(texture:standingTexture , size: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.creep.rawValue | PhysicsCategory.boss.rawValue
    }
    
    func castDownGestureSpell() {
        self.run(downGestureAnimationWithSound)
    }
    
    func castDownArrowSpell() {
        self.run(downArrowAnimationWithSound)
    }
    
    func castUpArrowSpell() {
        self.run(upArrowAnimationWithSound)
    }
    
    func castRightGestureSpell() {
        self.run(rightGestureAnimationWithSound)
    }
    
    func castLightingSpell() {
        self.run(lightingAnimation)
    }
    
    func castHealingSpell() {
        self.run(heartAnimationWithSound)
    }
}

