//
//  BossLv3.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 3/16/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class BossLv3: SKSpriteNode, Boss {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"BossLv3.atlas")
    
    var isTurnBack:Bool = true
    var isDie:Bool = false
    
    var attackAnimation = SKAction()
    var damageAnimation = SKAction()
    var standAnimation = SKAction()
    var moveAnimation = SKAction()
    var dieAnimation = SKAction()
    
    let gestureImage = GestureImage()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    
    var moveToCenter = SKAction()
    var moveToCenterDuration: Double = 0
    
    var health: Int = 5
    
    var spawnCount = 0
    
    typealias FinishedAnimation = () -> ()
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 130, height: 109), moveDuration: Double, moveToPoint: CGPoint, gestureList: String) {
        parentNode.addChild(self)
        
        self.name = "boss"
        self.size = size
        self.position = position
        self.texture = textureAtlas.textureNamed("boss_stand_1.png")
        
        // createAnimations:
        self.createAnimation()
        self.createSound()
        self.createPhysicsBody(size: size)
        self.run(SKAction.repeatForever(standAnimation))
       // self.addGestureImage(gestureNumber: maxGestureNumber)
        self.addGestureBy(string: gestureList)
        
        // MARK: - move enemy to center of screen
        self.moveToCenterDuration = moveDuration
        moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
        self.run(moveToCenter, withKey: "toCenter")
    }
    
    func createAnimation() {
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 1...13 {
            attackSequence.append(textureAtlas.textureNamed("boss_attack_\(index).png"))
        }
        attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.1, resize: true, restore: true)
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 1...7 {
            damageSequence.append(textureAtlas.textureNamed("boss_hurt_\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.05, resize: true, restore: true)
        
        var standSequence: [SKTexture] = [SKTexture]()
        for index in 1...12 {
            standSequence.append(textureAtlas.textureNamed("boss_stand_\(index).png"))
        }
        standAnimation = SKAction.animate(with: standSequence, timePerFrame: 0.1, resize: true, restore: true)
        
        var moveSequence: [SKTexture] = [SKTexture]()
        for index in 2...7 {
            moveSequence.append(textureAtlas.textureNamed("boss_move_\(index).png"))
        }
        moveAnimation = SKAction.animate(with: moveSequence, timePerFrame: 0.2, resize: true, restore: true)
        self.run(SKAction.repeatForever(moveAnimation))
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 1...10 {
            dieSequence.append(textureAtlas.textureNamed("boss_die_\(index).png"))
        }
        let dieAction = SKAction.animate(with: dieSequence, timePerFrame: 0.1, resize: true, restore: true)
        dieAnimation = SKAction.sequence([attackAnimation, dieAction])
        
    }
    
    func createSound() {
        self.dieSound = SKAction.playSoundFileNamed("BossLv3_die", waitForCompletion: false)
        self.attackSound = SKAction.playSoundFileNamed("boss_attack.wav", waitForCompletion: false)
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
        self.physicsBody = nil
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
        self.removeAction(forKey: "toCenter")
        self.run(SKAction.move(to: CGPoint(x:230, y:-100), duration: 0.5)){
            // Boss run faster each time die
            //self.moveToCenterDuration -= 1
            self.run(self.moveToCenter)
        }
        if outOfGesture {
            //self.addGestureImage(gestureNumber: 3)
            if spawnCount == 0 {
                self.addGestureBy(string: "310")
            }
            if spawnCount == 1 {
                self.addGestureBy(string: "023")
            }
            if spawnCount == 2 {
                self.addGestureBy(string: "012")
            }
            if spawnCount == 3 {
                self.addGestureBy(string: "121")
            }
            spawnCount += 1
        }
    }
    
    func addGestureImage(gestureNumber: Int) {
        var x: Int = -24 * gestureNumber / 2 // gesture image width = 24
        // add gesture image as children of zombie
        for _ in 1...gestureNumber{
            gestureImage.spawnRandom(parentNode: self, position: CGPoint(x: Int(x), y: 60), isFlipHorizontal: false)
            x += 24
        }
    }
    
    
    func addGestureBy(string: String) {
        var x: Int = -24 * (string.count - 1) / 2 // gesture image width = 24
        for char in string {
            let gestureImage = GestureImage()
            gestureImage.spawnByString(parentNode: self, position: CGPoint(x: Int(x), y: 50), index: char, isFlipHorizontal: false)
            x += 24
        }
    }

    
    func updateGesturePosition() {
        let gestureArray: [SKNode] = self.children
        let gestureNumber: Int = gestureArray.count
        var xPos: Int = -24 * (gestureNumber - 1) / 2 // gesture image width = 24
        // add gesture image as children of zombie
        for gesture in gestureArray {
            gesture.position = CGPoint(x: xPos, y: 50)
            xPos += 24
        }
    }
    
    func attack(completionHandler: @escaping () -> Void) {
        let attackAnimationWithSound = SKAction.group([attackAnimation, attackSound])
        self.run(attackAnimationWithSound) {
            completionHandler()
        }
    }
    
    func takeDamage() {
        self.run(damageAnimation)
    }
    
    
    func getChildren() -> [SKNode] {
        return self.children
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
}


