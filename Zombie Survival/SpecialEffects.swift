//
//  SpecialEffects.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 4/8/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class SpecialEffects: SKSpriteNode {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Special_Effects.atlas")
    var animation = SKAction()
    
    func spawn(parentNode: SKSpriteNode, type: String /* completion: @escaping () -> ()*/) {
        self.createAnimation(effectName: type)
        let specialEffect = SKSpriteNode()
        parentNode.addChild(specialEffect)
        specialEffect.name = "lighting-effect"
        // set effect anchor point at middle bottom
        //specialEffect.anchorPoint = CGPoint(x: 0.75, y:0.10)
        //specialEffect.position = CGPoint(x: 0, y: 300)
        specialEffect.run(SKAction.move(to: CGPoint(x: 0, y: 100), duration: 0))
        specialEffect.zPosition = 51
        specialEffect.size = CGSize(width: 132, height: 269)
        specialEffect.texture = textureAtlas.textureNamed("lighting_2.png")
        specialEffect.physicsBody = nil
        specialEffect.run(self.animation) {
            specialEffect.removeFromParent()
        }
    }
    
    func createAnimation(effectName: String) {
        switch effectName {
        case "lighting":
            var attackSequence: [SKTexture] = [SKTexture]()
            for index in 1...10 {
                attackSequence.append(textureAtlas.textureNamed("lighting_\(index).png"))
            }
            self.animation = SKAction.animate(with: attackSequence, timePerFrame: 0.2, resize: false, restore: false)
        default:
            print("invalid special effect type, check SpecialEffect.swift")
        }
    }
}
