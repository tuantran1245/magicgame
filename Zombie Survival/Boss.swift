//
//  GameSprite.swift
//  Zombie Survive
//
//  Created by Tran Quoc Tuan on 2/14/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

protocol Boss {
    var textureAtlas: SKTextureAtlas {get set}
    var isTurnBack:Bool {get set}
    var isDie:Bool {get set}
    var health:Int {get set}
    
    typealias FinishedAnimation = () -> ()
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize, moveDuration: Double, moveToPoint: CGPoint, gestureList: String)
    func moveBack(outOfGesture: Bool)
    func attack(completionHandler: @escaping () -> Void)
    func takeDamage()
    func getChildren() -> [SKNode]
    func getGestureNumber() -> Int
    func updateGesturePosition() 
    func die(completionHandler: @escaping FinishedAnimation)
    var spawnCount:Int {get set}
}

