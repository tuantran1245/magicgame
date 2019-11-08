//
//  MiniBoss.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 8/26/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

protocol MiniBoss {
    var textureAtlas: SKTextureAtlas {get set}
    var pBody:SKPhysicsBody! {get set}
    var isDisplayed:Bool {get set}
    var isDie:Bool {get set}
    var reSpawnCount:Int {get set}
    var doubleGestureList: String {get set} // truoc dau phay la gesture list thu nhat, sau dau phay la gesture list thu 2
    var firstGestureList:String {get set}
    var secondGestureList:String {get set}
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize, maxGestureNumber: Int, delayTime: Double, isLighting: Bool, moveToPoint: CGPoint, moveDuration: Double, doubleGestureList: String)
    func moveBack()
    func attack()
    func takeDamage()
    func getChildren() -> [SKNode]
    func getGestureNumber() -> Int
    func updateGesturePosition()
    func die()
    func transformToCoin()
}
