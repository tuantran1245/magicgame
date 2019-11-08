//
//  Arrow.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 9/15/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit
class Arrow:SKSpriteNode {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named: "Projectiles")
    let initialSize = CGSize(width: 43, height: 14)

    init() {
        super.init(texture: nil, color: UIColor.clear, size: initialSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPhysicBody() {
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.initialSize)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.projectiles.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = PhysicsCategory.damagedPlayer.rawValue | PhysicsCategory.player.rawValue
    }
    
    func shoot() {
        let moveToCenter = SKAction.move(to: CGPoint.zero, duration: 0.7)
        let actionDone = SKAction.removeFromParent()
        self.run(SKAction.sequence([moveToCenter, actionDone]))
    }
    
    func spawn(parentNode:SKNode, position:CGPoint) {
        parentNode.addChild(self)
        self.texture = textureAtlas.textureNamed("Arrow.png")
        self.position = position
        self.createPhysicBody()
       /* if position.x > 0 {
            self.xScale = -1
        }*/
        self.rotateArrowToFacePlayer()
    }
    
    func rotateArrowToFacePlayer() {
        let verticalVector = CGVector(dx:0, dy:1)
        let directionVector = CGVector(dx:CGPoint.zero.x - self.position.x, dy: CGPoint.zero.y - self.position.y)
        
        let angle = atan2(directionVector.dy, directionVector.dx) - atan2(verticalVector.dy, verticalVector.dx)
        self.zRotation = angle + CGFloat(.pi*0.5)
        
        /*let DegreesToRadians = CGFloat.pi / 180
        // Calculate the angle using the relative positions of the sprite and destination
        // player is at CGPoint.zero
        let deltaX = self.position.x - CGPoint.zero.x
        let deltaY = self.position.y - CGPoint.zero.y
        let angle = atan2(deltaY, deltaX)
        
        self.zRotation = angle * DegreesToRadians
        */
    }
}

