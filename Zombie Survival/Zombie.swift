//
//  Zombie.swift
//  Zombie Survive
//
//  Created by Tran Quoc Tuan on 2/14/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class Zombie: SKSpriteNode {
    let screenSize = UIScreen.main.bounds
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"Zombie_3.atlas")
    
    var attackAnimateWithSound = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    
    var moveDuration: Double = 10
    
    var isDisplayed = false
    
    var _xScale: CGFloat = 1.0
    
    func spawn(parentNode:SKNode, position: CGPoint,
               size: CGSize = CGSize(width: 59, height: 75), maxGestureNumber: Int, delayTime: Double, isLighting: Bool, moveToPoint: CGPoint, moveDuration: Double, _xScale: CGFloat, scale: CGFloat, gestureList: String) {
        parentNode.addChild(self)
        self.moveDuration = moveDuration
        
        // createAnimations:
        self.createSound()
        self.createAnimation()
        self.createPhysicsBody(size: size)
        
        self.name = "zombie"
        self.size = size
        self.position = position
        self.zPosition = 5
        self.alpha = 0
        self.texture = self.textureAtlas.textureNamed("Zombie_3_Walking0001.png")
        self.setScale(scale)
        self.xScale = _xScale
        self._xScale = _xScale
        
        if isLighting {
            self.addLightningGesture()
        } else if gestureList.isEmpty { // if there is no gestureList pass by param, add ramdom gesture
            self.addGestureImage(gestureNumber: maxGestureNumber)
        } else {
            self.addGestureBy(string: gestureList)
        }
        
        self.run(SKAction.wait(forDuration: delayTime)){
           
            self.isDisplayed = true
            self.run(SKAction.move(to: moveToPoint, duration: moveDuration))
        }
    }
    
    func addGestureImage(gestureNumber: Int) {
        var x: Int = -24 * (gestureNumber - 1) / 2 // gesture image width = 24
        if self._xScale == -1 {
            x = 24 * (gestureNumber - 1) / 2
        }
        // add gesture image as children of zombie
        for _ in 0..<gestureNumber{
            let gestureImage = GestureImage()
            if self._xScale == 1 {
                gestureImage.spawnRandom(parentNode: self, position: CGPoint(x: Int(x), y: 50), isFlipHorizontal: false)
                x += 24
            } else {
                gestureImage.spawnRandom(parentNode: self, position: CGPoint(x: Int(x), y: 50), isFlipHorizontal: true)
                x -= 24
            }
        }
    }
    
    func addGestureBy(string: String) {
        var x: Int = -24 * (string.count - 1) / 2 // gesture image width = 24
        if self._xScale == -1 {
            x = 24 * (string.count - 1) / 2
        }
        for char in string {
            let gestureImage = GestureImage()
            if self._xScale == 1 {
                gestureImage.spawnByString(parentNode: self, position: CGPoint(x: Int(x), y: 50), index: char, isFlipHorizontal: false)
                x += 24
            } else {
                gestureImage.spawnByString(parentNode: self, position: CGPoint(x: Int(x), y: 50), index: char, isFlipHorizontal: true)
                x -= 24
            }
        }
    }
    
    func addLightningGesture() {
        let lightingGesture = GestureImage()
        if self._xScale == 1 {
            lightingGesture.spawnSpecialGesture(parentNode: self, position: CGPoint(x: 0, y:50), gestureName: "lighting", isFlipHorizontal: false)
        } else {
            lightingGesture.spawnSpecialGesture(parentNode: self, position: CGPoint(x: 0, y:50), gestureName: "lighting", isFlipHorizontal: true)
        }
    }
    
    func updateGesturePosition() {
        let gestureArray: [SKNode] = self.children
        let gestureNumber: Int = self.getGestureNumber()
        var xPos: Int = -24 * (gestureNumber - 1) / 2 // gesture image width = 24
        
        if self._xScale == -1 {
            xPos = 24 * (gestureNumber - 1) / 2
        }
        
        // add gesture image as children of zombie
        for gesture in gestureArray {
            if self._xScale == 1 {
                gesture.position = CGPoint(x: xPos, y: 50)
                xPos += 24
            } else {
                gesture.position = CGPoint(x: xPos, y: 50)
                xPos -= 24
            }
        }
        
        /* for child in self.children {
         print (child.name!)
         }
         */
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
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 1...7 {
            attackSequence.append(textureAtlas.textureNamed("ghost_attack_\(index).png"))
        }
        let attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.1, resize: true, restore: true)
        attackAnimateWithSound = SKAction.group([attackAnimation, attackSound])
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 1...5 {
            damageSequence.append(textureAtlas.textureNamed("ghost_hurt_\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.1, resize: true, restore: true)
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 1...8 {
            dieSequence.append(textureAtlas.textureNamed("ghost_die_\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.1, resize: true, restore: false)
        
        /*  let bounceUp = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1)
         let bounceDown = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1)
         let bounceSequence = SKAction.sequence([bounceUp,bounceDown])
         let bounceReapeat = SKAction.repeatForever(bounceSequence)
         */
    }
    
    func createSound() {
        self.attackSound = SKAction.playSoundFileNamed("ghost_attack.wav", waitForCompletion: false)
    }
    
    func createPhysicsBody(size: CGSize) {
        // MARK: Physics body
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.creep.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
    }
    
    func takeDamage() {
        self.run(damageAnimation)
    }
    
    func die() {
        self.physicsBody = nil
        self.run(dieAnimation) {
            self.removeFromParent()
        }
    }
    
    func attack() {
        self.removeAllActions()
        
        self.run(attackAnimateWithSound){
            self.removeFromParent()
        }
    }
    
    func onTap() {}
}
