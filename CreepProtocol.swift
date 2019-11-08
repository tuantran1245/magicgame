//
//  EnemyProtocol.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 8/22/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

protocol Creep:Enemy {
    var textureAtlas:SKTextureAtlas {get set}
    var pBody:SKPhysicsBody! {get set}
    var isDisplayed:Bool {get set}
    var isDie:Bool {get set}
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize, maxGestureNumber: Int, delayTime: Double, isLighting: Bool, moveToPoint: CGPoint, moveDuration: Double, gestureList: String)
    func getChildren() -> [SKNode]
    func addGestureImage(gestureNumber: Int)
    func addGestureBy(string: String)
    //func addLightningGesture()
    func updateGesturePosition()
    func getGestureNumber() -> Int
    func createAnimation()
    func createSound()
    func createPhysicsBody(size: CGSize)
    func takeDamage()
    func die()
    func attack()
    func transformToCoin()
}
