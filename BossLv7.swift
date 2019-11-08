//
//  BossLv7.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 8/26/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//



import SpriteKit

class BossLv7: SKSpriteNode, Boss {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"BossLv7")
    
    var isTurnBack:Bool = true
    var isDie:Bool = false
    
    var attackAnimation = SKAction()
    var damageAnimation = SKAction()
    var standAnimation = SKAction()
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
    
    var initialPosition = CGPoint()
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 134, height: 140), moveDuration: Double, moveToPoint: CGPoint, gestureList: String) {
        parentNode.addChild(self)
        
        self.name = "boss"
        self.size = size
        self.position = position
        self.initialPosition = position
        self.texture = textureAtlas.textureNamed("BOSSLV7_IDLE_000.png")
        self.xScale = -1 // flip textures horizontally
        
        // createAnimations:
        self.createAnimation()
        self.createSound()
        self.createPhysicsBody(size: size)
        self.addGestureBy(string: gestureList)
        
        // MARK: - move enemy to center of screen
        self.moveToCenterDuration = moveDuration
        moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
        
        self.run(moveToCenter, withKey: "toCenter")
 
    }
    
    
    func createAnimation() {
        // MARK: walk animation
        var walkSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            walkSequence.append(textureAtlas.textureNamed("BOSSLV7_WALK_00\(index).png"))
        }
        let walkAction = SKAction.animate(with: walkSequence, timePerFrame: 0.1, resize: true, restore: false)
        walkAnimation = SKAction.repeatForever(walkAction)
        self.run(walkAnimation)
        
        var runSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            runSequence.append(textureAtlas.textureNamed("BOSSLV7_RUN_00\(index).png"))
        }
        let runAction = SKAction.animate(with: runSequence, timePerFrame: 0.1, resize: true, restore: false)
        runAnimation = SKAction.repeatForever(runAction)
        //self.run(runAnimation)
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            attackSequence.append(textureAtlas.textureNamed("BOSSLV7_ATTAK_00\(index).png"))
        }
        attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.05, resize: false, restore: false)
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            damageSequence.append(textureAtlas.textureNamed("BOSSLV7_HURT_00\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.1, resize: false, restore: false)
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            dieSequence.append(textureAtlas.textureNamed("BOSSLV7_DIE_00\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.1, resize: true, restore: false)
    }
    
    func createSound() {
        self.dieSound = SKAction.playSoundFileNamed("BossLv4_die", waitForCompletion: false)
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
    
    func stopMoveToCenter() {
        self.removeAction(forKey: "toCenter")
    }
    
    func moveBack(outOfGesture: Bool) {
        stopMoveToCenter()
        if outOfGesture {
            // Boss run faster each time die
            if spawnCount == 0 {
                self.addGestureBy(string: "0adb0")
                self.moveToCenterDuration -= 2
                self.run(self.runAnimation)
            }
            if spawnCount == 1 {
                self.addGestureBy(string: "421035")
                self.moveToCenterDuration -= 2
            }
            if spawnCount == 2 {
                self.addGestureBy(string: "1gbah0")
                self.moveToCenterDuration -= 2
            }
            spawnCount += 1
        }
        self.run(SKAction.move(to: self.initialPosition, duration: 0.5)){
            self.moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
            self.run(self.moveToCenter, withKey: "toCenter")
        }
    }
    
    func addGestureImage(gestureNumber: Int) {
        var x: Int = 24 * gestureNumber / 2 // gesture image width = 24
        // add gesture image as children of zombie
        for _ in 1...gestureNumber{
            gestureImage.spawnRandom(parentNode: self, position: CGPoint(x: Int(x), y: 60), isFlipHorizontal: true)
            x -= 24
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
        let gestureNumber: Int = self.getGestureNumber()
        var xPos: Int = 24 * (gestureNumber - 1) / 2 // gesture image width = 24
        
        // add gesture image as children of boss
        for gesture in gestureArray {
            gesture.position = CGPoint(x: xPos, y: 75)
            xPos -= 24
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


