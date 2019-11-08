//
//  RacingPlayer.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 6/27/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class RacingPlayer: SKSpriteNode, PlayerProtocol {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"RacingScene.atlas")
    var health:Int = 5
    var maxHealth:Int = 5
    
    var invulnerable = false
    var damaged = false
    var forwardVelocity:CGFloat = 200
    var bodyTexture = SKTexture()
    
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    
    var score:Int = 0
    var coinCollected:Int = 0
    
    var isDead = false
    
    
    func spawn(parentNode: SKNode, position: CGPoint, size: CGSize = CGSize(width: 96, height: 159), completionHandler: @escaping () -> Void) {
        parentNode.addChild(self)
        self.bodyTexture = textureAtlas.textureNamed("cat_ride_bloom.png")
        self.texture = bodyTexture
        self.position = position
        self.size = size
        self.zPosition = 2
        self.createPhysicBody()
    }
    
    func createPhysicBody() {
        self.physicsBody = SKPhysicsBody(texture: bodyTexture, size: CGSize(width: 96, height: 159))
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.isDynamic = true
        self.physicsBody!.affectedByGravity = false
        
        //self.physicsBody?.linearDamping = 0.2
        self.physicsBody?.mass = 4
        
        self.physicsBody!.categoryBitMask = PhysicsCategory.player.rawValue
        self.physicsBody!.contactTestBitMask = PhysicsCategory.crate.rawValue | PhysicsCategory.powerUp.rawValue
        self.physicsBody!.collisionBitMask = PhysicsCategory.creep.rawValue

    }
    func createSound() {
        
    }
    func createAnimation() {
        let damageStart = SKAction.run {
            self.physicsBody?.categoryBitMask = PhysicsCategory.damagedPlayer.rawValue
        }
        let slowFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.35),
            SKAction.fadeAlpha(to: 0.7, duration: 0.35)
            ])
        let fastFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 0.7, duration: 0.2)
            ])
        let fadeOutAndIn = SKAction.sequence([
            SKAction.repeat(slowFade, count: 2),
            SKAction.repeat(fastFade, count: 5),
            SKAction.fadeAlpha(to: 1, duration: 0.15)
            ])
        
        let damageEnd = SKAction.run {
            self.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
            self.damaged = false
        }
        self.damageAnimation = SKAction.sequence([
            damageStart,
            fadeOutAndIn,
            damageEnd
            ])
    }
    
    func takeDamage() {
        if self.invulnerable || self.damaged {
            return
        }
        //self.damaged = true
        print("Take Damage")
        self.health -= 1
        if self.health == 0 {
            die()
        }
        
    }
    func die() {
        self.alpha = 1
        self.removeAllActions()
        self.run(dieAnimation)
        self.forwardVelocity = 0
        if let racingScene = self.parent?.parent as? RacingScene {
            racingScene.gameOver()
        }
    }

}
