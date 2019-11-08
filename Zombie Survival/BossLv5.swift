//
//  BossLv4.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 3/18/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class BossLv5: SKSpriteNode, Boss {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"BossLv5.atlas")
    
    var isSpawningEnemy:Bool = false
    var isTurnBack:Bool = false
    var isDie:Bool = false
    
    var attackAnimation = SKAction()
    var damageAnimation = SKAction()
    var standAnimation = SKAction()
    var moveAnimation = SKAction()
    var dieAnimation = SKAction()
    var laughAnimationWithSound = SKAction()
    
    let gestureImage = GestureImage()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    var laughSound = SKAction()
    
    var moveToCenter = SKAction()
    var moveToCenterDuration: Double = 0
    
    var health: Int = 4
    
    var moveToPoint = CGPoint()
    
    var spawnCount = 0
    
    typealias FinishedAnimation = () -> ()
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 410, height: 267), moveDuration: Double, moveToPoint: CGPoint, gestureList: String) {
        parentNode.addChild(self)
        self.moveToCenterDuration = moveDuration
        self.moveToPoint = moveToPoint // move destination
        self.name = "boss"
        self.anchorPoint = CGPoint(x: 0.25, y: 0.5)
        self.size = size
        self.position = position
        self.texture = textureAtlas.textureNamed("boss_stand_1.png")
        
        self.createSound()
        // createAnimations:
        self.createAnimation()
    //  self.createPhysicsBody(size: size)
        self.run(laughAnimationWithSound){
            self.run(SKAction.repeatForever(self.standAnimation))
        }
    }
    
    
    func moveToCenterOfScene() {
       self.run(moveToCenter, withKey: "toCenter")
    }
    
    func createAnimation() {
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 1...21 {
            attackSequence.append(textureAtlas.textureNamed("boss_attack_\(index).png"))
        }
        attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.05, resize: false, restore: false)
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 1...7 {
            damageSequence.append(textureAtlas.textureNamed("boss_hurt_\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.2, resize: false, restore: true)
        
        var standSequence: [SKTexture] = [SKTexture]()
        for index in 1...7 {
            standSequence.append(textureAtlas.textureNamed("boss_stand_\(index).png"))
        }
        standAnimation = SKAction.animate(with: standSequence, timePerFrame: 0.1, resize: true, restore: false)
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 1...8 {
            dieSequence.append(textureAtlas.textureNamed("boss_die_\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.15, resize: true, restore: false)
        
        var laughSequence: [SKTexture] = [SKTexture]()
        for index in 1...12 {
            laughSequence.append(textureAtlas.textureNamed("Boss_laugh_\(index).png"))
        }
        let laughAnimation = SKAction.animate(with: laughSequence, timePerFrame: 0.1, resize: true, restore: false)
        self.laughAnimationWithSound = SKAction.group([laughSound, laughAnimation])
        
        // MARK: - move enemy to center of screen
        moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
    }
    
    func createSound() {
        self.dieSound = SKAction.playSoundFileNamed("BossLv5_die", waitForCompletion: false)
        self.attackSound = SKAction.playSoundFileNamed("BossLv5_attack.wav", waitForCompletion: false)
        self.laughSound = SKAction.playSoundFileNamed("BossLv5_laugh.wav", waitForCompletion: false)
    }
    
    func createPhysicsBody(size: CGSize) {
        // MARK: Physics body
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.boss.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        self.physicsBody?.collisionBitMask = 0 // same as ghost to pass through each other
    }
    
    func die(completionHandler: @escaping FinishedAnimation) {
        self.isDie = true
        // closure passed as parameter
        self.removeAllActions()
        let dieAnimateWithSound = SKAction.group([dieAnimation, dieSound])
        // remove node after run block completion
        self.run(dieAnimateWithSound){
            completionHandler()
        }
    }
    
    func removeBossNode() {
        self.removeFromParent()
    }
    
    func moveBack(outOfGesture: Bool) {
        if outOfGesture {
            if spawnCount == 0 {
                self.addGestureBy(string: "01020202")
            }
            if spawnCount == 2 {
                self.addGestureBy(string: "21032103")
            }
            if spawnCount == 4 {
                self.addGestureBy(string: "330133012233111")
            }
        }
        self.run(SKAction.move(to: CGPoint(x:26, y:-54), duration: 0.5))
    }
    
    func addGestureImage(gestureNumber: Int) {
        var x: Int = -24 * gestureNumber / 2 // gesture image width = 24
        // add gesture image as children of zombie
        for _ in 1...gestureNumber{
            gestureImage.spawnRandom(parentNode: self, position: CGPoint(x: Int(x), y: 160), isFlipHorizontal: false)
            x += 24
        }
        self.addLightningGesture(xPos: x)
    }
    
    func addGestureBy(string: String) {
        var x: Int = -24 * (string.count - 1) / 2 // gesture image width = 24
        for char in string {
            let gestureImage = GestureImage()
            gestureImage.spawnByString(parentNode: self, position: CGPoint(x: Int(x), y: 160), index: char, isFlipHorizontal: false)
            x += 24
        }
        self.addLightningGesture(xPos: 1)
    }
    
    func addLightningGesture(xPos: Int ) {
        let lightingGesture = GestureImage()
        lightingGesture.spawnSpecialGesture(parentNode: self, position: CGPoint(x: xPos, y:160), gestureName: "lighting", isFlipHorizontal: false)
    }

    
    func updateGesturePosition() {
        let gestureArray: [SKNode] = self.children
        let gestureNumber: Int = gestureArray.count
        var xPos: Int = -24 * (gestureNumber - 1) / 2 // gesture image width = 24
        // add gesture image as children of zombie
        for gesture in gestureArray {
            gesture.position = CGPoint(x: xPos, y:  160)
            xPos += 24
        }
    }
    
    func getGestureNumber() -> Int{
        var gestureNumber = 0
        for child in self.children {
            //print(child.name!)
            if child is GestureImage{
                gestureNumber += 1
            }
        }
        return gestureNumber
    }
    
    func attack(completionHandler: @escaping () -> Void) {
        let moveToPlayer = SKAction.move(to: moveToPoint, duration: 1)
        let attackAnimationWithSound = SKAction.group([moveToPlayer, attackAnimation, attackSound])
        self.run(attackAnimationWithSound) {
            self.moveBack(outOfGesture: false)
            completionHandler()
        }
    }
    
    func takeDamage() {
        self.run(damageAnimation)
    }
    
    func getChildren() -> [SKNode] {
        return self.children
    }
}


