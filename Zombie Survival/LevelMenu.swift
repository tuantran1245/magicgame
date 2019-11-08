//
//  ScrollTest.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 3/7/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class LevelMenu: SKScene {
    var viewSize = CGRect()
    var viewController : GameViewController!
    var startY: CGFloat = 0.0
    var lastY: CGFloat = 0.0
    var moveableArea = SKNode()
    let textureAtlas: SKTextureAtlas = SKTextureAtlas(named:"hud.atlas")
    
    var buttonLeft = SKSpriteNode()
    var buttonRight = SKSpriteNode()
    var buttonDown = SKSpriteNode()
    
    var currentLevel = 1
  
    var pageIndex = 0
    var maxpageIndex = 4
    
    fileprivate var page1Xpos = CGFloat()
    fileprivate var page2Xpos = CGFloat()
    fileprivate var page3Xpos = CGFloat()
    fileprivate var page4Xpos = CGFloat()
    fileprivate var page5Xpos = CGFloat()

    var fadeAnimation = SKAction()
    
    override func didMove(to view: SKView) {
        viewSize = view.bounds
        self.createAnimations()

        // set position & add scrolling/moveable node to screen
        moveableArea.position = CGPoint.zero
        self.addChild(moveableArea)
        
        // width + 1 each page
        page1Xpos = CGFloat(viewSize.width / 2)
        page2Xpos = CGFloat(viewSize.width * 3/2)
        page3Xpos = CGFloat(viewSize.width * 5/2)
        page4Xpos = CGFloat(viewSize.width * 7/2)
        page5Xpos = CGFloat(viewSize.width * 9/2)
        
        // width + 1 each page
        let backgroundPage1 = SKSpriteNode(imageNamed: "Level_background_1.jpg")
        backgroundPage1.size = CGSize(width: self.size.width, height: self.size.height * 3)
        backgroundPage1.position = CGPoint(x: page1Xpos, y: viewSize.height / -2)
        backgroundPage1.zPosition = -1
        moveableArea.addChild(backgroundPage1)
        
        let backgroundPage2 = SKSpriteNode(imageNamed: "Level_background_2.jpg")
        backgroundPage2.size = CGSize(width: self.size.width, height: self.size.height * 3)
        backgroundPage2.position = CGPoint(x: page2Xpos, y: viewSize.height / -2)
        backgroundPage2.zPosition = -1
        moveableArea.addChild(backgroundPage2)

        let backgroundPage3 = SKSpriteNode(imageNamed: "Level_background_3.jpg")
        backgroundPage3.size = CGSize(width: self.size.width, height: self.size.height * 3)
        backgroundPage3.position = CGPoint(x: page3Xpos, y: viewSize.height / -2)
        backgroundPage3.zPosition = -1
        moveableArea.addChild(backgroundPage3)
        
        let backgroundPage4 = SKSpriteNode(imageNamed: "Level_background_4.jpg")
        backgroundPage4.size = CGSize(width: self.size.width, height: self.size.height * 3)
        backgroundPage4.position = CGPoint(x: page4Xpos, y: viewSize.height / -2)
        backgroundPage4.zPosition = -1
        moveableArea.addChild(backgroundPage4)

        let backgroundPage5 = SKSpriteNode(imageNamed: "Level_background_5.jpg")
        backgroundPage5.size = CGSize(width: self.size.width, height: self.size.height * 3)
        backgroundPage5.position = CGPoint(x: page5Xpos, y: viewSize.height / -2)
        backgroundPage5.zPosition = -1
        moveableArea.addChild(backgroundPage5)
        
        
        buttonLeft = SKSpriteNode()
        // Build the start game button
        buttonLeft.texture = textureAtlas.textureNamed("button-left.png")
        buttonLeft.size = CGSize(width: 75, height: 75)
        // Name the start button for touch detetion
        buttonLeft.name = "buttonLeft"
        buttonLeft.position = CGPoint(x: 15, y: self.frame.midY)
        buttonLeft.zPosition = 100
        buttonLeft.alpha = 0.6
        self.addChild(buttonLeft)
        
        buttonRight = SKSpriteNode()
        // Build the start game button
        buttonRight.texture = textureAtlas.textureNamed("button-right.png")
        buttonRight.size = CGSize(width: 75, height: 75)
        // Name the start button for touch detetion
        buttonRight.name = "buttonRight"
        buttonRight.position = CGPoint(x: self.frame.maxX - 15, y: self.frame.midY)
        buttonRight.zPosition = 100
        buttonRight.alpha = 0.6
        self.addChild(buttonRight)
 
        buttonDown = SKSpriteNode()
        // Build the start game button
        buttonDown.texture = textureAtlas.textureNamed("button-down.png")
        buttonDown.size = CGSize(width: 75, height: 75)
        // Name the start button for touch detetion
        buttonDown.name = "buttonDown"
        buttonDown.position = CGPoint(x: self.frame.midX, y: 15)
        buttonDown.zPosition = 100
        buttonDown.alpha = 0.6
        self.addChild(buttonDown)

        //MARK: - Page tittles
        self.addPageTittle()
        
        let bottom = SKLabelNode(fontNamed: "Avenir-Black")
        bottom.text = "Bottom"
        bottom.fontSize = self.frame.maxY/20
        bottom.position = CGPoint(x:self.frame.midX, y:0-self.frame.maxY*0.5)
        moveableArea.addChild(bottom)
        
        // MARK: Add level buttons
        var levelButtons: [SKSpriteNode] = []
        levelButtons += self.addLevelButtonsToPage(index: 1)
        levelButtons += self.addLevelButtonsToPage(index: 2)
        levelButtons += self.addLevelButtonsToPage(index: 3)
        
        // MARK: Get current level
        self.getCurrentLevel()
        //self.scrollToCurrentLevel()
        self.addButtonAlpha(levelButtons: levelButtons)
        self.addPageButtonsAnimation()
        
        let swipedRight = UISwipeGestureRecognizer(target: self, action: #selector(moveToPreviousLevelPage))
        swipedRight.direction = .right
        view.addGestureRecognizer(swipedRight)
        
        let swipedLeft = UISwipeGestureRecognizer(target: self, action: #selector(moveToNextLevelPage))
        swipedLeft.direction = .left
        view.addGestureRecognizer(swipedLeft)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // store the starting position of the touch
        let touch = touches.first
        //let location = touch!.location(in: view)
        let location = touch!.location(in: self)

        startY = location.y
        lastY = location.y
        
        // get touched node
        let nodeTouched = atPoint(location)
        print(nodeTouched.name ?? "nil")
        if nodeTouched.name == "buttonLeft" {
            self.moveToPreviousLevelPage()
        }
        if nodeTouched.name == "buttonRight" {
            self.moveToNextLevelPage()
        }
        
        if nodeTouched.name == "buttonLevel_1" {
            let level1_Intro = Level1_Intro(fileNamed: "Level1_Intro")
            level1_Intro?.viewController = self.viewController
            level1_Intro?.scaleMode = .aspectFit
            self.view?.presentScene(level1_Intro)
            //self.presentGameScene(chosenLevel: 1)
        }
        
        if nodeTouched.name == "buttonLevel_2" {
            if currentLevel >= 2 {
                self.presentGameScene(chosenLevel: 2)
            }
        }
        
        if nodeTouched.name == "buttonLevel_3" {
            if currentLevel >= 3 {
                self.presentGameScene(chosenLevel: 3)
            }
        }
        
        if nodeTouched.name == "buttonLevel_4" {
            if currentLevel >= 4 {
                self.presentGameScene(chosenLevel: 4)
            }
        }
        
        if nodeTouched.name == "buttonLevel_5" {
            if currentLevel >= 5 {
                let level5_Intro = Level5_Intro(fileNamed: "Level5_Intro")
                level5_Intro?.viewController = self.viewController
                self.view?.presentScene(level5_Intro)
            }
        }
        
        if nodeTouched.name == "buttonLevel_6" {
            let racingScene = RacingScene(fileNamed: "RacingScene")
            racingScene?.scaleMode = .aspectFill
            racingScene?.viewController = self.viewController
            self.view?.presentScene(racingScene)
        }

        if nodeTouched.name == "buttonLevel_7" {
            if currentLevel >= 7 {
                self.presentGameScene(chosenLevel: 7)
            }
        }
        
        if nodeTouched.name == "buttonLevel_8" {
            if currentLevel >= 8 {
                self.presentGameScene(chosenLevel: 8)
            }
        }
        
        if nodeTouched.name == "buttonLevel_9" {
            if currentLevel >= 9 {
                self.presentGameScene(chosenLevel: 9)
            }
        }
    }
    
   /* func addBackGround(viewSize: CGSize) {
        let node = SKSpriteNode()
       // var backgroundXPos: CGFloat = viewSize * 1/2
        for i in 1...5 {
            var pageBackground = node.copy() as! SKSpriteNode
            pageBackground = SKSpriteNode(imageNamed: "Level_background_\(i).jpg")
            pageBackground.size = CGSize(width: self.size.width, height: self.size.height * 3)
            pageBackground.position = CGPoint(x: page1Xpos, y: viewSize.height / -2)
            pageBackground.zPosition = -1
            moveableArea.addChild(pageBackground)
        }
    }
 */

    func addPageTittle() {
        let topTitlePage1 = SKLabelNode(fontNamed: "Avenir-Black")
        topTitlePage1.text = "Chapter 1: Ghost buster"
        topTitlePage1.fontSize = self.frame.maxY/15
        topTitlePage1.position = CGPoint(x:self.page1Xpos, y:self.frame.maxY*0.9)
        moveableArea.addChild(topTitlePage1)
        
        let topTitlePage2 = SKLabelNode(fontNamed: "Avenir-Black")
        topTitlePage2.text = "Chapter 2: Alien invasion"
        topTitlePage2.fontSize = self.frame.maxY/15
        topTitlePage2.position = CGPoint(x:self.page2Xpos, y:self.frame.maxY*0.9)
        moveableArea.addChild(topTitlePage2)
        
        let topTitlePage3 = SKLabelNode(fontNamed: "Avenir-Black")
        topTitlePage3.text = "Chapter 3: Zombie apocalise"
        topTitlePage3.fontSize = self.frame.maxY/15
        topTitlePage3.position = CGPoint(x:self.page3Xpos, y:self.frame.maxY*0.9)
        moveableArea.addChild(topTitlePage3)
    }
    
   
    func addLevelButtonsToPage(index: Int) -> [SKSpriteNode] {
        // MARK: Add level buttons
        var levelButtons: [SKSpriteNode] = []
        // node declaration then copy to level button
        let node = SKSpriteNode()
        let text = SKLabelNode(fontNamed: "Avenir-Black")
        
        var buttonCount:CGFloat = 1 // increase each time add a level button
        
        var levelListOnPage: [Int] = []
        var levelButtonXPosition: CGFloat = 0.0
        // MARK: - SET LEVEL LIST ON EACH PAGE HERE
        switch index {
        case 1:
            levelListOnPage = [1,2,3,4,5]
            levelButtonXPosition = self.page1Xpos
        case 2:
            levelListOnPage = [6,7,8,9,10]
            levelButtonXPosition = self.page2Xpos
        case 3:
            levelListOnPage = [11,12,13,14,15]
            levelButtonXPosition = self.page3Xpos
        default:
            print("level list error, check levelmenu.swift")
        }
        
        for i in levelListOnPage {
            let buttonLevel = node.copy() as! SKSpriteNode
            // Build the start game button
            buttonLevel.texture = textureAtlas.textureNamed("button.png")
            buttonLevel.size = CGSize(width: 295, height: 76)
            // Name the start button for touch detetion
            buttonLevel.name = "buttonLevel_\(i)"
            // print("button name: \(buttonLevel.name), y: \(maxY * 0.9 - CGFloat(i) * 0.2 * maxY)")
            buttonLevel.position = CGPoint(x: levelButtonXPosition, y: 350 - 75 * buttonCount)
            buttonCount += 1
            buttonLevel.zPosition = 1
            levelButtons.append(buttonLevel)
            moveableArea.addChild(buttonLevel)
            
            // Add text to the level button:
            let textLevel = text.copy() as! SKLabelNode
            textLevel.text = "Level \(i)"
            textLevel.verticalAlignmentMode = .center
            textLevel.position = CGPoint(x: 0, y: 2)
            textLevel.fontSize = 40
            textLevel.zPosition = 2
            textLevel.name = "buttonLevel_\(i)"
            buttonLevel.addChild(textLevel)
        }
        return levelButtons
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // MARK: Scroll setting
        let touch = touches.first
        let location = touch!.location(in: self)
        // set the new location of touch
        let currentY = location.y
        
        // Set Top and Bottom scroll distances, measured in screenlengths
        let topLimit:CGFloat = 0
        let bottomLimit:CGFloat = 2
        
        // Set scrolling speed - Higher number is faster speed
        let scrollSpeed:CGFloat = 1.0
        
        // calculate distance moved since last touch registered and add it to current position
        // reserve scroll direction by Multiply -1 with distance
        let newY = moveableArea.position.y + ((currentY - lastY)*scrollSpeed)
        
        // perform checks to see if new position will be over the limits, otherwise set as new position
        if newY < self.size.height*(-topLimit) {
            moveableArea.position = CGPoint(x: moveableArea.position.x,y: self.size.height*(-topLimit))
        }
        else if newY > self.size.height*bottomLimit {
            moveableArea.position = CGPoint(x: moveableArea.position.x,y: self.size.height*bottomLimit)
            buttonDown.removeAllActions()
            buttonDown.alpha = 0
        }
        else {
            moveableArea.position = CGPoint(x: moveableArea.position.x,y: newY )
        }
        
        // Set new last location for next time
        lastY = currentY
    }
    
    func presentGameScene(chosenLevel: Int){
        if currentLevel >= chosenLevel {
            // gameViewController -> menuScene -> gameScene
            let gameScene = GameScene(size: self.size, chosenLevel: chosenLevel )
            // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
            gameScene.viewController = self.viewController
            // Player touched the start text oe button node:
            self.view?.presentScene(gameScene)
        }
    }
    
    func getCurrentLevel() {
        let saveGameData = UserDefaults.standard
        currentLevel = saveGameData.value(forKey: "CurrentLevel") as! Int
        print("curent level \(currentLevel)")
    }
    
    func scrollToCurrentLevel() {
        let scrollToLevelButton = SKAction.moveTo(y: self.frame.maxY * 0.2 * CGFloat(currentLevel), duration: 1)
        scrollToLevelButton.timingMode = SKActionTimingMode.easeInEaseOut
        moveableArea.run(scrollToLevelButton)
    }
    //MARK: - Change Pages
    @objc func moveToPreviousLevelPage() {
        pageIndex -= 1
        
        if pageIndex < 0 {
            pageIndex = 0
        }
        self.addPageButtonsAnimation()
        let moveToPreviousPage = SKAction.move(to: CGPoint(x: CGFloat(pageIndex) * -viewSize.width, y: 0), duration: 0.5)
        
        moveableArea.run(moveToPreviousPage)
    }
    
    @objc func moveToNextLevelPage() {
        pageIndex += 1
        
        if pageIndex > maxpageIndex {
            pageIndex = maxpageIndex
        }
        self.addPageButtonsAnimation()
        let moveToNextPage = SKAction.move(to: CGPoint(x: CGFloat(pageIndex) * -viewSize.width, y: 0), duration: 0.5)
        
        moveableArea.run(moveToNextPage)
    }
    
    func addButtonAlpha(levelButtons: [SKSpriteNode]) {
        if currentLevel < levelButtons.count - 1 {
            for i in currentLevel...levelButtons.count - 1 {
                levelButtons[i].alpha = 0.5
            }
        }
    }
    
    func createAnimations() {
        let fadeOutGroup = SKAction.group([
            SKAction.fadeAlpha(to: 0.1, duration: 1.5)//,
            //SKAction.scale(to: 0.8, duration: 2)
        ]);
        let fadeInGroup = SKAction.group([
            SKAction.fadeAlpha(to: 0.4, duration: 1.5)//,
            //SKAction.scale(to: 1, duration: 2)
        ]);
        let fadeSequence = SKAction.sequence([fadeOutGroup, fadeInGroup])
        fadeAnimation = SKAction.repeatForever(fadeSequence)
    }
    
    func addPageButtonsAnimation() {
        if pageIndex == 0 {
            buttonLeft.removeAllActions()
            buttonLeft.alpha = 0
        }else {
            buttonLeft.run(fadeAnimation)
        }
        
        if pageIndex == maxpageIndex {
            buttonRight.removeAllActions()
            buttonRight.alpha = 0
        }else {
            buttonRight.run(fadeAnimation)
        }
        
        buttonDown.run(fadeAnimation)
    }
}

