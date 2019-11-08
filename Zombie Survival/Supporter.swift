//
//  Ghost.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 2/27/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit
class Supporter: SKSpriteNode {
    let screenSize = UIScreen.main.bounds
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"Supporter.atlas")
    var gestureImage = GestureImage()
    var flyAnimation = SKAction()
    var healingSound = SKAction()
    var standAnimation = SKAction()
    var healingAnimationWithSound = SKAction()
  
    func spawn(parentNode:SKNode, position: CGPoint,
               size: CGSize = CGSize(width: 75, height: 75), delayTime: Double) {
        parentNode.addChild(self)
        // create Animations:
        self.createSound()
        self.createAnimation()
        self.name = "healer"
        self.size = size
        self.zPosition = 1
        // set anchor point = top left corner point
        //self.anchorPoint = CGPoint(x: 0, y: 0)
       
        self.run(SKAction.wait(forDuration: delayTime)){
            self.texture = self.textureAtlas.textureNamed("dog_stand_1.png")
            self.addBroomDecorate()
            self.addGestureImage()
            self.flyToSpawnPosition(spawnPosition: position)
        }
    }
    
    func addGestureImage() {
        self.gestureImage.spawnSpecialGesture(parentNode: self, position: CGPoint(x:0, y:50), gestureName: "heart", isFlipHorizontal: false)
    }
    
    func addBroomDecorate() {
        let broom = SKSpriteNode()
        broom.texture = textureAtlas.textureNamed("broom.png")
        broom.position = CGPoint(x:0, y: -35)
        broom.size = CGSize(width: 159, height: 41)
        self.addChild(broom)
    }
    
    func createAnimation() {
        var standSequence: [SKTexture] = [SKTexture]()
        for index in 1...7 {
            standSequence.append(textureAtlas.textureNamed("dog_stand_\(index).png"))
        }
        let standAction = SKAction.animate(with: standSequence, timePerFrame: 0.2, resize: false, restore: false)
        standAnimation = SKAction.repeatForever(standAction)

        // MARK: Create Attack animation
        var healingSequence: [SKTexture] = [SKTexture]()
        for index in 1...7 {
            healingSequence.append(textureAtlas.textureNamed("dog_jump_\(index).png"))
        }
        let healingAnimation = SKAction.animate(with: healingSequence, timePerFrame: 0.1, resize: false, restore: false)
        self.healingAnimationWithSound = SKAction.group([healingAnimation, healingSound])
        
        let flyUp = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1)
        let flyDown = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1)
        let flySequence = SKAction.sequence([flyUp, flyDown])
        flyAnimation = SKAction.repeatForever(flySequence)
    }
    
    func flyToSpawnPosition(spawnPosition: CGPoint) {
        let moveToSpawnPosition = SKAction.move(to: spawnPosition, duration: 1)
        if spawnPosition.x <= 0 {
            self.position = CGPoint(x: -screenSize.midX - 100, y: spawnPosition.y)
            self.run(moveToSpawnPosition) {
                self.run(self.flyAnimation)
            }
        }else {
            // flip this node among x-axis:
            self.xScale = self.xScale * -1
            //self.childNode(withName: "heart")?.xScale *= -1
            self.position = CGPoint(x: screenSize.midX + 100, y: spawnPosition.y)
            self.run(moveToSpawnPosition) {
                self.run(self.flyAnimation)
            }
        }
    }
    
    func createSound() {
        self.healingSound = SKAction.playSoundFileNamed("heart.wav", waitForCompletion: false)
    }
    
    func healing() {
        self.run(self.healingAnimationWithSound) {
            self.fadeOutAndDisapear()
        }
    }
    
    func fadeOutAndDisapear() {
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        self.run(fadeOut) {
            self.removeFromParent()
        }
    }
}
