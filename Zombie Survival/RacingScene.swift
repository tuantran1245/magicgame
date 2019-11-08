//
//  MenuScene.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 3/3/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit
import CoreMotion

class RacingScene: SKScene, SKPhysicsContactDelegate {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"RacingScene.atlas")
    var viewController : GameViewController!
    var motionManager = CMMotionManager()
    
    // Grab the HUD texture atlas:
    let screenBounds = UIScreen.main.bounds
    let initialPlayerPosition = CGPoint(x: 0, y: 0)
    var playerProgress:CGFloat = 0
    
    let world = SKNode()
    var player = RacingPlayer()
    
    var landBackground:SKTileMapNode!
    var objectsTileMap:SKTileMapNode!
    var bonusTileMap:SKTileMapNode!
    var TNTTileMap:SKTileMapNode!
    
    let particlePool = ParticalPool()
    
    var cam = SKCameraNode()
    let hud = HUD()
    
    let initForwardVelocity:CGFloat = 400
    var forwardVelocity:CGFloat = 0
    
    var currentVelocity:CGFloat = 0
    var increaseVelocity = SKAction()
    
    var forceAmount:CGFloat = 0
    var movement = CGVector()
    
    var isGameOver = false
    var chosenLevel = 6
    
    var replayBackgroundMusic = true
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = UIColor.cyan
        self.world.zPosition = 1
        self.addChild(world)
        
        if replayBackgroundMusic {
            SKTAudio.sharedInstance().playBackgroundMusic("Racing_Background.m4a")
        }
        
        hud.createHudNode(score: player.score, coinCollected: player.coinCollected)
        /*cam.xScale = 0.75
        cam.yScale = 0.75
        */
        
        self.camera = cam
        
        self.addChild(self.camera!)
        self.camera?.zPosition = 50
        
        hud.xScale = 3
        hud.yScale = 3
        
        self.camera?.addChild(hud)
        self.hud.show()
        
        self.physicsWorld.contactDelegate = self
        self.view?.showsPhysics = true
        let playableRect = CGRect(x: -frame.width/4, y: -frame.height/2 , width: frame.width/2, height: 40000)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        
        self.createAnimation()
        player.spawn(parentNode: world, position: initialPlayerPosition) {
        }
        self.player.run(self.increaseVelocity)
        
        motionManager.deviceMotionUpdateInterval = 1.0/100.0
        motionManager.startAccelerometerUpdates()
        
        self.loadSceneNodes()
        self.setObjectsMapPhysicBody()
        self.setBonusMapPhysicBody()
        self.setTNTTileMapPhysicBody()
    
        self.getPlayerStats()
        
        // Add emitter nodes to racingScene node tree:
        particlePool.addEmittersToScene(scene: self)
        self.forwardVelocity = self.initForwardVelocity
    }
    
    func loadSceneNodes() {
        guard let landBackground = childNode(withName: "GrassMap") as? SKTileMapNode else {
            fatalError("Background node not loaded")
        }
        self.landBackground = landBackground
        
        guard let objectsTileMap = childNode(withName: "CrateMap") as? SKTileMapNode else {
            fatalError("Object tile node not loaded")
        }
        self.objectsTileMap = objectsTileMap
        
        guard let bonusTileMap = childNode(withName: "BonusMap") as? SKTileMapNode else {
            fatalError("Bonus tile node not loaded")
        }
        self.bonusTileMap = bonusTileMap
        
        guard let TNTTileMap = childNode(withName: "TNTMap") as? SKTileMapNode else {
            fatalError("TNT tile node not loaded")
        }
        self.TNTTileMap = TNTTileMap
    }
    
    func setObjectsMapPhysicBody() {
        
        let tileSize = objectsTileMap.tileSize
        let halfWidth = CGFloat(objectsTileMap.numberOfColumns) / 2.0 * tileSize.width
      //  let halfHeight = CGFloat(objectsTileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<objectsTileMap.numberOfColumns {
            for row in 0..<objectsTileMap.numberOfRows {
                if let tileDefinition = objectsTileMap.tileDefinition(atColumn: col, row: row) {
                    if let _ = tileDefinition.userData?.value(forKey: "crate") {
                        let x = CGFloat(col) * tileSize.width - halfWidth
                        let y = CGFloat(row) * tileSize.height // tilemap anchorpoint = 0.5; 0
                        //let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                        let crate = Crate()
                        crate.position = CGPoint(x: x, y: y)
                        crate.anchorPoint = CGPoint(x: 0, y: 0)
                        crate.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                        crate.physicsBody?.isDynamic = false
                        
                        crate.physicsBody?.categoryBitMask = PhysicsCategory.crate.rawValue
                        crate.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
                        
                        crate.zPosition = 1
                        world.addChild(crate)
                        
                    }
                }
            }
        }
        // Remove crate node of the tile map after add crate as instance of Crate custom class
        self.objectsTileMap.removeFromParent()
    }
    
    func setBonusMapPhysicBody() {
        let tileSize = bonusTileMap.tileSize
        let halfWidth = CGFloat(bonusTileMap.numberOfColumns) / 2.0 * tileSize.width
        
        for col in 0..<bonusTileMap.numberOfColumns {
            for row in 0..<bonusTileMap.numberOfRows {
                if let tileDefinition = bonusTileMap.tileDefinition(atColumn: col, row: row) {
                    if let _ = tileDefinition.userData?.value(forKey: "bonusCrate") {
                        let x = CGFloat(col) * tileSize.width - halfWidth
                        let y = CGFloat(row) * tileSize.height // tilemap anchorpoint = 0.5; 0
                        //let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                        let bonusCrate = Crate()
                        bonusCrate.position = CGPoint(x: x, y: y)
                        bonusCrate.anchorPoint = CGPoint(x: 0, y: 0)
                        bonusCrate.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                        bonusCrate.physicsBody?.isDynamic = false
                        
                        bonusCrate.physicsBody?.categoryBitMask = PhysicsCategory.crate.rawValue
                        bonusCrate.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
                        
                        bonusCrate.turnToRandomRewardedCrate()
                        bonusCrate.zPosition = 1
                        world.addChild(bonusCrate)
                        
                    }
                }
            }
        }
        // Remove crate node of the tile map after add crate as instance of Crate custom class
        self.bonusTileMap.removeFromParent()
    }
    
    func setTNTTileMapPhysicBody() {
        let tileSize = TNTTileMap.tileSize
        let halfWidth = CGFloat(TNTTileMap.numberOfColumns) / 2.0 * tileSize.width
        
        for col in 0..<TNTTileMap.numberOfColumns {
            for row in 0..<TNTTileMap.numberOfRows {
                if let tileDefinition = TNTTileMap.tileDefinition(atColumn: col, row: row) {
                    if let _ = tileDefinition.userData?.value(forKey: "isTNT") {
                        let x = CGFloat(col) * tileSize.width - halfWidth
                        let y = CGFloat(row) * tileSize.height // tilemap anchorpoint = 0.5; 0
                        //let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                        let TNTCrate = Crate()
                        TNTCrate.position = CGPoint(x: x, y: y)
                        TNTCrate.anchorPoint = CGPoint(x: 0, y: 0)
                        TNTCrate.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
                        TNTCrate.physicsBody?.isDynamic = false
                        
                        TNTCrate.physicsBody?.categoryBitMask = PhysicsCategory.crate.rawValue
                        TNTCrate.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
                        
                        TNTCrate.turnToTNT()
                        TNTCrate.zPosition = 1
                        world.addChild(TNTCrate)
                        
                    }
                }
            }
        }
        // Remove crate node of the tile map after add crate as instance of Crate custom class
        self.TNTTileMap.removeFromParent()
    }
    
    // MARK: - Touch Handler
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch!.location(in: self)
        let nodeTouched = atPoint(location)
        //let touchLocationinView = convertPoint(toView: location)
        //print(nodeTouched.name ?? "nil or noname")
        
        // Check for HUD buttons:
        if nodeTouched.name == "restartGame" {
            if isGameOver {
                self.reloadGame()
            }
            else if world.isPaused {
                SKTAudio.sharedInstance().resumeBackgroundMusic()
                world.isPaused = false
                hud.hidePauseMenu()
            }
        }
        
        if nodeTouched.name == "returnToMenu" {
            // Transition to the main menu scene:
            let menuScene = MenuScene(size: self.screenBounds.size)
            menuScene.scaleMode = .aspectFill
            menuScene.viewController = self.viewController
            self.view?.presentScene(menuScene, transition: .crossFade(withDuration: 0.6))
        }
        
        if nodeTouched.name == "pauseGame" {
            if world.isPaused && !isGameOver {
                SKTAudio.sharedInstance().resumeBackgroundMusic()
                world.isPaused = false
                hud.hidePauseMenu()
            }else if !isGameOver{
                SKTAudio.sharedInstance().pauseBackgroundMusic()
                hud.showPauseMenu()
                world.isPaused = true
            }
        }
    }
    
    // MARK: - Collistion handler
    func didBegin(_ contact: SKPhysicsContact) {
        let otherBody:SKPhysicsBody
        // Combine the two player physics categories into one
        // bitmask using the bitwise OR operator |
        let playerMask = PhysicsCategory.player.rawValue | PhysicsCategory.damagedPlayer.rawValue
        
        // Use the bitwise AND operator & to find the player.
        // This returns a positive number if body A's category
        // is the same as either the penguin or damagedPenguin:
        if (contact.bodyA.categoryBitMask & playerMask) > 0 {
            //body A is player, we will test body b
            otherBody = contact.bodyB
        }
        else {
            //Body B is player, we will test body a
            otherBody = contact.bodyA
        }
        // Find the type of contact:
        switch otherBody.categoryBitMask {
        case PhysicsCategory.crate.rawValue:
           // print("touched crate")
            if let crate = otherBody.node as? Crate {
              //  print("crate exploded")
                crate.broke(racingScene: self, playerPosition: convertPoint(toView: self.player.position)) // convert point from map to view to fit the camera node wheb it noving following player
                crate.physicsBody = nil
                if !crate.isRewardPlayer {
                      print("Take Damage")
                    player.takeDamage()
                    hud.setHealthDisplay(newHealth: player.health)
                }
            
                /*if crate.TNTExploded {
                    player.die()
                }*/
            }
            
        default:
            //print("Contact with no game logic")
            print("")
        }
    }

    func createAnimation() {
        // increase velocity every 5 seconds
        self.increaseVelocity = SKAction.repeatForever(
            SKAction.sequence([SKAction.wait(forDuration: 7),
                               SKAction.run({
                                self.forwardVelocity += 50
                                print("progress: \(self.playerProgress), velocity: \(self.forwardVelocity)")
                               })]))
    }
    
    func getPlayerStats() {
        let saveGameData = UserDefaults.standard
        
        let currentScore = saveGameData.value(forKey: "CurrentScore")
        let coinCollected = saveGameData.value(forKey: "CoinCollected")
        
        
        self.player.score = currentScore as! Int
        self.hud.setScoreCountDisplay(newScoreCount: Int(player.score))
        print("player score: \(player.score)")
        
        self.player.coinCollected = coinCollected as! Int
        self.hud.setcoinCountDisplay(newCoinCount: player.coinCollected)
        print("player coin collected: \(player.coinCollected)")
    }
    
    func updatePlayerStats(completionHandler: () -> Void ) {
        // Completion handler is place holder for player.victory function which take presentLevelMenu or presentNextGameLevel as parametter to run these function serialy
        // get saved game data
        let saveGameData = UserDefaults.standard
        
        let highScore = saveGameData.value(forKey: "HighScore")
        let currentLevel = saveGameData.value(forKey: "CurrentLevel")
        
        if highScore == nil {
            saveGameData.set(player.score, forKey: "HighScore")
        }
        if currentLevel == nil {
            saveGameData.set(chosenLevel, forKey: "CurrentLevel")
        }
        
        saveGameData.set(player.score, forKey: "CurrentScore")
        saveGameData.set(player.coinCollected, forKey: "CoinCollected")
        //print("coin conllected = \(player.coinCollected)")
        saveGameData.synchronize()
        
        // three argument must not be nil
        
        if player.score > highScore as! Int {
            saveGameData.set(player.score, forKey: "HighScore")
            saveGameData.synchronize()
        }
        
        if chosenLevel == currentLevel as! Int {
            let nextLevel = chosenLevel + 1
            saveGameData.set(nextLevel, forKey: "CurrentLevel")
            print("Next level: \(nextLevel)")
            saveGameData.synchronize()
        }
        
        // call player.victory function after update player stats
        completionHandler()
    }
    
    // MARK: - Present next level
    func presentNextGameLevel() {
        print("present next level")
        // gameViewController -> menuScene -> gameScene
        let gameScene = GameScene(size: self.screenBounds.size, chosenLevel: self.chosenLevel + 1)
        // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
        gameScene.viewController = self.viewController
        let pushTransition = SKTransition.push(with: .left, duration: 1)
        self.view?.presentScene(gameScene, transition: pushTransition)
    }
    
    func presentLevelMenu() {
        print("present new game scene")
        // gameViewController -> menuScene -> gameScene
        let levelMenu = LevelMenu()
        // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
        levelMenu.scaleMode = .aspectFill
        levelMenu.viewController = self.viewController
        // Player touched the start text oe button node:
        self.view?.presentScene(levelMenu)
    }
    
    func gameOver() {
        isGameOver = true
        // pause game when game over
        world.isPaused = true
        //generateGhostTimer?.invalidate()
        // Show the restart and main menu buttons:
        hud.showPauseMenu()
    }
    
    func reloadGame() {
        let newGameScene = RacingScene(fileNamed: "RacingScene")
        newGameScene?.viewController = self.viewController
        newGameScene?.scaleMode = .aspectFill
        newGameScene?.replayBackgroundMusic = false
        self.view?.presentScene(newGameScene)
        
       /* player.health = 5
        player.isDead = false
        player.createPhysicBody() // re-create physic body
        hud.setHealthDisplay(newHealth: player.health)
        player.score = 0
        hud.setScoreCountDisplay(newScoreCount: player.score)
        hud.hidePauseMenu()
        hud.show()
        self.isGameOver = false
        world.isPaused = false
        */
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if let data = motionManager.accelerometerData {
            let accYPos = CGFloat(data.acceleration.y)
            
            currentVelocity = forwardVelocity
            
            if world.isPaused {
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            } else {
                switch UIApplication.shared.statusBarOrientation {
                case .landscapeRight:
                    forceAmount = -15000
                // print("landscapeRight")
                case .landscapeLeft:
                    forceAmount = 15000
                //print("landscapeLeft")
                default:
                    forceAmount = 0
                }
                
                if accYPos > 0.05 || accYPos <  -0.05 {
                    movement.dx = forceAmount * accYPos
                }

               /* if forwardVelocity < initForwardVelocity {
                    self.forwardVelocity = self.currentVelocity
                    print("current Velocity: \(currentVelocity)")
                    player.physicsBody?.velocity.dy = forwardVelocity
                }*/
                
                player.physicsBody?.applyForce(movement)
                player.physicsBody?.velocity.dy = forwardVelocity
                cam.position = player.position
                
                // Keep track of how far the player has flown
                playerProgress = player.position.y - initialPlayerPosition.y
                //print(playerProgress)
                
                /*if self.playerProgress >= 38000 {
                    self.presentNextGameLevel()
                }*/

            }
        }
    }
}
