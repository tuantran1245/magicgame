//
//  Crate.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 7/1/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class Crate: SKSpriteNode {
    var initialSize = CGSize(width: 128, height: 128)
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named: "Object")
    
    var isRewardPlayer = false
    var givesHeart = false
    var givesCoin = false
    var brokenWoodCrate = false
    var TNTExploded = false
    
    let giveCoinStatistic:UInt32 = 50 // percents
    
    init() {
        super.init(texture: nil, color: UIColor.clear, size: initialSize)
        self.createPhysicBody()
        self.texture = textureAtlas.textureNamed("wooden_crate.png")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPhysicBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: initialSize)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.crate.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.damagedPlayer.rawValue
    }
    
    func turnToRandomRewardedCrate() {
        self.texture = textureAtlas.textureNamed("crate-power-up")
        self.isRewardPlayer = true
    }
    
    func turnToTNT() {
        self.texture = textureAtlas.textureNamed("TNT_Tile")
        self.TNTExploded = true
    }
    
    // a function for exploding crates
    func broke(racingScene:RacingScene, playerPosition: CGPoint) {
        if (isRewardPlayer) {
            self.randomRewardPlayer()
            if (givesHeart) {
                // If this is a heart crate, award a health point:
                let newHealth = racingScene.player.health + 1
                let maxHealth = racingScene.player.maxHealth
                racingScene.player.health = newHealth > maxHealth ? maxHealth : newHealth
                racingScene.hud.setHealthDisplay(newHealth: racingScene.player.health)
                // Place a heart explotion at this location:
                racingScene.particlePool.placeEmitter(node: self, emitterType: "heart")
            }
            
            if (givesCoin) {
               // let playerPosition = racingScene.player.position
                let coinPositionToSastifyEffects = CGPoint(x: playerPosition.x, y: 0)
                racingScene.particlePool.placeEmitter(node: self, emitterType: "bonus")
                let coin = Coin(isRacingScene: true)
                coin.turnToGold()
                coin.setScale(3)
                coin.spawn(parentNode: racingScene.cam, position: convert(coinPositionToSastifyEffects, to: racingScene.cam)) {
                    coin.onTap()
                    racingScene.player.coinCollected += 1
                    racingScene.hud.setcoinCountDisplay(newCoinCount: racingScene.player.coinCollected)
                } // coin must be a child of camera node because it must always stay in the view
            }
          
        }
        
        if(TNTExploded) {
            racingScene.player.health = 0
            racingScene.particlePool.placeEmitter(node: self, emitterType: "TNT")
            racingScene.player.die()
        }
        else {
            // Do not do anything if crate already exploded:
            if brokenWoodCrate { return }
            brokenWoodCrate = true
            // print("crate exploded")
            // Place a crate explotion at this location:
            racingScene.particlePool.placeEmitter(node: self, emitterType: "crate")
            // Fade out the crate sprite:
            //self.run(SKAction.fadeOut(withDuration: 0.1))
            
            /*// otherwise, reward the player:
            racingScene.player.coinCollected += 1
            racingScene.hud.setScoreCountDisplay(newScoreCount: racingScene.player.coinCollected)
            */
        }
        self.run(SKAction.fadeOut(withDuration: 0.1))

        // prevent additional contact:
        self.physicsBody?.contactTestBitMask = 0
    }
    
    func randomRewardPlayer() {
        let randomNumber = arc4random_uniform(100)
        if randomNumber <= giveCoinStatistic {
            givesCoin = true
        } else {
            givesHeart = true
        }
    }
    
   /* func reset() {
        self.alpha = 1
        self.physicsBody?.contactTestBitMask = PhysicsCategory.crate.rawValue
        exploded = false
    }*/
    
}
