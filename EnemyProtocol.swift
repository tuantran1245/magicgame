//
//  EnemyProtocol.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 9/8/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

protocol Enemy {
    var pBody:SKPhysicsBody! {get set}
    var isDisplayed:Bool {get set}
    var isDie:Bool {get set}

    func getChildren() -> [SKNode]
    func takeDamage()
    func updateGesturePosition()
    func getGestureNumber() -> Int
    func die()
}
