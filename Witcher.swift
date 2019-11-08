//
//  Witch.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 9/13/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit
class Witcher: SKSpriteNode, Ranger, Creep, Enemy {
    let screenSize = UIScreen.main.bounds
    var textureAtlas:SKTextureAtlas =
        SKTextureAtlas(named:"Witcher")
    var fadeAnimation = SKAction()
    
    var idleAnimation = SKAction()
    var attackAnimation = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    var walkAnimation = SKAction()
    var runAnimation = SKAction()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    
    var moveDuration: Double = 5
    
    var isDisplayed = false
    var isDie = false
    
    var _xScale: CGFloat = 1.0
    
    let coinSpawnRate: UInt32 = 20 // percents
    
    var pBody:SKPhysicsBody!
    
    var shootingPoint = CGPoint()
    
    let attackTime = 7 //seconds
    
    init() {
        super.init(texture: nil, color: UIColor.clear, size: CGSize.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // To check it worked:
        print("Yup, all working")
    }
    
    func spawn(parentNode:SKNode, position: CGPoint,
               size: CGSize = CGSize(width: 74, height: 97), maxGestureNumber: Int, delayTime: Double, isLighting: Bool, moveToPoint: CGPoint, moveDuration: Double, gestureList: String) {
        parentNode.addChild(self)
        self.moveDuration = moveDuration
        
        // createAnimations:
        self.createSound()
        self.createAnimation()
        
        self.name = "Witcher"
        self.size = size
        self.position = position
        self.zPosition = 5
        self.alpha = 0
        self.texture = self.textureAtlas.textureNamed("WITCHER_1_IDLE_000.png")
        
        if position.x > moveToPoint.x {
            self.xScale = -1
            self._xScale = -1 // get scale for global var to use later
            
            self.shootingPoint = CGPoint(x: screenSize.width/4, y: position.y)
        } else {
            self.shootingPoint = CGPoint(x: -screenSize.width/4, y: position.y)
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
            self.run(SKAction.move(to: self.shootingPoint, duration: moveDuration)) {
                self.removeAction(forKey: "run")
                self.castLightingSpell(world: parentNode)
                self.run(self.attackAnimation) {
                    self.run(self.idleAnimation, withKey: "idle")
                    self.repeatAttacking(world: parentNode)
                }
            }
        }
    }
    
    func castLightingSpell(world: SKNode) {
        let player = world.childNode(withName: "player") as! Player
        let specialEffects = SpecialEffects()
        specialEffects.spawn(parentNode: player as SKSpriteNode, type: "lighting")
        player.takeDamage()

    }
    
    func repeatAttacking(world: SKNode) {
        let repeatAttackAction = SKAction.repeatForever(
            SKAction.sequence([SKAction.wait(forDuration: TimeInterval(self.attackTime)),
                               SKAction.run({
                                self.run(self.attackAnimation);
                                self.castLightingSpell(world: world)
                               })]))
        self.run(repeatAttackAction)

    }
    
    func getChildren() -> [SKNode] {
        return self.children
    }
    
    func addGestureImage(gestureNumber: Int) {
        var x: Int = 24 * (gestureNumber - 1) / 2 // gesture image width = 24
        if self._xScale > 0 {
            x = -24 * (gestureNumber - 1) / 2
        }
        
        if gestureNumber == 0 {
            self.addLightningGesture(xPos: x)
        } else {
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
            self.addLightningGesture(xPos: x)
        }
    }
    
    func addGestureBy(string: String) {
        var x: Int = 24 * (string.count - 1) / 2 // gesture image width = 24
        if self._xScale > 0 {
            x = -24 * (string.count - 1) / 2
        }
        print("Witcher gesture string \(string)")
        if string.isEmpty {
            self.addLightningGesture(xPos: x)
        } else {
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
            self.addLightningGesture(xPos: x)
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
    
    func addLightningGesture(xPos: Int) {
        let lightingGesture = GestureImage()
        if self._xScale < 0 {
            lightingGesture.spawnSpecialGesture(parentNode: self, position: CGPoint(x: xPos, y:50), gestureName: "lighting", isFlipHorizontal: true)
        } else {
            lightingGesture.spawnSpecialGesture(parentNode: self, position: CGPoint(x: xPos, y:50), gestureName: "lighting", isFlipHorizontal: false)
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
        
        var idleSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            idleSequence.append(textureAtlas.textureNamed("WITCHER_1_IDLE_00\(index).png"))
        }
        let idleAction = SKAction.animate(with: idleSequence, timePerFrame: 0.1, resize: true, restore: false)
        idleAnimation = SKAction.repeatForever(idleAction)
        
        var walkSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            walkSequence.append(textureAtlas.textureNamed("WITCHER_2_WALK_00\(index).png"))
        }
        let walkAction = SKAction.animate(with: walkSequence, timePerFrame: 0.1, resize: true, restore: false)
        walkAnimation = SKAction.repeatForever(walkAction)
        //self.run(walkAnimation)
        
        var runSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            runSequence.append(textureAtlas.textureNamed("WITCHER_3_RUN_00\(index).png"))
        }
        let runAction = SKAction.animate(with: runSequence, timePerFrame: 0.15, resize: true, restore: false)
        runAnimation = SKAction.repeatForever(runAction)
        self.run(runAnimation, withKey: "run")
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            attackSequence.append(textureAtlas.textureNamed("WITCHER_5_ATTACK_00\(index).png"))
        }
        attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.1, resize: true, restore: true)
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            damageSequence.append(textureAtlas.textureNamed("WITCHER_6_HURT_00\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.1, resize: true, restore: true)
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 0...4 {
            dieSequence.append(textureAtlas.textureNamed("WITCHER_7_DIE_00\(index).png"))
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
        
        self.run(attackAnimation){
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

