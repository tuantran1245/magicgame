//
//  ParticalPool.swift
//  Magic Game
//
//  Created by Tran Quoc Tuan on 7/2/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class ParticalPool {
    var cratePool:[SKEmitterNode] = []
    var heartPool:[SKEmitterNode] = []
    var TNTPool:[SKEmitterNode] = []
    var bonusCratePool:[SKEmitterNode] = []
    
    var crateIndex = 0
    var heartIndex = 0
    var TNTIndex = 0
    var bonusCrateIndex = 0
    // A property to store a reference to the gamescene:
    var racingScene = SKScene()
    
    init() {
        // Create 5 crate explosion emitter nodes:
        for i in 1...5 {
            // Create a crate emitter node:
            let crate = SKEmitterNode(fileNamed: "CrateExplosion")
            crate?.position = CGPoint(x: -5000, y: -5000)
            crate?.zPosition = CGFloat(45 - i)
            crate?.name = "crate" + String(i)
            // Add the emitter to the crate pool array:
            cratePool.append(crate!)
        }
        // Repeat these steps to create 1 heart emitter:
        for i in 1...1 {
            let heart = SKEmitterNode(fileNamed: "HeartExplosion")
            heart?.position = CGPoint(x: -5000, y: -5000)
            heart?.zPosition = CGFloat(45 - i)
            heart?.name = "heart" + String(i)
            heartPool.append(heart!)
        }
        
        for i in 1...1 {
            let tnt = SKEmitterNode(fileNamed: "TNTExplosion")
            tnt?.position = CGPoint(x: -5000, y: -5000)
            tnt?.zPosition = CGFloat(45 - i)
            tnt?.name = "TNT" + String(i)
            TNTPool.append(tnt!)
        }
        
        for i in 1...5 {
            let bonusCrate = SKEmitterNode(fileNamed: "BonusCrateExplotion")
            bonusCrate?.position = CGPoint(x: -5000, y: -5000)
            bonusCrate?.zPosition = CGFloat(45 - i)
            bonusCrate?.name = "bonus" + String(i)
            // Add the emitter to the crate pool array:
            bonusCratePool.append(bonusCrate!)
        }
    }
    // Called from GameScene to add emitters á children 
    func addEmittersToScene(scene: RacingScene) {
        self.racingScene = scene
        // Add the crate emitters to the scene:
        for i in 0..<cratePool.count {
            self.racingScene.addChild(cratePool[i])
        }
        // Add the heart emitter to the scene:
        for i in 0..<heartPool.count {
            self.racingScene.addChild(heartPool[i])
        }
        for i in 0..<TNTPool.count {
            self.racingScene.addChild(TNTPool[i])
        }
        for i in 0..<bonusCratePool.count {
            self.racingScene.addChild(bonusCratePool[i])
        }
    }
    // Use this function to reposition the next poooled node into the desired position:
    func placeEmitter(node:SKNode, emitterType:String) {
        // Pull an emitter node from correct pool 
        var emitter: SKEmitterNode
        switch emitterType {
            case "crate":
                emitter = cratePool[crateIndex] // global variable
                // Keep track of the next node to pull:
                crateIndex += 1
                if crateIndex >= cratePool.count {
                    crateIndex = 0
                }
            case "heart":
                emitter = heartPool[heartIndex]
                heartIndex += 1
                if heartIndex >= heartPool.count {
                    heartIndex = 0
                }
            case "TNT":
                emitter = TNTPool[TNTIndex]
                TNTIndex += 1
                if TNTIndex >= TNTPool.count {
                    TNTIndex = 0
                }
            case "bonus":
                emitter = bonusCratePool[TNTIndex]
                bonusCrateIndex += 1
                if bonusCrateIndex >= bonusCratePool.count {
                    bonusCrateIndex = 0
                }

        default:
            return
        }
        // Find the node's position relative to RacingScene:
        var absolutePosition = node.position
        if node.parent != racingScene {
            absolutePosition = racingScene.convert(node.position, from: node.parent!)
        }
        // Position the emitter on top of the node:
        emitter.position = absolutePosition
        // Restart the emitter animation
        emitter.resetSimulation()
    }
}
