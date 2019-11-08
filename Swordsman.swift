//
//  Swordsman.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 9/13/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit
class Swordsman: SKSpriteNode, Creep, Enemy {
    let screenSize = UIScreen.main.bounds
    var textureAtlas:SKTextureAtlas =
        SKTextureAtlas(named:"Swordsman")
    var fadeAnimation = SKAction()
    
    var attackAnimateWithSound = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    var walkAnimation = SKAction()
    var runAnimation = SKAction()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    
    var moveDuration: Double = 10
    
    var isDisplayed = false
    var isDie = false
    
    var _xScale: CGFloat = 1.0
    
    let coinSpawnRate: UInt32 = 20 // percents
    
    var pBody:SKPhysicsBody!
    
    func spawn(parentNode:SKNode, position: CGPoint,
               size: CGSize = CGSize(width: 96, height: 86), maxGestureNumber: Int, delayTime: Double, isLighting: Bool, moveToPoint: CGPoint, moveDuration: Double, gestureList: String) {
        parentNode.addChild(self)
        self.moveDuration = moveDuration
        
        // createAnimations:
        self.createSound()
        self.createAnimation()
        
        self.name = "Swordsman"
        self.size = size
        self.position = position
        self.zPosition = 5
        self.alpha = 0
        self.texture = self.textureAtlas.textureNamed("1 IDLE_000.png")
        
        if position.x > moveToPoint.x {
            self.xScale = -1
            self._xScale = -1 // get scale for global var to use later
        }
        
        if isLighting {
            self.addLightningGesture()
        } else if gestureList.isEmpty { // if there is no gestureList pass by param, add ramdom gesture
            //print("Gesture list is empty, spawn gesture by Random function")
            self.addGestureImage(gestureNumber: maxGestureNumber)
        } else {
            self.addGestureBy(string: gestureList)
        }
        
        self.run(SKAction.wait(forDuration: delayTime)){
            self.createPhysicsBody(size: size)
            self.run(self.fadeAnimation)
            self.isDisplayed = true
            self.run(SKAction.move(to: moveToPoint, duration: moveDuration))
        }
    }
    
    func getChildren() -> [SKNode] {
        return self.children
    }
    
    func addGestureImage(gestureNumber: Int) {
        var x: Int = 24 * (gestureNumber - 1) / 2 // gesture image width = 24
        if self._xScale > 0 {
            x = -24 * (gestureNumber - 1) / 2
        }
        // add gesture image as children of zombie
        for _ in 0..<gestureNumber{
            let gestureImage = GestureImage()
            if self._xScale < 0 {
                gestureImage.spawnRandom(parentNode: self, position: CGPoint(x: Int(x), y: 50), isFlipHorizontal: true)
                x -= 24
            } else {
                gestureImage.spawnRandom(parentNode: self, position: CGPoint(x: Int(x), y: 50), isFlipHorizontal: false)
                x += 24
            }
        }
    }
    
    func addGestureBy(string: String) {
        var x: Int = 24 * (string.count - 1) / 2 // gesture image width = 24
        if self._xScale > 0 {
            x = -24 * (string.count - 1) / 2
        }
        for char in string {
            let gestureImage = GestureImage()
            if self._xScale < 0 {
                gestureImage.spawnByString(parentNode: self, position: CGPoint(x: Int(x), y: 50), index: char, isFlipHorizontal: true)
                x -= 24
            } else {
                gestureImage.spawnByString(parentNode: self, position: CGPoint(x: Int(x), y: 50), index: char, isFlipHorizontal: false)
                x += 24
            }
        }
    }
    
    func addLightningGesture() {
        let lightingGesture = GestureImage()
        if self._xScale < 0 {
            lightingGesture.spawnSpecialGesture(parentNode: self, position: CGPoint(x: 0, y:50), gestureName: "lighting", isFlipHorizontal: true)
        } else {
            lightingGesture.spawnSpecialGesture(parentNode: self, position: CGPoint(x: 0, y:50), gestureName: "lighting", isFlipHorizontal: false)
        }
    }
    
    func updateGesturePosition() {
        let gestureArray: [SKNode] = self.children
        let gestureNumber: Int = self.getGestureNumber()
        var xPos: Int = 24 * (gestureNumber - 1) / 2 // gesture image width = 24
        
        if self._xScale > 0 {
            xPos = -24 * (gestureNumber - 1) / 2
        }
        
        // add gesture image as children of zombie
        for gesture in gestureArray {
            if self._xScale < 0 {
                gesture.position = CGPoint(x: xPos, y: 50)
                xPos -= 24
            } else {
                gesture.position = CGPoint(x: xPos, y: 50)
                xPos += 24
            }
        }
    }
    
    func getGestureNumber() -> Int{
        var gestureNumber = 0
        for child in self.children {
            if child is GestureImage{
                gestureNumber += 1
            }
        }
        return gestureNumber
    }
    
    func createAnimation() {
        self.fadeAnimation = SKAction.fadeAlpha(to: 1, duration: 1)
        
        var walkSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            walkSequence.append(textureAtlas.textureNamed("2 WALK_00\(index).png"))
        }
        let walkAction = SKAction.animate(with: walkSequence, timePerFrame: 0.15, resize: true, restore: false)
        walkAnimation = SKAction.repeatForever(walkAction)
        //self.run(walkAnimation)
        
        var runSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            runSequence.append(textureAtlas.textureNamed("3 RUN_00\(index).png"))
        }
        let runAction = SKAction.animate(with: runSequence, timePerFrame: 0.15, resize: true, restore: false)
        runAnimation = SKAction.repeatForever(runAction)
        self.run(runAnimation)
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            attackSequence.append(textureAtlas.textureNamed("5 ATTACK_00\(index).png"))
        }
        let attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.15, resize: true, restore: true)
        attackAnimateWithSound = SKAction.group([attackAnimation, attackSound])
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            damageSequence.append(textureAtlas.textureNamed("7 HURT_00\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.15, resize: true, restore: true)
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            dieSequence.append(textureAtlas.textureNamed("6 DIE_00\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.1, resize: true, restore: false)
    }
    
    func createSound() {
        self.attackSound = SKAction.playSoundFileNamed("ghost_attack.wav", waitForCompletion: false)
    }
    
    func createPhysicsBody(size: CGSize) {
        // MARK: Physics body
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.creep.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue //| PhysicsCategory.boss.rawValue
        self.physicsBody?.collisionBitMask = 0 // set this same as boss
    }
    
    func takeDamage() {
        self.run(damageAnimation) {
            self.updateGesturePosition()
        }
    }
    
    func die() {
        self.isDie = true
        self.physicsBody = nil
        self.texture = nil
        self.run(dieAnimation) {
            self.transformToCoin()
            //self.removeFromParent()
        }
    }
    
    func attack() {
        self.removeAllActions()
        
        self.run(attackAnimateWithSound){
            self.removeFromParent()
        }
    }
    
    func transformToCoin () {
        let currentGhostPosition = self.position
        let world = self.parent!
        let randomNuber = arc4random_uniform(100)
        if randomNuber <= self.coinSpawnRate {
            //print ("Ghost parent node: \(self.parent?.name)")
            let coin = Coin(isRacingScene: false)
            coin.turnToGold()
            coin.spawn(parentNode: world, position: currentGhostPosition){
                self.removeFromParent()
            }
        } else {
            self.removeFromParent()
        }
    }
}

