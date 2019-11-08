//
//  BossLv8.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 10/10/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class BossLv8: SKSpriteNode, Boss {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"BossLv8")
    
    var isTurnBack:Bool = true
    var isDie:Bool = false
    
    var initialPosition = CGPoint()
    
    var attackAnimation = SKAction()
    var damageAnimation = SKAction()
    var idleAnimation = SKAction()
    var walkAnimation = SKAction()
    var runAnimation = SKAction()
    var dieAnimation = SKAction()
    
    let gestureImage = GestureImage()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    
    var moveToCenter = SKAction()
    var moveToCenterDuration: Double = 0
    
    var health: Int = 4
    
    var spawnCount = 0
    
    typealias FinishedAnimation = () -> ()
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 130, height: 109), moveDuration: Double, moveToPoint: CGPoint, gestureList: String) {
        parentNode.addChild(self)
        
        self.name = "boss"
        self.size = size
        self.initialPosition = position
        self.position = initialPosition
        let initialTexture = textureAtlas.textureNamed("_IDLE_000.png")
        self.texture = initialTexture
            
        // createAnimations:
        self.createAnimation()
        self.createSound()
        self.createPhysicsBody(size: size)
        self.addGestureBy(string: gestureList)
        self.xScale = -1
        // MARK: - move enemy to center of screen
        self.moveToCenterDuration = moveDuration
        moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
        self.run(moveToCenter, withKey: "toCenter")
    }
    
    func createAnimation() {
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            attackSequence.append(textureAtlas.textureNamed("_ATTACK_00\(index).png"))
        }
        attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.1, resize: true, restore: true)
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            damageSequence.append(textureAtlas.textureNamed("_HURT_00\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.05, resize: true, restore: true)
        
        var idleSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            idleSequence.append(textureAtlas.textureNamed("_IDLE_00\(index).png"))
        }
        idleAnimation = SKAction.animate(with: idleSequence, timePerFrame: 0.1, resize: true, restore: true)
        
        var walkSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            walkSequence.append(textureAtlas.textureNamed("_WALK_00\(index).png"))
        }
        walkAnimation = SKAction.animate(with: walkSequence, timePerFrame: 0.2, resize: true, restore: true)
        self.run(SKAction.repeatForever(walkAnimation))
        
        var runSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            runSequence.append(textureAtlas.textureNamed("_RUN_00\(index).png"))
        }
        runAnimation = SKAction.animate(with: runSequence, timePerFrame: 0.2, resize: true, restore: true)
        //self.run(SKAction.repeatForever(runAnimation))
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            dieSequence.append(textureAtlas.textureNamed("_DIE_00\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.1, resize: true, restore: false)
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
    
    func stopMoveToCenter() {
        self.removeAction(forKey: "toCenter")
    }
    
    func moveBack(outOfGesture: Bool) {
        if outOfGesture {
            self.run(SKAction.repeatForever(runAnimation))
            //self.removeAction(forKey: "toCenter")
            self.moveToCenterDuration -= 3
            self.moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
            //self.run(moveToCenter, withKey: "toCenter")
            
            if spawnCount == 0 {
                self.addGestureBy(string: "01020202")
            }
            if spawnCount == 1 {
                self.addGestureBy(string: "21032103")
            }
            if spawnCount == 2 {
                self.addGestureBy(string: "330133012233111")
            }
            spawnCount += 1
        }
        stopMoveToCenter()
        self.run(SKAction.move(to: self.initialPosition, duration: 0.5)){
            self.run(self.moveToCenter, withKey: "toCenter")
        }
    }
    
    func addGestureBy(string: String) {
        var x: Int = 24 * (string.count - 1) / 2 // gesture image width = 24
        for char in string {
            let gestureImage = GestureImage()
            gestureImage.spawnByString(parentNode: self, position: CGPoint(x: Int(x), y: 75), index: char, isFlipHorizontal: true)
            x -= 24
        }
    }
    
    
    func updateGesturePosition() {
        let gestureArray: [SKNode] = self.children
        let gestureNumber: Int = gestureArray.count
        var xPos: Int = 24 * (gestureNumber - 1) / 2 // gesture image width = 24
        // add gesture image as children of zombie
        for gesture in gestureArray {
            gesture.position = CGPoint(x: xPos, y: 75)
            xPos -= 24
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


