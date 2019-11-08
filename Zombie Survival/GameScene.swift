//
//  GameScene.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 2/21/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let screenSize = UIScreen.main.bounds
    var renderView: RenderView!
    
    // MARK: - enum
    fileprivate enum ScreenEdge: Int {
        case top = 0
        case right = 1
        case bottom = 2
        case left = 3
    }
    
    var rawPoints: [Int] = []
    var recognizer = DBPathRecognizer()
    var gesture: PathModel? = nil
    var gestureName: String = ""
    
    let world = SKNode()
    let hud = HUD()
    let player = Player()
    
    var viewController : GameViewController!
    
    var encounterManager = EncounterManager()
    var encounterIndex = 0 // default: 0
    
    //var generateGhostTimer:Timer? = nil
    var bossAttackTimer:Timer? = nil

    var dieSound = SKAction()
    var lightingSound = SKAction()
    
    var chosenLevel = 1
    
    // LV1 TUTORIAL
    var tutorialStep = 1
    var isdoneTutorial = false
    var isLv1ShowReadyLabel = false
    var isLv1StartSpawnEnemy = false
    
    var isBeginPlay = false
    var isGameOver = false
    var isVictory = false
    
    var attackTimer:Timer! // lv5 only
    
    var comboTimer:Timer!
    var comboValue = 0 {
        didSet {
            if comboValue > oldValue {
                if comboTimer != nil {
                    comboTimer.invalidate()
                }
                comboTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:  #selector(displayAndResetComboValue), userInfo: nil, repeats: false)
            }
        }
    }
   
    convenience init(size:CGSize, chosenLevel: Int) {
        self.init(size: size)
        self.chosenLevel = chosenLevel
        self.encounterManager.setEncounterNameBy(chosenLevel: chosenLevel)
        print("start at level: \(chosenLevel) encounter count: \(encounterManager.encounterCount)")
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    override func didMove(to view: SKView) {
        // remove gesture recognizers from previous scene for better performance
        self.removeAllGestureRecognizers()
        
        self.view?.showsFPS = true
        self.view?.showsPhysics = true
        
        setGestureModel()
        
        world.name = "world"
        self.addChild(world)
        self.addSoundToScene()
        self.physicsWorld.contactDelegate = self
        
        self.getPlayerStats()
        
        hud.createHudNode(score: Int(player.score), coinCollected: player.coinCollected)
        self.addChild(hud)
        hud.zPosition = 100

        if chosenLevel == 1 {
            hud.makeTutorialNode()
        }
        
        let background = SKSpriteNode(imageNamed: "Background_\(chosenLevel).png")
        background.zPosition = -1
        background.size = CGSize(width: self.size.width, height: self.size.height)
        background.position = CGPoint(x: 0, y: 0)
        world.addChild(background)
        
        self.spawnPlayer()
        
        /*let arrow = Arrow()
        arrow.spawn(parentNode: world, position: CGPoint(x:550, y:150))*/
        
        
        /*let ghost = Ghost()
        ghost.spawn(parentNode: world, position: CGPoint(x:650, y:150), maxGestureNumber: 1, delayTime: 1, isLighting: false, moveToPoint: CGPoint.zero, moveDuration: 100, gestureList: "pq")
         */
       /* let bossLv7 = BossLv7()
        bossLv7.spawn(parentNode: world, position: CGPoint(x:650, y:150), moveDuration: 100, moveToPoint: CGPoint.zero, gestureList: "000") */
        
        /*let orkTest = OrkCaptain()
        orkTest.spawn(parentNode: world, position: CGPoint(x:650, y:150), maxGestureNumber: 3, delayTime: 3, isLighting: false, moveToPoint: CGPoint.zero, moveDuration: 10, doubleGestureList: "123|320")
        */
        //random
        //generateGhostTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(generateGhost), userInfo: nil, repeats: true)

    }
    
    func spawnPlayer() {
        switch chosenLevel {
        case 1:
            player.spawn(parentNode: world, position: CGPoint(x: -screenSize.width/2, y: 0), hud: self.hud) {
                self.player.playWalkInCenterAnimation {
                    self.player.playStandingAnimation {
                        self.showTutorial(step: 1)
                    }
                }
            }

        case 5:
            player.spawn(parentNode: world, position: CGPoint(x: -screenSize.width/4, y: 0), hud: self.hud) {
                self.player.setScale(0.5)
                self.player.addFlyBroom()
                self.player.playFlyAnimation()
                self.isBeginPlay = true
                self.hud.show()
                // auto add enemy at begin
                self.addEnemiesToWorld()
            }
        default:
            player.spawn(parentNode: world, position: CGPoint(x: -screenSize.width/2, y: 0), hud: self.hud) {
                self.player.playWalkInCenterAnimation {
                    self.player.playStandingAnimation {
                        self.hud.showReadyLabel(level: self.chosenLevel) {
                            self.hud.show()
                            self.isBeginPlay = true
                            self.addEnemiesToWorld()
                        }
                    }
                }
            }
        }
    }

    func removeAllGestureRecognizers(){
        for recognizer in self.view!.gestureRecognizers!{
            self.view!.removeGestureRecognizer(recognizer);
        }
    }
    
    // MARK: - Set gesture model
    func setGestureModel() {
        // init recognizer instance:
        recognizer = DBPathRecognizer(sliceCount: 8, deltaMove: 64.0)
        
        recognizer.addModel(PathModel(directions: [7,7,1,1], datas: "upArrow" as AnyObject))
        //recognizer.addModel(PathModel(directions: [5,3], datas: "upArrow" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [1,1,7,7], datas: "downArrow" as AnyObject))
        //recognizer.addModel(PathModel(directions: [3,5], datas: "downArrow" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [0], datas: "right" as AnyObject))
        recognizer.addModel(PathModel(directions: [4], datas: "right" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [2], datas: "down" as AnyObject))
        recognizer.addModel(PathModel(directions: [6], datas: "down" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [3,1], datas: "leftArrow" as AnyObject))
        recognizer.addModel(PathModel(directions: [5,7], datas: "leftArrow" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [1,3], datas: "rightArrow" as AnyObject))
        recognizer.addModel(PathModel(directions: [7,5], datas: "rightArrow" as AnyObject))
       
        recognizer.addModel(PathModel(directions: [3,0,3], datas:"lighting" as AnyObject))
        recognizer.addModel(PathModel(directions: [3,3,0,0,3,3], datas:"lighting" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [5,4,3,2,1,7,6,5,4,3], datas: "heart" as AnyObject))
        recognizer.addModel(PathModel(directions: [7,0,1,2,3,5,6,7,0,1], datas: "heart" as AnyObject))
        recognizer.addModel(PathModel(directions: [5,6,7,0,1,7,0,1,2,3], datas: "heart" as AnyObject))
        recognizer.addModel(PathModel(directions: [7,6,5,4,3,5,4,3,2,1], datas: "heart" as AnyObject))
        
        if self.chosenLevel == 8 {
        // MARK: *NEW GESTURES
        
        recognizer.addModel(PathModel(directions: [1,2,3,5,6,7], datas:"downFish" as AnyObject))
        recognizer.addModel(PathModel(directions: [3,2,1,7,6,5], datas:"downFish" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [7,6,5,3,2,1], datas:"upFish" as AnyObject))
        recognizer.addModel(PathModel(directions: [5,6,7,1,2,3], datas:"upFish" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [7,1,7,1], datas:"m" as AnyObject))
        recognizer.addModel(PathModel(directions: [7,7,1,1,7,7,1], datas:"m" as AnyObject))

        recognizer.addModel(PathModel(directions: [1,7,1,7], datas:"w" as AnyObject))
        recognizer.addModel(PathModel(directions: [1,1,7,7,1,1,7,7], datas:"w" as AnyObject))
        
        /* recognizer.addModel(PathModel(directions: [4,3,2,1,0,4,3,2,1,0], datas:"E" as AnyObject))
         recognizer.addModel(PathModel(directions: [0,1,2,3,4,0,1,2,3,4], datas:"EReserved" as AnyObject))
         */
        recognizer.addModel(PathModel(directions: [3,2,1,0,7,6,5,3,2,2], datas:"pRight" as AnyObject))
        recognizer.addModel(PathModel(directions: [3,1,0,7,5,4,2,2], datas:"pRight" as AnyObject))
        recognizer.addModel(PathModel(directions: [1,2,3,4,5,6,7,1,2,2], datas:"pLeft" as AnyObject))
        recognizer.addModel(PathModel(directions: [1,3,4,5,7,0,2,2], datas:"pLeft" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [6,1,6], datas:"n" as AnyObject))
        recognizer.addModel(PathModel(directions: [6,6,1,1,6,6], datas:"n" as AnyObject))
        recognizer.addModel(PathModel(directions: [2,7,2], datas:"nReserved" as AnyObject))
        recognizer.addModel(PathModel(directions: [2,2,7,7,2,2], datas:"nReserved" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [2,2,3,4,5,6,7,0,0,0,7,6,5,4,3,2,2], datas:"dogRight" as AnyObject))
        recognizer.addModel(PathModel(directions: [2,2,3,5,7,0,0,0,7,5,3,2,2], datas:"dogRight" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [6,6,5,4,3,2,1,0,0,0,1,2,3,4,5,6,6], datas:"dogLeft" as AnyObject))
        recognizer.addModel(PathModel(directions: [6,6,5,3,1,0,0,0,1,3,5,6,6], datas:"dogLeft" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [0,0,7,6,5,4,3,2,2,2,3,4,5,6,7,0,0], datas:"boyRight" as AnyObject))
        recognizer.addModel(PathModel(directions: [0,0,7,6,4,3,2,2,3,4,5,7,0,0], datas:"boyRight" as AnyObject))
        recognizer.addModel(PathModel(directions: [0,0,5,4,3,2,2,3,4,7,0,0], datas:"boyRight" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [4,4,5,6,7,0,1,2,2,2,1,0,7,6,5,4,4], datas:"boyLeft" as AnyObject))
        recognizer.addModel(PathModel(directions: [4,4,7,0,1,2,2,1,0,5,4,4], datas:"boyLeft" as AnyObject))
        
        recognizer.addModel(PathModel(directions: [2,2,3,4,5,6,7,0,0,0,1,2,3,4,5,6,6], datas:"nose" as AnyObject))
        recognizer.addModel(PathModel(directions: [2,2,3,4,5,7,0,0,1,3,5,6,6], datas:"nose" as AnyObject))
                
        recognizer.addModel(PathModel(directions: [6,6,5,4,3,2,1,0,0,0,7,6,5,4,3,2,2], datas:"noseReserved" as AnyObject))
        recognizer.addModel(PathModel(directions: [6,6,5,4,3,1,0,0,7,5,3,2,2], datas:"noseReserved" as AnyObject))

        recognizer.addModel(PathModel(directions: [0,3,0], datas:"z" as AnyObject))
        recognizer.addModel(PathModel(directions: [0,0,3,3,0,0], datas:"z" as AnyObject))
        //self.recognizer = recognizer
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rawPoints = []
        gesture = nil // reset gesture
        let touch = touches.first
        let location = touch!.location(in: self)
        let nodeTouched = atPoint(location)
        let touchLocationinView = convertPoint(toView: location)
        rawPoints.append(Int(touchLocationinView.x))
        rawPoints.append(Int(touchLocationinView.y))
        
        //print(nodeTouched.name ?? "nil or noname")
        
        if nodeTouched is Coin {
            let coin = nodeTouched as! Coin
            coin.onTap()
            player.coinCollected += 1
            hud.setcoinCountDisplay(newCoinCount: player.coinCollected)
        }
        
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
            let menuScene = MenuScene(size: self.size)
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch!.location(in: view)
        if (rawPoints[rawPoints.count - 2]) != Int(location.x) && rawPoints[rawPoints.count - 1] != Int(location.y) {
            rawPoints.append(Int(location.x))
            rawPoints.append(Int(location.y))
        }
       // print("rawPoints .count:\(rawPoints.count)")

        if rawPoints.count >= 1 { // drawn gesture long enought to avoid single point gesture
            self.viewController.renderView.setPointsToDraw(drawPoints: rawPoints)
            var path: Path = Path()
            path.addPointFromRaw(rawPoints)
            gesture = self.recognizer.recognizePath(path)

        } /*else {
            gesture = nil
        }*/
        if gesture != nil {
            gestureName = (gesture!.datas as? String)!
            self.viewController.renderView.gestureName = gestureName
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gesture != nil && rawPoints.count > 2 {
            self.playerRunSpellAnimations()
            
            if !isVictory {
                self.removeAllDeadEnemies()
            }
        } else {
            print("Unable to recognize gesture")
        }
        self.viewController.renderView.clear()
    }
 
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch cancelled")
        self.viewController.renderView.clear()
    }
    
    func spawnSupporter() {
        if let _ = world.childNode(withName: "healer") as? Supporter {
            // if there is a supporter already, do nothing.
            return
        }else {
            // if not, create a supporter random y position
           // let randomY = CGFloat(arc4random_uniform(UInt32(screenSize.height/2))) - CGFloat(screenSize.height/2)
            let supporter = Supporter()
            supporter.spawn(parentNode: world, position: CGPoint(x:-screenSize.width/2 + 80, y: 0), delayTime: 0)
            if chosenLevel == 5 || chosenLevel == 9{
                supporter.setScale(0.5)
            }
        }
    }
    
    // MARK: - Collistion handler
    func didBegin(_ contact: SKPhysicsContact) {
        // Each contact has two bodies; we do not know which is which.
        // We will find the player body, then use
        // the other body to determine the type of contact.
        let otherBody:SKPhysicsBody
        // Combine the two penguin physics categories into one
        // bitmask using the bitwise OR operator |
        let playerMask = PhysicsCategory.player.rawValue | PhysicsCategory.damagedPlayer.rawValue
        
        // Use the bitwise AND operator & to find the penguin.
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
        case PhysicsCategory.creep.rawValue:
            // get node from physics body
            let touchedEnemy = otherBody.node
            if touchedEnemy is Creep, var creep = touchedEnemy as! Creep? {
                creep.pBody = nil
                creep.attack()
                print("take damage")
                player.takeDamage()
                hud.setHealthDisplay(newHealth: player.health)
                self.spawnSupporter()
            }
        case PhysicsCategory.boss.rawValue:
            print("hit by boss")
            let touchedEnemy = otherBody.node
            if touchedEnemy is Boss, let boss = touchedEnemy as! Boss? {
                boss.attack{
                    self.player.takeDamage()
                    boss.moveBack(outOfGesture: false)
                    self.hud.setHealthDisplay(newHealth: self.player.health)
                    self.spawnSupporter()
                }
            }
        case PhysicsCategory.miniBoss.rawValue:
            let touchedEnemy = otherBody.node
            if touchedEnemy is MiniBoss, var miniBoss = touchedEnemy as! MiniBoss? {
                miniBoss.pBody = nil
                miniBoss.attack()
                player.takeDamage()
                hud.setHealthDisplay(newHealth: player.health)
                self.spawnSupporter()
            }
        case PhysicsCategory.projectiles.rawValue:
            let touchedEnemy = otherBody.node
            if touchedEnemy is Arrow, let arrow = touchedEnemy as! Arrow? {
                //.pBody = nil
                arrow.removeFromParent()
                player.takeDamage()
                hud.setHealthDisplay(newHealth: player.health)
                self.spawnSupporter()
            }

        default:
            print("Contact with no game logic")
        }
    }
    

     /* func generateGhost() {
        // Generate an enemy with radom position
        let screenEdge = ScreenEdge.init(rawValue: Int(arc4random_uniform(4)))
        let screenBounds = UIScreen.main.bounds // tra ve CGRect chua kich thuoc man hinh
        var position: CGFloat = 0
        
        switch screenEdge! {
        case .left, .right:
            position = CGFloat(arc4random_uniform(UInt32((screenBounds.height))))
        //   print(position)
        case .top, .bottom:
            position = CGFloat(arc4random_uniform(UInt32((screenBounds.width))))
            //  print(position)
        }
        // Add the new enemy to the view
        switch screenEdge! {
        case .left:
            ghost.spawn(parentNode: world, position: CGPoint(x: 0, y: position), maxGestureNumber: self.maxGestureNumber)
        case .right:
            ghost.spawn(parentNode: world, position: CGPoint(x:(screenBounds.width), y: (screenBounds.height)),maxGestureNumber: self.maxGestureNumber)
        case .top:
            ghost.spawn(parentNode: world, position: CGPoint(x: position, y: (screenBounds.height)),maxGestureNumber: self.maxGestureNumber)
        case .bottom:
            ghost.spawn(parentNode: world, position: CGPoint(x: position, y: 0), maxGestureNumber: self.maxGestureNumber)
        }
 
    }
    */
    
    // MARK: - Remove enemy nodes
    func removeAllDeadEnemies() {
        //Iterate All Sprite Nodes
        for node in world.children {
            if node is Creep, let creep = node as? Creep{
                if creep.isDisplayed {
                    // if node name is zombie, iterate all its children
                    for gesture in creep.getChildren() {
                        // if children node has same name as gesture, remove it
                        if gesture.name == gestureName && !player.isDead && isBeginPlay {
                            if gestureName == "lighting" {
                                comboValue += self.castLightingSpell()
                            }else {
                                gesture.removeFromParent()
                                creep.takeDamage()
                               // enemy.updateGesturePosition()
                                
                                if chosenLevel == 1 {
                                    self.tutorialHandle()
                                }
                            }
                            break // only remove 1 gesture image
                        }
                        break // remove first gesture only
                    }
                    // if enemy node remain no child, remove it
                    if creep.getGestureNumber() == 0 && !creep.isDie {
                        creep.die()
                        world.run(dieSound)
                        comboValue += 1
                    }
                }
            }
            
            if node is MiniBoss, let miniBoss = node as? MiniBoss {
                if miniBoss.isDisplayed {
                    for gesture in miniBoss.getChildren() {
                        if gesture.name == gestureName && !player.isDead && isBeginPlay {
                            if gestureName == "lighting" {
                                comboValue += self.castLightingSpell()
                            }else {
                                gesture.removeFromParent()
                                miniBoss.takeDamage()
                            }
                            break // only remove 1 gesture image
                        }
                        break // remove first gesture only
                    }
                    if miniBoss.getGestureNumber() == 0 && miniBoss.reSpawnCount == 0 { // run out of gesture for first time
                        miniBoss.moveBack()
                    } else if miniBoss.getGestureNumber() == 0 && miniBoss.reSpawnCount == 1 {
                        miniBoss.die()
                        world.run(dieSound)
                        comboValue += 2
                    }
                }
            }
            
            if node is Supporter, let supporter = node as? Supporter {
                if gestureName == "heart" && !player.isDead {
                    if let heartNode = supporter.childNode(withName: "heart") {
                        supporter.healing()
                        if player.health < 5 {
                            player.health += 1
                        }
                        hud.setHealthDisplay(newHealth: player.health)
                        heartNode.removeFromParent()
                    }
                }
            }
            
            if node is Boss, var boss = node as? Boss{
                // if node name is zombie, iterate all its children
                for gesture in boss.getChildren(){
                    // if children node has same name as gesture, remove it
                    if(gesture.name == gestureName) && !player.isDead {
                        if gestureName == "lighting"{
                            comboValue += castLightingSpell()
                            boss.takeDamage()
                        }
                        gesture.removeFromParent()
                        boss.updateGesturePosition()
                        // bosslv5 and bosslv9 only take damage when cast lighting gesture
                        if chosenLevel != 5 || chosenLevel != 9 {
                            boss.takeDamage()
                        }
                        break // only remove 1 gesture image
                    }
                    break // remove first gesture only
                }
                if chosenLevel == 2 || chosenLevel == 5 || chosenLevel == 9 {
                    // in level 2, 5, 9 boss handler in Update() function
                }
               
                // if enemy node remain no child, remove it
                else if boss.getGestureNumber() == 0 {
                    self.player.score += 25
                    boss.health -= 1

                    hud.setScoreCountDisplay(newScoreCount: Int(player.score))
                    if boss.health > 0 {
                        boss.moveBack(outOfGesture: true)
                    }
                    else{
                        if let support = world.childNode(withName: "healer") as? Supporter {
                            support.removeFromParent()
                        }
                
                        self.runVictoryAnimation(boss: boss)
                    }
                }
            }
        }

    }
    
    func castLightingSpell() -> Int {
       // let dispatchQueue = DispatchQueue(label: "remove_Then_UpdatePosition")
        var comboCount = 0
        // MARK: For lighting Gesture
        for node in world.children {
            if node is Enemy, let enemy = node as? Enemy{
                if enemy.isDisplayed {
                    // if node name is zombie, iterate all its children
                    for gesture in enemy.getChildren() {
                        // if children node has same name as gesture, remove it
                        gesture.removeFromParent()
                        let specialEffects = SpecialEffects()
                        specialEffects.spawn(parentNode: enemy as! SKSpriteNode, type: "lighting")
                        enemy.takeDamage()
                        break // only remove 1 gesture image
                    }
                    enemy.updateGesturePosition()
                    
                    // if enemy node remain no child, remove it
                    if enemy.getGestureNumber() == 0 && enemy.isDisplayed && !enemy.isDie {
                        enemy.die()
                        comboCount += 1
                    }
                }
            }
        }
        
        if let boss = world.childNode(withName: "boss") as? Boss {
            let specialEffects = SpecialEffects()
            specialEffects.spawn(parentNode: boss as! SKSpriteNode, type: "lighting")
        }
        world.run(lightingSound)
        return comboCount
    }
    
    func removeAllRemainEnemy() { // remove all remain enemy nodes after boss die
        for node in world.children {
            if node is Ghost || node is Supporter {
                node.removeFromParent()
            }
        }
    }
    
    // MARK: - Calculate combo value
    @objc func displayAndResetComboValue() {
        if comboValue > 1 {
            self.player.score += 10 * comboValue * comboValue
            // show combo shape node
            hud.setComboValue(comboValue: comboValue)
        }
        else if comboValue == 1 {
            self.player.score += 10
        }
        comboValue = 0
        hud.setScoreCountDisplay(newScoreCount: self.player.score)
    }
    
    func tutorialHandle() {
        self.tutorialStep += 1
        //print("tutor step: \(tutorialStep)")
        if tutorialStep == 2 {
            self.hideTutorial()
            self.showTutorial(step: self.tutorialStep) // 2
        }
        if self.tutorialStep > 2 {
            self.isdoneTutorial = true
        }
    }
    
    func runVictoryAnimation(boss: Boss) {
        self.isVictory = true
        removeAllRemainEnemy()
        // let internalQueue = DispatchQueue.global(qos: .userInteractive)
        // run boss die animation -> self.updatePlayerStats function -> player victory animation
        // boss.die completion handler has declarated inside function using typealias
        boss.die { () -> () in
            self.hud.hide()
            SKTAudio.sharedInstance().pauseBackgroundMusic()
            SKTAudio.sharedInstance().playSoundEffect("level_done.wav") {
                self.player.victory {
                    self.updatePlayerStats {
                        //self.presentLevelMenu()
                        self.presentNextGameLevel()
                    }
                }
            }
        }
    }
    
    func playerRunSpellAnimations() {
        if !player.isDead && !isVictory {
            switch gestureName {
            case "down":
                player.castDownGestureSpell()
            case "upArrow":
                player.castUpArrowSpell()
            case "downArrow":
                player.castDownArrowSpell()
            case "right":
                player.castRightGestureSpell()
            case "lighting":
                player.castLightingSpell()
            case "heart":
                player.castHealingSpell()
            default:
                print("error gesture name: \(gestureName) check gameScene.swift")
            }
        }
    }
    func addSoundToScene() {
        //SKTAudio.sharedInstance().pauseBackgroundMusic()
        //Add background music to scene
        if chosenLevel == 5 {
        // Background music played from intro
           //SKTAudio.sharedInstance().playBackgroundMusic("main-2.wav")
        }
        else {
            SKTAudio.sharedInstance().playBackgroundMusic("main_background.mp3")
        }
        
        // run diesound here to improve performance
        self.dieSound = SKAction.playSoundFileNamed("one_enemy_die.wav", waitForCompletion: false)
        
        self.lightingSound = SKAction.playSoundFileNamed("lighting.wav", waitForCompletion: false)
    }
    
    func addEnemiesToWorld() {
        // if encounters number reached, stop spawning enemy
        if encounterIndex < encounterManager.encounterCount {
            // add encounter to world, encounter contain all enemy node
            encounterManager.addEnemiesTo(world: self.world, encounterIndex: encounterIndex, moveToPoint: player.position) // move to player position
            print("encounter index: \(encounterIndex)")
            encounterIndex += 1
        }
    }
    
    /*func startTimer(){
        //MARK: - Start timer
       // generateGhostTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(addEnemiesToWorld), userInfo: nil, repeats: true)
    }*/
    // MARK: * PLAYER STATS
    
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
        if chosenLevel == 4 {
            let level5_Intro = Level5_Intro(fileNamed: "Level5_Intro")
            level5_Intro?.viewController = self.viewController
            self.view?.presentScene(level5_Intro)
        }
        else {
            print("present next level")
            // gameViewController -> menuScene -> gameScene
            let gameScene = GameScene(size: self.size, chosenLevel: self.chosenLevel + 1)
            // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
            gameScene.viewController = self.viewController
            let pushTransition = SKTransition.push(with: .left, duration: 1)
            self.view?.presentScene(gameScene, transition: pushTransition)
        }
    }
    
    func presentLevelMenu() {
        print("present new game scene")
        // gameViewController -> menuScene -> gameScene
        let levelMenu = LevelMenu(size: self.size)
        // Set gamescene.viewController same as menuScene.viewController to use renderView to draw gesture
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
        for child in world.children {
            if child is Creep || child is Enemy || child is Boss || child is Supporter || child is Coin || child is MiniBoss {
                child.removeFromParent()
            }
        }
    }
    
    func reloadGame() {
        //startTimer()
        encounterIndex = 0
        player.health = 5
        player.isDead = false
        player.createPhysicBody() // re-create physic body
        hud.setHealthDisplay(newHealth: player.health)
        player.score = 0
        hud.setScoreCountDisplay(newScoreCount: player.score)
        hud.hidePauseMenu()
        hud.show()
        self.isGameOver = false
        world.isPaused = false
        self.addEnemiesToWorld()
    }
    
    func convert(point: CGPoint)->CGPoint {
        return self.view!.convert(CGPoint(x: point.x, y:self.view!.frame.height-point.y), to:self)
    }
    
    func runCode(delay timeInterval:TimeInterval, _ code:@escaping ()->(Void)) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + timeInterval,
            execute: code
        )
    }
    
    func isEnemyRemain() -> Bool {
        // MARK: CHECK THIS FUNCTION AFTER ADD NEW ENEMY CLASS
        var isThereEnemy = false
        for enemy in world.children {
            if enemy is Enemy || enemy is Creep || enemy is MiniBoss {
                isThereEnemy = true
                return isThereEnemy
            }
        }
        return isThereEnemy
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !isGameOver && isBeginPlay{
            // if there is ghost, do nothing
            /*if let _ = world.childNode(withName: "ghost") {
                print ("there is enemy")
            }*/
            if isEnemyRemain() { // true if there is any enemies
                // do nothing
            }
            else if chosenLevel == 1 {
                self.level1Handler()
            }
            else if chosenLevel == 2 {
                self.bossLv2Handle()
            }
            // if there is no ghost, and level = 5
            else if chosenLevel == 5 { // boss Lv5 has special handler
                self.bossLv5Handle()
            }
            else if chosenLevel == 9 {
                self.bossLv9Handle()
            }
            else {
                // if not, add more enemy to world
                self.addEnemiesToWorld()
            }
        }
    }
    
    func level1Handler() {
         if isdoneTutorial && !isLv1ShowReadyLabel {
            self.hideTutorial()
            self.isLv1ShowReadyLabel = true
            self.hud.showReadyLabel(level: self.chosenLevel) {
                self.hud.show()
                self.isLv1StartSpawnEnemy = true
            }
        }

        if let _ = world.childNode(withName: "ghost") {
            
        } else if isLv1StartSpawnEnemy {
            self.addEnemiesToWorld()
        }
    }
    
    // MARK: - BOSS LV2 BEHAVIOR
    func bossLv2Handle() {
        if let boss = world.childNode(withName: "boss") as? BossLv2 {
            //print("boss gesture number: \(boss.getGestureNumber())")
            if !(boss.health > 0) && !boss.isDie{
                boss.isDie = true
                print("boss died \(boss.isDie)")
                self.runVictoryAnimation(boss: boss)
            }
            else if boss.getGestureNumber() == 0 && !boss.isDie {
                print("is boss die: \(boss.isDie)")
                if boss.spawnCount % 2 == 0 && boss.health > 0{
                    boss.moveBack(outOfGesture: true)
                    boss.spawnCount += 1
                    boss.health -= 1
                    print("gesture added to boss, increase Spawn Count to: \(boss.spawnCount)")
                } else if boss.spawnCount % 2 != 0 && boss.health > 0{
                    boss.spawnCount += 1
                    boss.stopMoveToCenter()
                    boss.runSpawnAnimation()
                    self.addEnemiesToWorld()
                    print("all enemy killed, Spawn Count: \(boss.spawnCount)")
                }
            }
        }
        else {
            self.addEnemiesToWorld()
        }
    }
    
    // MARK: - BOSS LV5 BEHAVIOR
    func bossLv5Handle() {
        if let boss = world.childNode(withName: "boss") as? BossLv5 {
            if !(boss.health > 0) && !boss.isDie{
                boss.isDie = true
               // print("boss died \(boss.isDie)")
                boss.die {
                    self.presentLevel5Ending()
                }
            }
            else if boss.getGestureNumber() == 0 && !boss.isDie {
                //print("is boss die: \(boss.isDie)")
                if boss.spawnCount % 2 == 0 && boss.health > 0{
                    boss.moveBack(outOfGesture: true)
                    //boss.addGestureImage(gestureNumber: 1)
                    boss.health -= 1
                    // boss LV5 attack repeatly each 5 seconds, timer start after add gesture
                    self.attackTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(bosslv5Attack(_:)), userInfo: ["boss":boss], repeats: true)
                } else {
                    self.addEnemiesToWorld()
                    // cancel attack when spawn more enemy
                    self.attackTimer.invalidate()
                }
                boss.spawnCount += 1
                //print("Spawn Count: \(boss.spawnCount)")
            }
        }
    }
    
    @objc func bosslv5Attack(_ timer: Timer) { // this function pass timer as parameter, boss node pass as dictonary param
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        let boss:BossLv5 = (userInfo["boss"] as! BossLv5)
        boss.attack {
            self.player.takeDamage()
            self.hud.setHealthDisplay(newHealth: self.player.health)
        }
    }
    
    // MARK: - BOSS LV5 BEHAVIOR
    func bossLv9Handle() {
        if let boss = world.childNode(withName: "boss") as? BossLv9 {
            if !(boss.health > 0) && !boss.isDie{
                boss.isDie = true
                // print("boss died \(boss.isDie)")
                boss.die {
                    //self.presentLevel5Ending()
                }
            }
            else if boss.getGestureNumber() == 0 && !boss.isDie {
                //print("is boss die: \(boss.isDie)")
                if boss.spawnCount % 2 == 0 && boss.health > 0{
                    boss.moveBack(outOfGesture: true)
                    //boss.addGestureImage(gestureNumber: 1)
                    boss.health -= 1
                    // boss LV5 attack repeatly each 5 seconds, timer start after add gesture
                    self.attackTimer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(bosslv9Attack(_:)), userInfo: ["boss":boss], repeats: true)
                } else {
                    self.addEnemiesToWorld()
                    // cancel attack when spawn more enemy
                    self.attackTimer.invalidate()
                }
                boss.spawnCount += 1
                //print("Spawn Count: \(boss.spawnCount)")
            }
        }
    }
    
    @objc func bosslv9Attack(_ timer: Timer) { // this function pass timer as parameter, boss node pass as dictonary param
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        let boss:BossLv9 = (userInfo["boss"] as! BossLv9)
        boss.attack {
            self.player.takeDamage()
            self.hud.setHealthDisplay(newHealth: self.player.health)
        }
    }

    
    func presentLevel5Ending() {
        let level5_Ending = Level5_Ending(fileNamed: "Level5_Ending")
        level5_Ending?.viewController = self.viewController
        updatePlayerStats {
            self.view?.presentScene(level5_Ending)
        }
    }
    
    func showTutorial(step: Int) {
        var cursorHandAnimation = SKAction()
        let ghostPosition = CGPoint(x: screenSize.width/2, y: 0)
        let path = UIBezierPath()
        
        if step == 1 {
            let ghost = Ghost()
            ghost.spawn(parentNode: world, position: ghostPosition, maxGestureNumber: 1, delayTime: 1, isLighting: false, moveToPoint: CGPoint(x: 150, y: 0), moveDuration: 2, gestureList: "0")
            
            let swipeLeft = SKAction.move(to: CGPoint(x: 170, y: -80), duration: 1)
            let backRight = SKAction.move(to: CGPoint(x: -170, y: -80), duration: 0)
            let swipeLeftSequence = SKAction.sequence([swipeLeft, backRight])
            cursorHandAnimation = SKAction.repeatForever(swipeLeftSequence)
            
            path.move(to: self.convertPoint(toView: CGPoint(x: -170, y: -80)))
            path.addLine(to: self.convertPoint(toView: CGPoint(x: 170, y: -80)))

        }
        else if step == 2 { // tutorial step 2
            hud.cursorHand.position = CGPoint(x: 180, y: 100)
            hud.shapeLayer.fillColor = UIColor.blue.cgColor
            hud.shapeLayer.strokeColor = UIColor.blue.cgColor
            
            let ghost = Ghost()
            ghost.spawn(parentNode: world, position: ghostPosition, maxGestureNumber: 1, delayTime: 1, isLighting: false, moveToPoint: CGPoint(x: 150, y: 0), moveDuration: 2, gestureList: "1")
            
            let swipeDown = SKAction.move(to: CGPoint(x: 180, y: -100), duration: 1)
            let backUp = SKAction.move(to: CGPoint(x: 180, y: 100), duration: 0)
            let swipeDownSequence = SKAction.sequence([swipeDown, backUp])
            cursorHandAnimation = SKAction.repeatForever(swipeDownSequence)
            
            path.move(to: self.convertPoint(toView: CGPoint(x: 220, y: 85)))
            path.addLine(to: self.convertPoint(toView: CGPoint(x: 220, y: -85)))
        }
    
        // shape layer for that path created in hud.swift
        // animate it
        self.view?.layer.addSublayer(hud.shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 1
        animation.repeatCount = .infinity
        
        runCode(delay: 1) {
            self.player.scared()
        }
        
        runCode(delay: 2) {
            self.addChild(self.hud.tutorialDialog)
        }
        
        runCode(delay: 3.5) {
            if !self.isdoneTutorial {
                self.addChild(self.hud.cursorHand)
                self.hud.cursorHand.run(cursorHandAnimation)
                self.hud.shapeLayer.path = path.cgPath
                self.hud.shapeLayer.add(animation, forKey: "MyAnimation")
                
                self.isBeginPlay = true
            }
        }
    }
    
    func hideTutorial() {
        self.hud.tutorialDialog.removeFromParent()
        self.hud.cursorHand.removeAllActions()
        self.hud.cursorHand.removeFromParent()
        self.hud.shapeLayer.path = nil
        self.hud.shapeLayer.removeAllAnimations()
        self.hud.shapeLayer.removeFromSuperlayer()
    }
    
}
enum PhysicsCategory:UInt32 {
    case player = 1
    case damagedPlayer = 2
    case creep = 4
    case boss = 8
    case crate = 16
    case powerUp = 32
    case miniBoss = 64
    case projectiles = 128
}

