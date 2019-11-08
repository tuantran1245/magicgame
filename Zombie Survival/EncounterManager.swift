//
//  EncounterManager.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 3/2/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class EncounterManager {
    let screenBounds = UIScreen.main.bounds
    let iphone6sHalfWidth: CGFloat = 333.5
    let iphone6SHaftHeigh: CGFloat = 187.5
    var maxGestureNumber:Int = 1
    var defaultMoveDuration:Double = 8
    var defaultRangerMoveDuration:Double = 5
    var gameLevel:Int = 1
    var encounterNames:[String] = []
    
    // MARK: USER DATA PARAMETER
    // default value are gesture number = 1, delay = 0s.
    var gestureNumber:Int = 1
    var delay:Double = 0 //seconds
    var moveTime:Double = 8
    var gestureList:String = ""
    var isLighting = false
    
    var encounterCount: Int = 0
    // store encounter file name
   
    func setEncounterNameBy(chosenLevel:Int){
        self.gameLevel = chosenLevel
        let lv_1_encounterName:[String] = [
           // "lv1_w1",
           // "lv1_w2",
            "lv1_w3",
            "lv1_w4",
            "lv1_w5",
            "lv1_w6",
            "lv1_w7",
            "lv1_w8",
            "lv1_w9",
            "lv1_w10",
            "lv1_w11"
        ]
        
        let lv_2_encounterName:[String] = [
            "lv2_w1",
            "lv2_w2",
            "lv2_w3",
            "lv2_w4",
            "lv2_w5",
            "lv2_w6",
            "lv2_w7",
            "lv2_w8",
            "lv2_w9",
            "lv2_w10"
        ]

        let lv_3_encounterName:[String] = [
            "lv3_w1",
            "lv3_w2",
            "lv3_w3",
            "lv3_w4",
            "lv3_w5",
            "lv3_w6",
            "lv3_w7",
            "lv3_w8",
            "lv3_w9",
            "lv3_w10"
        ]
        
        let lv_4_encounterName:[String] = [
            "lv4_w1",
            "lv4_w2",
            "lv4_w3",
            "lv4_w4",
            "lv4_w5",
            "lv4_w6",
            "lv4_w7"
            /*"lv4_w8",
            "lv4_w9",
            "lv4_w10"*/
        ]
        
        let lv_5_encounterName:[String] = [
            "lv5_w1",
            "lv5_w2",
            "lv5_w3"
//            "lv5_w4",
//            "lv5_w5",
//            "lv5_w6",
//            "lv5_w7",
//            "lv5_w8",
//            "lv5_w9",
//            "lv5_w10"
        ]

        let lv_7_encounterName:[String] = [
            "lv7_w1",
            "lv7_w2",
            "lv7_w3",
            "lv7_w4",
            "lv7_w5",
            "lv7_w6",
            "lv7_w7",
            "lv7_w8",
            "lv7_w9",
            "lv7_w10",
            "lv7_w11"
        ]

        
        let lv_8_encounterName:[String] = [
            "lv8_w1",
            "lv8_w2",
            "lv8_w3",
            "lv8_w4",
            "lv8_w5",
            "lv8_w6",
            "lv8_w7",
            "lv8_w8",
            "lv8_w9",
            "lv8_w10",
            "lv8_w11"
        ]

        
        let lv_9_encounterName:[String] = [
            "lv9_w1",
            "lv9_w2",
            "lv9_w3",
            "lv9_w4"
        ]

        
        let encounterNamesDict: [Int:[String]] = [
            1: lv_1_encounterName,
            2: lv_2_encounterName,
            3: lv_3_encounterName,
            4: lv_4_encounterName,
            5: lv_5_encounterName,
            7: lv_7_encounterName,
            8: lv_8_encounterName,
            9: lv_9_encounterName
        ]
        
        encounterNames = encounterNamesDict[chosenLevel]!
        encounterCount = encounterNames.count
    }
    
    func addEnemiesTo(world: SKNode, encounterIndex:Int, moveToPoint: CGPoint) {
        //load this screen into a SKScene instance
        if let encounterScene = SKScene(fileNamed: encounterNames[encounterIndex]) {
            print(encounterNames[encounterIndex])
            
            // loop through each pleaceholder, spawn appropriate game object
            for placeholder in encounterScene.children {
                if let node = placeholder as SKNode? {
                    let spawnPosition =  self.convertPointAccordSceneRatio(nodePosition: node.position)
                    // *MARK: Get node uset data param
                    self.getNodeUserData(node: node)
                    switch node.name! {
                    case "Ghost":
                        let ghost = Ghost()
                        // add enemy node to encounter parent - world
                        ghost.spawn(parentNode: world, position: spawnPosition, maxGestureNumber: gestureNumber, delayTime: delay, isLighting: isLighting, moveToPoint: moveToPoint, moveDuration: moveTime, gestureList: gestureList)
                        
                    case "Ork":
                        let ork = Ork()
                        ork.spawn(parentNode: world, position: spawnPosition, maxGestureNumber: gestureNumber, delayTime: delay, isLighting: isLighting, moveToPoint: moveToPoint, moveDuration: moveTime, gestureList: gestureList)
                        
                        
                    case "Ork_Capt":
                        let orkCaptain = OrkCaptain()
                        orkCaptain.spawn(parentNode: world, position: spawnPosition, maxGestureNumber: gestureNumber, delayTime: delay, isLighting: false, moveToPoint: moveToPoint, moveDuration: moveTime, doubleGestureList: gestureList)
                        
                        
                    case "Archer":
                        let archer = Archer()
                        archer.spawn(parentNode: world, position: spawnPosition, maxGestureNumber: gestureNumber, delayTime: delay, isLighting: isLighting, moveToPoint: moveToPoint, moveDuration: moveTime, gestureList: gestureList)
                    
                    
                    /*case "ArcherWoman":
                        let archerWoman = ArcherWoman()
                        archerWoman.spawn(parentNode: world, position: spawnPosition, maxGestureNumber: gestureNumber, delayTime: delay, isLighting: isLighting, moveToPoint: moveToPoint, moveDuration: moveTime, gestureList: gestureList)*/
                        
                    case "SwordsWoman":
                        let swordsWoman = SwordsWoman()
                        swordsWoman.spawn(parentNode: world, position: spawnPosition, maxGestureNumber: gestureNumber, delayTime: delay, isLighting: isLighting, moveToPoint: moveToPoint, moveDuration: moveTime, gestureList: gestureList)
                        
                    case "Witcher":
                        let witcher = Witcher()
                        witcher.spawn(parentNode: world, position: spawnPosition, maxGestureNumber: gestureNumber, delayTime: delay, isLighting: isLighting, moveToPoint: moveToPoint, moveDuration: moveTime, gestureList: gestureList)
                        
                    case "BossLv_1":
                        let bossLv1 = BossLv1()
                        bossLv1.spawn(parentNode: world, position: spawnPosition, moveDuration: self.defaultMoveDuration + 7, moveToPoint: moveToPoint, gestureList: "20212021")
                        
                    case "BossLv_2":
                        let bossLv2 = BossLv2()
                        bossLv2.spawn(parentNode: world, position: spawnPosition, moveDuration: self.defaultMoveDuration + 1, moveToPoint: moveToPoint, gestureList: "")
                        
                    case "BossLv_3":
                        let bossLv3 = BossLv3()
                        bossLv3.spawn(parentNode: world, position: spawnPosition, moveDuration: self.defaultMoveDuration - 4, moveToPoint: moveToPoint, gestureList: "023")
                        
                    case "BossLv_4":
                        let bossLv4 = BossLv4()
                        bossLv4.spawn(parentNode: world, position: spawnPosition, moveDuration: self.defaultMoveDuration + 4, moveToPoint: moveToPoint, gestureList: "22332233")
                        
                    case "BossLv_5":
                        let bossLv5 = BossLv5()
                        bossLv5.spawn(parentNode: world, position: spawnPosition, moveDuration: self.defaultMoveDuration, moveToPoint: moveToPoint, gestureList: "")
                        
                    case "BossLv_7":
                        let bossLv7 = BossLv7()
                        bossLv7.spawn(parentNode: world, position: spawnPosition, moveDuration: self.defaultMoveDuration + 5, moveToPoint: moveToPoint, gestureList: "023")
                        
                    case "BossLv_8":
                        let bossLv8 = BossLv8()
                        bossLv8.spawn(parentNode: world, position: spawnPosition, moveDuration: self.defaultMoveDuration + 4, moveToPoint: moveToPoint, gestureList: "22332233")
                    
                    case "BossLv_9":
                        let bossLv9 = BossLv9()
                        bossLv9.spawn(parentNode: world, position: spawnPosition, moveDuration: self.defaultMoveDuration, moveToPoint: moveToPoint, gestureList: "")
                        
                    default:
                        print("Name error: \(String(describing: node.name))")
                    }
                }
            }
        }
    }
    
    func delay(delayTime:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delayTime
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func convertPointAccordSceneRatio(nodePosition: CGPoint) -> CGPoint {
        let xPos = nodePosition.x / iphone6sHalfWidth * (screenBounds.width / 2)
        let yPos = nodePosition.y / iphone6SHaftHeigh * (screenBounds.height / 2)
        // Node in SKS file was positioned according to iphone 6s
        return CGPoint(x: xPos,y: yPos)
    }
    
    func getNodeUserData(node: SKNode) -> () {
        let userData = node.userData
        // default value are gesture number = 1, delay = 0s.
        self.gestureNumber = userData?.object(forKey: "gestureNumber") as? Int ?? 1
        self.delay = userData?.object(forKey: "delay") as? Double ?? 0
        self.gestureList = userData?.object(forKey: "list") as? String ?? ""
        self.isLighting = userData?.object(forKey: "lighting") as? Bool ?? false
        
        let tempMoveTime = userData?.object(forKey: "moveTime") as? Double
        //print("movetime:\(tempMoveTime)")
        if isLighting {
            moveTime += 5 // lighting ghost move slower than usual
        } else if node is Ranger && tempMoveTime == nil {
           // print("Ranger detected!")
            moveTime = self.defaultRangerMoveDuration
        } else {
            moveTime = tempMoveTime ?? self.defaultMoveDuration
            //print ("moveTime: \(moveTime)")
        }
    }
    
    // MARK: Random generate encounter
    /*var randomEncounterCount = 1
    
    func randomEncounterGenerate() {
        var randomLevel:UInt32 = 1
        var randomEncounterIndex:UInt32 = 0
        
        while true {
            randomLevel = arc4random_uniform(7) + 1
            if randomLevel != 5 || randomLevel != 6 {
                break
            }
        }
        
        switch randomLevel {
            case 1,7,8:
                randomEncounterIndex = arc4random_uniform(9) + 1
            case 3:
                randomEncounterIndex = arc4random_uniform(8) + 1
            case 2,4:
                randomEncounterIndex = arc4random_uniform(6) + 1
            default:
                print("what to do here? - EncounterManager.swift")
        }
        let encounterName = "lv\(randomLevel)_w\(randomEncounterIndex)"
    }*/
  }
