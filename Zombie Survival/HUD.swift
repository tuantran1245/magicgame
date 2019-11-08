//
//  HUD.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 2/26/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import UIKit
import SpriteKit

class HUD: SKNode {
    var screenSize = UIScreen.main.bounds
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named: "hud.atlas")
    // An array to keep track of the heart
    var heartNodes: [SKSpriteNode] = []
    // A SKLabelNode to print the score
    let scoreCountText = SKLabelNode()
    
    let coinIcon = SKSpriteNode()
    var coinCountText = SKLabelNode()
    
    let restartButton = SKSpriteNode()
    let menuButton = SKSpriteNode()
    
    var comboShapeNode = SKSpriteNode()
    var comboCountText = SKLabelNode()
    
    var pauseButton = SKSpriteNode()
    
    
    // tutorial node
    let tutorialDialog = SKNode()
    let cursorHand = SKSpriteNode(imageNamed: "OneFinger.png")
    let shapeLayer = CAShapeLayer()

    func createHudNode(score:Int, coinCollected: Int) {
        //self.screenSize = screenSize
        self.zPosition = 100
        scoreCountText.fontName = "ChalkboardSE-Bold"
        scoreCountText.fontColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
        scoreCountText.fontSize = 40
        scoreCountText.position = CGPoint(x: screenSize.width/2 - 30, y: screenSize.height/2 - 30)
        scoreCountText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        scoreCountText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        scoreCountText.text = String (score)
        self.addChild(scoreCountText)
        
        // Create five heart nodes for the life meter
        for index in 0..<5 {
            let newHeartNode = SKSpriteNode(texture: textureAtlas.textureNamed("heart-full.png"))
            newHeartNode.size = CGSize(width: 46, height: 40)
            // position the hearts node below the score counter
            let xPos = -screenSize.width/2 + CGFloat(index * 60 + 33)
            let yPos = screenSize.height/2 - 30
            newHeartNode.position = CGPoint(x: xPos, y: yPos)
            // keep track of nodes in an array properties
            heartNodes.append(newHeartNode)
            self.addChild(newHeartNode)
        }

        pauseButton.texture = textureAtlas.textureNamed("button-pause.png")
        pauseButton.size = CGSize(width: 36, height: 36)
        pauseButton.name = "pauseGame"
        pauseButton.position = CGPoint(x: -screenSize.width/2 + 30, y: -screenSize.height/2 + 30)
        pauseButton.alpha = 0
        self.addChild(pauseButton)
        
        // Add restart and menu button textures to node
        restartButton.texture = textureAtlas.textureNamed("button-restart.png")
        menuButton.texture = textureAtlas.textureNamed("button-menu.png")
        // Assign node names to the buttons:
        restartButton.name = "restartGame"
        menuButton.name = "returnToMenu"
        // Position the button node:
        restartButton.position = CGPoint(x: 0, y: 0)
        menuButton.position = CGPoint(x: -140, y: 0)
        // Size the button nodes:
        restartButton.size = CGSize(width: 140, height: 140)
        menuButton.size = CGSize(width: 70, height: 70)
        
        comboShapeNode.texture = textureAtlas.textureNamed("CatHeadShape.png")
        comboShapeNode.position = CGPoint(x: 0, y: -screenSize.height/2 + 30)
        comboShapeNode.size = CGSize(width: 95, height: 62)
        comboShapeNode.alpha = 0
        
        comboCountText = SKLabelNode(fontNamed: "Chalkduster")
        comboCountText.fontColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
        comboCountText.text = "x1"
        comboCountText.verticalAlignmentMode = .center
        comboCountText.position = CGPoint(x: 0, y: 2)
        comboCountText.fontSize = 40
        comboCountText.zPosition = 2
        comboShapeNode.addChild(comboCountText)
        self.addChild(comboShapeNode)
        
        coinIcon.texture = textureAtlas.textureNamed("coin-gold.png")
        // set coinIcon position through heartnode position
        let xPos = screenSize.width/2 - 50
        let yPos = -screenSize.height/2 + 30
        coinIcon.position = CGPoint(x: xPos, y: yPos)
        coinIcon.size = CGSize(width: 26, height: 26)
        coinIcon.alpha = 0
        self.addChild(coinIcon)
        
        coinCountText.text = String (coinCollected) // set coin collected
        coinCountText.verticalAlignmentMode = .center
        coinCountText.horizontalAlignmentMode = .right
        coinCountText.position = CGPoint(x: -20, y: 0)
        coinCountText.fontSize = 35
        coinCountText.zPosition = 2
        coinCountText.fontColor = UIColor(red: 250/255, green: 203/255, blue: 0, alpha: 1)
        coinCountText.fontName = "ChalkboardSE-Bold"
        coinIcon.addChild(coinCountText)

        self.hide()
    }
    

    func hide() {
        for heartNode in heartNodes {
            heartNode.alpha = 0
        }
        scoreCountText.alpha = 0
        coinIcon.alpha = 0
        pauseButton.alpha = 0
    }
    
    func show() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        for heartNode in heartNodes {
            heartNode.run(fadeIn)
        }
        scoreCountText.run(fadeIn)
        coinIcon.run(fadeIn)
        pauseButton.run(fadeIn)
    }
    
    func showSkipButton() { // for intros and endings
        let skipButton = SKSpriteNode()
        skipButton.texture = textureAtlas.textureNamed("button-right.png")
        skipButton.size = CGSize(width: 50, height: 50)
        skipButton.position = CGPoint(x: screenSize.width/2 - 25, y:-screenSize.height/2 + 25)
        skipButton.zPosition = 100
        skipButton.name = "skipBtn"
        self.addChild(skipButton)
        
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.9),
            SKAction.fadeAlpha(to: 1, duration: 0.9),
            ])
       
        skipButton.run(SKAction.repeatForever(pulseAction))
    }
    
    func setScoreCountDisplay(newScoreCount:Int) {
        let formatter = NumberFormatter()
        formatter.maximumIntegerDigits = 6
        if let scoreStr = formatter.string(from: NSNumber(value: newScoreCount)) {
            scoreCountText.text = scoreStr
        }
    }
    
    func setHealthDisplay(newHealth: Int) {
        // Create a fade action to fade out any lost hearts:
        let fadeAction = SKAction.fadeAlpha(to: 0.2, duration: 0.3)
        //Loop through each heart and update its status
        for index in 0..<heartNodes.count {
            if index < newHealth {
                heartNodes[index].alpha = 1
            }
            else {
                heartNodes[index].run(fadeAction)
            }
        }
    }
    
    func setcoinCountDisplay(newCoinCount: Int) {
        coinCountText.text = String (newCoinCount)
    }
    
    func showPauseMenu() {
        // Set the button alpha to 0:
        restartButton.alpha = 0
        menuButton.alpha = 0
        // Add the button nodes to the HUD:
        self.addChild(restartButton)
        self.addChild(menuButton)
        // Fade in the buttons:
        let fadeAnimation =
            SKAction.fadeAlpha(to: 1, duration: 0.4)
        restartButton.run(fadeAnimation)
        menuButton.run(fadeAnimation)
    }
    
    func hidePauseMenu() {
        restartButton.removeFromParent()
        menuButton.removeFromParent()
    }
    
    func setComboValue(comboValue: Int) {
        let comboStr = "x\(comboValue)"
        let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
        let wait = SKAction.wait(forDuration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let fadeSequence = SKAction.sequence([fadeIn, wait, fadeOut])
        comboShapeNode.run(fadeSequence)
        self.comboCountText.text = comboStr
    }
    
    func showReadyLabel(level: Int, completionHandler: @escaping () -> ()) {
        let wait = SKAction.wait(forDuration: 1)
        
        let readyDialog = SKNode()
        readyDialog.position = CGPoint(x: 0, y: screenSize.height/2 - 100)
        self.addChild(readyDialog)

        let levelShapeNode = SKShapeNode(rect: CGRect(x: -98, y: -35, width: 196, height: 70), cornerRadius: 10 )
        levelShapeNode.zPosition = 1
        levelShapeNode.fillColor = UIColor.black
        levelShapeNode.strokeColor = UIColor.black
        levelShapeNode.alpha = 0.5
        readyDialog.addChild(levelShapeNode)
        
        let readyShapeNode = SKShapeNode(rect: CGRect(x: -85, y: -35, width: 170, height: 70), cornerRadius: 10 )
        readyShapeNode.zPosition = 1
        readyShapeNode.fillColor = UIColor.black
        readyShapeNode.strokeColor = UIColor.black
        readyShapeNode.alpha = 0.5
        
        let setShapeNode = SKShapeNode(rect: CGRect(x: -50, y: -35, width: 100, height: 70), cornerRadius: 10 )
        setShapeNode.zPosition = 1
        setShapeNode.fillColor = UIColor.black
        setShapeNode.strokeColor = UIColor.black
        setShapeNode.alpha = 0.5
        
        let drawShapeNode = SKShapeNode(rect: CGRect(x: -70, y: -35, width: 140, height: 70), cornerRadius: 10 )
        drawShapeNode.zPosition = 1
        drawShapeNode.fillColor = UIColor.green
        drawShapeNode.strokeColor = UIColor.green
        drawShapeNode.alpha = 0.25

        
        let readyLabel = SKLabelNode()
        readyLabel.fontName = "ChalkboardSE-Bold"
        readyLabel.fontSize = 50
        readyLabel.zPosition = 2
        readyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        readyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        readyLabel.text = "Level \(level)"
        readyDialog.addChild(readyLabel)
        
        readyLabel.run(wait) {
            levelShapeNode.removeFromParent()
            readyDialog.addChild(readyShapeNode)
            
            readyLabel.text = "Ready"
            readyLabel.run(wait) {
                
                readyShapeNode.removeFromParent()
                readyDialog.addChild(setShapeNode)
                
                readyLabel.text = "Set"
                readyLabel.run(wait) {
                    
                    setShapeNode.removeFromParent()
                    readyDialog.addChild(drawShapeNode)
                    
                    readyLabel.text = "Draw!"
                    readyLabel.run(wait) {
                        
                        completionHandler()
                        readyDialog.removeFromParent()
                    }
                }
            }
        }
    }
    
    func runCode(delay timeInterval:TimeInterval, _ code:@escaping ()->(Void)) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + timeInterval,
            execute: code
        )
    }
 
    func makeTutorialNode() {
        tutorialDialog.name = "tutorialDialog"
        tutorialDialog.position = CGPoint(x: 0, y: screenSize.height/2 - 50)
        
        let tutorialShapeNode = SKShapeNode(rect: CGRect(x: -200, y: -40, width: 400, height: 80), cornerRadius: 10)
        tutorialShapeNode.zPosition = 1
        tutorialShapeNode.fillColor = UIColor.black
        tutorialShapeNode.strokeColor = UIColor.black
        tutorialShapeNode.alpha = 0.5
        tutorialDialog.addChild(tutorialShapeNode)
        
        let tutorialLabelLine1 = SKLabelNode()
        tutorialLabelLine1.fontName = "ChalkboardSE-Bold"
        tutorialLabelLine1.fontSize = 30
        tutorialLabelLine1.position = CGPoint(x: 0, y: 15)
        tutorialLabelLine1.zPosition = 2
        tutorialLabelLine1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        tutorialLabelLine1.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        tutorialLabelLine1.text = "Defeat a ghost by drawing"
        tutorialDialog.addChild(tutorialLabelLine1)
        
        let tutorialLabelLine2 = SKLabelNode()
        tutorialLabelLine2.fontName = "ChalkboardSE-Bold"
        tutorialLabelLine2.fontSize = 30
        tutorialLabelLine2.position = CGPoint(x: 0, y: -20)
        tutorialLabelLine2.zPosition = 2
        tutorialLabelLine2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        tutorialLabelLine2.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        tutorialLabelLine2.text = "its symbol anywhere"
        tutorialDialog.addChild(tutorialLabelLine2)
        
        cursorHand.size = CGSize(width: 128, height: 128)
        cursorHand.position = CGPoint(x: -170, y: -80)
        cursorHand.anchorPoint = CGPoint(x: 0, y: 1)

        shapeLayer.fillColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound

    }
}
