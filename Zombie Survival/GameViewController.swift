//
//  GameViewController.swift
//  Zombie Survival
//
//  Created by Tran Quoc Tuan on 2/21/17.
//  Copyright © 2017 Tran Quoc Tuan. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet weak var renderView: RenderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        /*
        let level5 = Level5_Ending(fileNamed: "Level5_Ending")
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        //level5.size = view.bounds.size
        skView.presentScene(level5)
        */
        // build the main menu scene
        let menuScene = MenuScene()
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        menuScene.size = view.bounds.size
        skView.presentScene(menuScene)
        
        // Set gamescene instance to this
        menuScene.viewController = self
        
    }
    
   /* override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Create our screen:
        let scene = GameScene()
        // Configure the view:
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.showsPhysics = true
        
        scene.scaleMode = .aspectFill
        // size our scene to fit the view exactly
        scene.size = view.bounds.size
        // Set gamescene instance to this
        scene.viewController = self
        // show new scene:
        skView.presentScene(scene)
    }
    */
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeRight, .landscapeLeft]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
