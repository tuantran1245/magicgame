//
//  MenuScene.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 3/3/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var viewController : GameViewController!
    // Grab the HUD texture atlas:
    let textureAtlas: SKTextureAtlas = SKTextureAtlas(named:"hud.atlas")
    let startButton = SKSpriteNode()
    let screenBounds = UIScreen.main.bounds
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        SKTAudio.sharedInstance().playBackgroundMusic("main_menu_background.mp3")
        
        let backgroundImage = SKSpriteNode(imageNamed: "Background-menu_6")
        backgroundImage.size = CGSize(width: screenBounds.width, height: screenBounds.height)
        backgroundImage.zPosition = -1
        self.addChild(backgroundImage)
        
        // Draw the name of the game
        let logoText = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        logoText.text = "Magic Cat"
        logoText.position = CGPoint(x: 0, y: 100)
        logoText.fontSize = 60
        logoText.zPosition = 1
        self.addChild(logoText)
        // Add another line below
        let logoTextBottom = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        logoTextBottom.text = "Aventure"
        logoText.position = CGPoint(x: 0, y: 50 )
        logoText.fontSize = 60
        logoText.zPosition = 1
        self.addChild(logoTextBottom)

        // Build the start game button
        startButton.texture = textureAtlas.textureNamed("button.png")
        startButton.size = CGSize(width: 295, height: 76)
        // Name the start button for touch detetion
        startButton.name = "StartBtn"
        startButton.position = CGPoint(x: 0, y: -50)
        startButton.zPosition = 1
        self.addChild(startButton)
        
        // Add text to the start button:
        let startText = SKLabelNode(fontNamed:
            "AvenirNext-HeavyItalic")
        startText.text = "START GAME"
        startText.verticalAlignmentMode = .center
        startText.position = CGPoint(x: 0, y: 2)
        startText.fontSize = 40
        startText.zPosition = 2
        
        // Name the text same as button for touch detection
        startText.name = "StartBtn"
        startButton.addChild(startText)
        
        // Pulse the start button in and out gently:
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.9),
            SKAction.fadeAlpha(to: 1, duration: 0.9),
            ])
        startButton.run(
            SKAction.repeatForever(pulseAction))
        
        //self.resetSaveGameData()
        self.setDefaultGameData()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodeTouched = atPoint(location)
            
            if nodeTouched.name == "StartBtn" {
                // gameViewController -> menuScene -> gameScene
                let levelMenu = LevelMenu(size: self.size)
                // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
                levelMenu.viewController = self.viewController
                // let transition = SKTransition.reveal(with: .left, duration: 1.0)
                let pushTransition = SKTransition.push(with: .left, duration: 1)
                self.view?.presentScene(levelMenu, transition: pushTransition)
            }
        }
    }
    
    func setDefaultGameData() {
        let saveGameData = UserDefaults.standard
        
        let highScore = saveGameData.value(forKey: "HighScore")
        let currentLevel = saveGameData.value(forKey: "CurrentLevel")
        //let hitPoints = saveGameData.value(forKey: "HitPoints")
        let coinCollected = saveGameData.value(forKey: "CoinCollected")
        let currentScore = saveGameData.value(forKey: "CurrentScore")
        
        if highScore == nil {
            saveGameData.set(0, forKey: "HighScore")
        }
        if currentLevel == nil {
            saveGameData.set(1, forKey: "CurrentLevel")
        }
        /*if hitPoints == nil {
            saveGameData.set(5, forKey: "HitPoints")
        }*/
        if coinCollected == nil {
            saveGameData.set(0, forKey: "CoinCollected")
        }
        if currentScore == nil {
            saveGameData.set(0, forKey: "CurrentScore")
        }
        
    }
    
    func resetSaveGameData() {
        let saveGameData = UserDefaults.standard
        saveGameData.removeObject(forKey: "HighScore")
        saveGameData.removeObject(forKey: "CurrentLevel")
        //saveGameData.removeObject(forKey: "HitPoints")
        saveGameData.removeObject(forKey: "CoinCollected")
        saveGameData.removeObject(forKey: "CurrentScore")
        
        let highScore = saveGameData.value(forKey: "HighScore")
        let currentLevel = saveGameData.value(forKey: "CurrentLevel")
       // let hitPoints = saveGameData.value(forKey: "HitPoints")
        let coinCollected = saveGameData.value(forKey: "CoinCollected")
        let currentScore = saveGameData.value(forKey: "CurrentScore")
        
        if highScore == nil {
            print("highScore is nil")
            saveGameData.set(0, forKey: "HighScore")
        }
        if currentLevel == nil {
            print("currentLevel is nil")
            saveGameData.set(1, forKey: "CurrentLevel")
        }
        /*if hitPoints == nil {
            print("hitPoints is nil")
        }*/
        if coinCollected == nil {
            print("coinCollected is nil")
            saveGameData.set(0, forKey: "CoinCollected")
        }
        if currentScore == nil {
            print("current score is nil")
            saveGameData.set(0, forKey: "CurrentScore")
        }
    }
}
