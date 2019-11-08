//
//  Boss.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 3/8/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class BossLv1: SKSpriteNode,Boss {
    var textureAtlas:SKTextureAtlas =
        SKTextureAtlas(named:"BossLv1.atlas")
    
    var screenSize = UIScreen.main.bounds
    
    var isTurnBack:Bool = true
    var isDie:Bool = false
    
    var walkAnimation = SKAction()
    var fadeAnimation = SKAction()
    var attackAnimation = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    
    let gestureImage = GestureImage()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    
    var moveToCenter = SKAction()
    var moveToCenterDuration: Double = 0
    
    typealias FinishedAnimation = () -> ()
    
    var health: Int = 3
    
    var spawnCount = 0
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 68, height: 103), moveDuration: Double, moveToPoint: CGPoint, gestureList: String) {
        parentNode.addChild(self)
        
        self.name = "boss"
        self.size = size
        self.position = position
        self.texture = textureAtlas.textureNamed("boss_walk_1.png")
        
        // createAnimations:
        self.createAnimation()
        self.createSound()
        self.createPhysicsBody(size: size)
        self.run(SKAction.repeatForever(walkAnimation))
        self.addGestureBy(string: gestureList)
        //self.addGestureImage(gestureNumber: maxGestureNumber)
        
        // MARK: - move enemy to center of screen
        self.moveToCenterDuration = moveDuration
        moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
        self.run(moveToCenter, withKey: "toCenter")
    }
    
    func createAnimation() {
       /* // Create a fade out action group:
        // The ghost becomes smaller and more transparent.
        let fadeOutGroup = SKAction.group([
            SKAction.fadeAlpha(to: 0.3, duration: 2),
            SKAction.scale(to: 0.8, duration: 2)
            ]);
        // Create a fade in action group:
        // The ghost returns to full size and transparency.
        let fadeInGroup = SKAction.group([
            SKAction.fadeAlpha(to: 0.8, duration: 2),
            SKAction.scale(to: 1, duration: 2)
            ]);
        // Package the groups into a sequence, then a
        // repeatActionForever action:
        let fadeSequence = SKAction.sequence([fadeOutGroup,
                                              fadeInGroup])
        fadeAnimation = SKAction.repeatForever(fadeSequence)
        self.run(fadeAnimation)
        */
        
        // Start the ghost semi-transparent:
        self.alpha = 0.8;
        
        // MARK: walk animation
        var walkSequence: [SKTexture] = [SKTexture]()
        for index in 1...10 {
            walkSequence.append(textureAtlas.textureNamed("boss_walk_\(index).png"))
        }
        
        let walkAction = SKAction.animate(with: walkSequence, timePerFrame: 0.2, resize: true, restore: false)
        walkAnimation = SKAction.repeatForever(walkAction)
        self.run(walkAnimation)
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 3...4 {
            attackSequence.append(textureAtlas.textureNamed("boss_attack_\(index).png"))
        }
        attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.1, resize: false, restore: false)
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 1...5 {
            damageSequence.append(textureAtlas.textureNamed("boss_damage_\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.03, resize: false, restore: false)
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 1...13 {
            dieSequence.append(textureAtlas.textureNamed("boss_die_\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.2, resize: true, restore: false)
    }
    
    func createSound() {
        self.dieSound = SKAction.playSoundFileNamed("BossLv1_die.wav", waitForCompletion: false)
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
    
    func moveBack(outOfGesture: Bool) {
        self.removeAction(forKey: "toCenter")
        self.run(SKAction.move(to: CGPoint(x: screenSize.midX - 25, y:0), duration: 0.5)){
            // Boss run faster each time die
            if outOfGesture {
                if self.spawnCount == 0{
                    self.addGestureBy(string: "30203020")
                }
                if self.spawnCount == 1{
                    self.addGestureBy(string: "101001")
                }
                self.moveToCenterDuration /= 2
                //self.addGestureImage(gestureNumber: 8)
                self.spawnCount += 1
            }
            self.moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
            self.run(self.moveToCenter)
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
        self.run(attackAnimationWithSound)
        completionHandler()
        
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

