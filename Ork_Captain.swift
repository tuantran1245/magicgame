//
//  Ork_Captain.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 8/24/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class OrkCaptain: SKSpriteNode, MiniBoss, Enemy {
    var textureAtlas:SKTextureAtlas =
        SKTextureAtlas(named:"OrkCaptain")
    
    var screenSize = UIScreen.main.bounds
    
    var isTurnBack:Bool = true
    var isDie:Bool = false
    
    var isDisplayed: Bool = false
    
    var walkAnimation = SKAction()
    var attackAnimation = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    var runAnimation = SKAction()
    
    let gestureImage = GestureImage()
    
    var dieSound = SKAction()
    var attackSound = SKAction()
    
    var moveToCenter = SKAction()
    var moveToCenterDuration: Double = 0
    
    var moveToPoint = CGPoint.zero
    //var moveBackPoint = CGPoint()
    
    typealias FinishedAnimation = () -> ()
    
    let coinSpawnRate: UInt32 = 20 // percents
    
    var _xScale: CGFloat = 1
    
    var reSpawnCount = 0
    
    var pBody: SKPhysicsBody!
    
    var doubleGestureList: String = "" // truoc dau "|" la gesture list thu nhat, sau dau "|" la gesture list thu 2
    var firstGestureList:String = ""
    var secondGestureList:String = ""
    
    var initialPosition = CGPoint()
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 100, height: 82), maxGestureNumber: Int, delayTime: Double, isLighting: Bool, moveToPoint: CGPoint, moveDuration: Double, doubleGestureList: String) {
        parentNode.addChild(self)
        
        self.doubleGestureList = doubleGestureList
        self.name = "Ork_Captain"
        self.size = size
        self.alpha = 0
        self.position = position
        self.initialPosition = position // get init position to global var
        self.zPosition = 5
        self.texture = textureAtlas.textureNamed("IDLE_000.png")
        self.moveToPoint = moveToPoint
        
        if position.x > moveToPoint.x {
            self.xScale = -1
            self._xScale = -1 // get scale for global var to use later
        }
        
        /*if(position.x >= 0) {
            self.moveBackPoint = CGPoint(x: screenSize.midX - 25, y:position.y)
        } else {
            self.moveBackPoint = CGPoint(x: -screenSize.midX + 25, y:position.y)
        }*/
        
        // createAnimations:
        self.createAnimation()
        self.createSound()
        self.createPhysicsBody(size: size)
        self.run(SKAction.repeatForever(walkAnimation))
        
        self.convertDoubleGestureList()
        self.addGestureBy(string: self.firstGestureList)
        //self.addGestureImage(gestureNumber: maxGestureNumber)
        
        // MARK: - move enemy to center of screen
        self.moveToCenterDuration = moveDuration
        moveToCenter = SKAction.move(to: moveToPoint, duration: self.moveToCenterDuration)
        
        self.run(SKAction.wait(forDuration: delayTime)){
            self.createPhysicsBody(size: size)
            self.alpha = 1
            self.isDisplayed = true
            self.run(self.moveToCenter, withKey: "toCenter")
        }
    }
    
    func convertDoubleGestureList() {
        // Use components() to split the string.
        let parts = self.doubleGestureList.components(separatedBy: "|")
        self.firstGestureList = parts[0]
        self.secondGestureList = parts[1]
    }
    
    func createAnimation() {
        // MARK: walk animation
        var walkSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            walkSequence.append(textureAtlas.textureNamed("CAPTAIN_WALK_00\(index).png"))
        }
        let walkAction = SKAction.animate(with: walkSequence, timePerFrame: 0.1, resize: true, restore: false)
        walkAnimation = SKAction.repeatForever(walkAction)
        self.run(walkAnimation)
        
        var runSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            runSequence.append(textureAtlas.textureNamed("CAPTAIN_RUN_00\(index).png"))
        }
        let runAction = SKAction.animate(with: runSequence, timePerFrame: 0.1, resize: true, restore: false)
        runAnimation = SKAction.repeatForever(runAction)
        //self.run(runAnimation)
        
        // MARK: Create Attack animation
        var attackSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            attackSequence.append(textureAtlas.textureNamed("CAPTAIN_ATTAK_00\(index).png"))
        }
        attackAnimation = SKAction.animate(with: attackSequence, timePerFrame: 0.05, resize: false, restore: false)
        
        var damageSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
        damageSequence.append(textureAtlas.textureNamed("CAPTAIN_HURT_00\(index).png"))
        }
        damageAnimation = SKAction.animate(with: damageSequence, timePerFrame: 0.1, resize: false, restore: false)
        
        var dieSequence: [SKTexture] = [SKTexture]()
        for index in 0...6 {
            dieSequence.append(textureAtlas.textureNamed("CAPTAIN_DIE_00\(index).png"))
        }
        dieAnimation = SKAction.animate(with: dieSequence, timePerFrame: 0.1, resize: true, restore: false)
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
        self.physicsBody?.categoryBitMask = PhysicsCategory.miniBoss.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        self.physicsBody?.collisionBitMask = 0 // same as ghost to pass through each other
        self.pBody = self.physicsBody
    }
    
    func die() {
        self.isDie = true
        self.physicsBody = nil
        self.texture = nil
        // closure passed as parameter
        self.removeAllActions()
        let dieAnimateWithSound = SKAction.group([dieAnimation, dieSound])
        // remove node after run block completion
        self.run(dieAnimateWithSound){
            self.transformToCoin()
        }
    }
    
    func moveBack() {
        self.removeAction(forKey: "toCenter")
        self.run(SKAction.move(to: self.initialPosition, duration: 0.5)){ // Move back to initial position
            self.addGestureBy(string: self.secondGestureList)
            self.moveToCenterDuration -= 2 // run twice times faster after moved back
            self.reSpawnCount += 1
            self.run(self.runAnimation)
            self.moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.moveToCenterDuration)
            self.run(self.moveToCenter)
        }
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
    
    func attack() {
        let attackAnimationWithSound = SKAction.group([attackAnimation, attackSound])
        self.removeAllActions()
        self.run(attackAnimationWithSound){
            self.removeFromParent()
        }
    }
    
    func takeDamage() {
        self.run(damageAnimation) {
            self.updateGesturePosition()
        }
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

    func addLightningGesture() {
        
    }
}

