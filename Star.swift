//
//  Star.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 7/6/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class star: SKSpriteNode {
    var initialSize = CGSize(width: 40, height: 38)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Object")
    var pulseAnimation = SKAction()
    
    init() {
        let starTexture = textureAtlas.textureNamed("star")
        super.init(texture: starTexture, color: .clear, size: initialSize)
        self.createPhysicBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPhysicBody() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        self.physicsBody?.affectedByGravity = false
    }
    
    func crateAnimation() {
        let pulseOutGroup = SKAction.group([
            SKAction.fadeAlpha(to: 0.85, duration: 0.8),
            SKAction.scale(to: 0.6, duration: 0.8),
            SKAction.rotate(byAngle: -0.3, duration: 0.8)
            ])
        let pulseInGroup = SKAction.group([
            SKAction.fadeIn(withDuration: 1.5),
            SKAction.scale(to: 1, duration: 1.5),
            SKAction.rotate(byAngle: 3.5, duration: 1.5)
            ])
        let pulseSequence = SKAction.sequence([pulseOutGroup, pulseInGroup])
        pulseAnimation = SKAction.repeatForever(pulseSequence)
    }
}
