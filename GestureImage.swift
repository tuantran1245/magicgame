//
//  Gesture.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 2/24/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class GestureImage: SKSpriteNode {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Gesture.atlas")
    var gestureTextures : [SKTexture] = [SKTexture]()
    
    // MARK: - enum
    fileprivate enum GestureTypes: Character {
        case right = "0"
        case down = "1"
        case upArrow = "2"
        case downArrow = "3"
        case leftArrow = "4"
        case rightArrow = "5"
        // Mark: New additional gestures
        
        case downFish = "a"
        case upFish = "b"
        case M = "c"
        case W = "d"
        /*case EReserved = "e"
        case E = "f"*/
        case pRight = "g"
        case pLeft = "h"
        case N = "i"
        case NReserved = "k"
        case dogRight = "l"
        case dogLeft = "m"
        case boyRight = "n"
        case boyLeft = "o"
        case nose = "p"
        case noseReserved = "q"
        case z = "z"
    }
    
    func spawnRandom(parentNode: SKNode, position: CGPoint, isFlipHorizontal: Bool) {
        let gesture = GestureImage()
        //get radom gesture image raw value <6
        let randomGestureIndex = String(arc4random_uniform(6)) // Cast Uint32 to Strng
        let randomIndexCharacter = Character(randomGestureIndex) // cast random number from string to character

       // print("GESTURE INDEX: \(randomIndexCharacter)")
        let gestureType = GestureTypes.init(rawValue: randomIndexCharacter)
        gesture.position = position
        
        if isFlipHorizontal {
            gesture.xScale = -1
        }
        switch gestureType! {
        case .right:
            gesture.texture = textureAtlas.textureNamed("right.png")
            gesture.size =  CGSize(width: 24, height: 24)
            gesture.name = "right"
        case .down:
            gesture.texture = textureAtlas.textureNamed("down.png")
            gesture.size =  CGSize(width: 24, height: 24)
            gesture.name = "down"
        case .upArrow:
            gesture.texture = textureAtlas.textureNamed("upArrow.png")
            gesture.size =  CGSize(width: 24, height: 24)
            gesture.name = "upArrow"
        case .downArrow:
            gesture.texture = textureAtlas.textureNamed("downArrow.png")
            gesture.size =  CGSize(width: 24, height: 24)
            gesture.name = "downArrow"
        case .leftArrow:
            gesture.texture = textureAtlas.textureNamed("leftArrow.png")
            gesture.size =  CGSize(width: 24, height: 24)
            gesture.name = "leftArrow"
        case .rightArrow:
            gesture.texture = textureAtlas.textureNamed("rightArrow.png")
            gesture.size =  CGSize(width: 24, height: 24)
            gesture.name = "rightArrow"
        default:
            print("add gesture image error: Wrong Gesture name Check GestureImage.swift")
        
        }
        gesture.zPosition = 50
        parentNode.addChild(gesture)
    }
    
    func spawnByString(parentNode: SKNode, position: CGPoint, index: Character, isFlipHorizontal: Bool ) {
        // index in enum determine what gesture would be added
        let gesture = GestureImage()
        let gestureType = GestureTypes.init(rawValue: index)
        gesture.position = position
        gesture.size =  CGSize(width: 24, height: 24)
        
        if isFlipHorizontal {
            gesture.xScale = -1
        }

        switch gestureType! {
        case .right: //0
            gesture.texture = textureAtlas.textureNamed("right.png")
            gesture.name = "right"
        case .down: //1
            gesture.texture = textureAtlas.textureNamed("down.png")
            gesture.name = "down"
        case .upArrow: //2
            gesture.texture = textureAtlas.textureNamed("upArrow.png")
            gesture.name = "upArrow"
        case .downArrow: //3
            gesture.texture = textureAtlas.textureNamed("downArrow.png")
            gesture.name = "downArrow"
        case .leftArrow: //4
            gesture.texture = textureAtlas.textureNamed("leftArrow.png")
            gesture.name = "leftArrow"
        case .rightArrow: //5
            gesture.texture = textureAtlas.textureNamed("rightArrow.png")
            gesture.name = "rightArrow"
            
        case .downFish: //a
            gesture.texture = textureAtlas.textureNamed("downFish.png")
            gesture.name = "downFish"
        case .upFish: //b
            gesture.texture = textureAtlas.textureNamed("upFish.png")
            gesture.name = "upFish"
        case .M: //c
            gesture.texture = textureAtlas.textureNamed("M.png")
            gesture.name = "m"
        case .W: //d
            gesture.texture = textureAtlas.textureNamed("W.png")
            gesture.name = "w"
        /*case .EReserved: //e
            gesture.texture = textureAtlas.textureNamed("EReserved.png")
            gesture.name = "EReserved"
        case .E: //f
            gesture.texture = textureAtlas.textureNamed("E.png")
            gesture.name = "E"*/
        case .pRight: //g
            gesture.texture = textureAtlas.textureNamed("pRight.png")
            gesture.name = "pRight"
        case .pLeft: //h
            gesture.texture = textureAtlas.textureNamed("pLeft.png")
            gesture.name = "pLeft"
        case .N: //i
            gesture.texture = textureAtlas.textureNamed("N.png")
            gesture.name = "n"
        case .NReserved: //k
            gesture.texture = textureAtlas.textureNamed("NReserved.png")
            gesture.name = "nReserved"
        case .dogRight: //l
            gesture.texture = textureAtlas.textureNamed("dogRight.png")
            gesture.name = "dogRight"
        case .dogLeft: //m
            gesture.texture = textureAtlas.textureNamed("dogLeft.png")
            gesture.name = "dogLeft"
        case .boyRight: //n
            gesture.texture = textureAtlas.textureNamed("boyRight.png")
            gesture.name = "boyRight"
        case .boyLeft: //o
            gesture.texture = textureAtlas.textureNamed("boyLeft.png")
            gesture.name = "boyLeft"
        case .nose: //p
            gesture.texture = textureAtlas.textureNamed("nose.png")
            gesture.name = "nose"
        case .noseReserved: //q
            gesture.texture = textureAtlas.textureNamed("noseReserved.png")
            gesture.name = "noseReserved"
        case .z: //z
            gesture.texture = textureAtlas.textureNamed("Z.png")
            gesture.name = "z"
            
        }
        gesture.zPosition = 50
        parentNode.addChild(gesture)
    }
    
    func spawnSpecialGesture(parentNode: SKNode, position: CGPoint, gestureName: String, isFlipHorizontal: Bool) {
        let gesture = GestureImage()
        gesture.position = position
        
        if isFlipHorizontal {
            gesture.xScale = -1
        }
        
        switch gestureName {
        case "heart":
            gesture.texture = textureAtlas.textureNamed("heart.png")
            gesture.name = "heart"
        case "lighting":
            gesture.texture = textureAtlas.textureNamed("lighting.png")
            gesture.name = "lighting"
        default:
            print("add special gesture image error! Check GestureImage.swift")
        }
        gesture.size = CGSize(width: 24, height: 24)
        gesture.zPosition = 99
        parentNode.addChild(gesture)
    }
}
