//
//  PlayerProtocol.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 6/27/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

protocol PlayerProtocol {
    var textureAtlas: SKTextureAtlas {get set}
    var health:Int {get set}
   // func spawn(parentNode: SKNode, position: CGPoint, size: CGSize, gameScene:GameScene , completionHandler: @escaping () -> Void)
    func createPhysicBody()
    func createSound()
    func createAnimation()
    func takeDamage()
    func die()
    
}
