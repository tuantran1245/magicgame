//
//  BossLv2.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 3/13/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class BossLv2: SKSpriteNode, Boss {

    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"BossLv2.atlas")
    
    var isTurnBack:Bool = false
    var isSpawningEnemy:Bool = true
    var isDie:Bool = false
    
    var attackAnimation = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    var standAnimation = SKAction()
    var flyAnimation = SKAction()
    var spawningEnemyAnimation = SKAction()
    
    let gestureImage = GestureImage()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    
    var moveToCenter = SKAction()
    var moveToCenterDuration: Double = 0
    
    var health: Int = 4
    
    var spawnCount = 0
    
    typealias FinishedAnimation = () -> ()
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 71, height: 76), moveDuration: Double, moveToPoint: CGPoint, gestureList: String) {
        parentNode.addChild(self)
        
        self.name = "boss"
        self.size = size
        self.position = position
        self.texture = textureAtlas.textureNamed("boss_stand_1.png")
        
        // createAnimations:
        self.createAnimation()
        self.createSound()
        self.createPhysicsBody(size: size)
        
        self.moveToCenterDuration = moveDuration
        
        self.run(spawningEnemyAnimation)
    }
    
    func createAnimation() {
        /*let flyUp = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1)
        let flyDown = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1)
        let flySequence = SKAction.sequence([flyUp, flyDown])
        flyAnimation = SKAction.repeatForever(flySequence)
        */
        
        var standSequence: [SKTexture] = [SKTexture]()
        for index in 1...2 {
            standSequence.append(textureAtlas.textureNamed("boss_stand_\(index).png"))
        }
        let standAnimation = SKAction.animate(with: standSequence, timePerFrame: 2.5, resize: true, restore: false)
        let standGroup = SKAction.group([standAnimation, flyAnimation])
        let standAction = SKAction.repeatForever(standGroup)
        self.run(standAction)
        
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 1...8 {
            attackSequence.append(textureAtlas.textureNamed("boss_attack_\(index).png"))
        }
        attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.1, resize: true, restore: true)
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 1...8 {
            damageSequence.append(textureAtlas.textureNamed("boss_hurt_\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.05, resize: true, restore: true)
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 1...20 {
            dieSequence.append(textureAtlas.textureNamed("boss_die_\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.1, resize: true, restore: false)
        
        var spawnSequence: [SKTexture] = [SKTexture]()
        for index in 1...8 {
            spawnSequence.append(textureAtlas.textureNamed("Boss_spawn_enemy_\(index).png"))
        }
        spawningEnemyAnimation = SKAction.animate(with: spawnSequence, timePerFrame: 0.2, resize: true, restore: true)
 
       // var standSequence:[SKAction] = textureAtlas.textureNames("boss_walk_1.png")
       // standAnimation = SKAction.animate(with: [], timePerFrame: )
    }
    
    func createSound() {
        self.dieSound = SKAction.playSoundFileNamed("BossLv2_die", waitForCompletion: false)
        self.attackSound = SKAction.playSoundFileNamed("boss_attack.wav", waitForCompletion: false)
    }
    
    func createPhysicsBody(size: CGSize) {
        // MARK: Physics body
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.boss.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue //| PhysicsCategory.enemy.rawValue
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
        stopMoveToCenter()
        
        if outOfGesture {
            print("move back func called")
            print ("boss LV 2 spawn count: \(spawnCount)")
            //self.addGestureImage(gestureNumber: 5)
            if spawnCount == 0 {
                self.addGestureBy(string: "00200")
            }
            if spawnCount == 2 {
                self.addGestureBy(string: "11311")
                self.moveToCenterDuration -= 2
            }
            if spawnCount == 4 {
                self.addGestureBy(string: "10201")
                self.moveToCenterDuration -= 2
            }
            
            self.moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
            self.run(self.moveToCenter, withKey: "toCenter")
        }
        else{
            self.run(SKAction.move(to: CGPoint(x:300, y:0), duration: 0.5)){
                self.run(self.moveToCenter, withKey: "toCenter")
            }
        }
    }
    
    func stopMoveToCenter() {
        self.removeAction(forKey: "toCenter")
    }
    
    func runSpawnAnimation() {
        self.run(spawningEnemyAnimation)
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


