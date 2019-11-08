//
//  RenderView.swift
//  PathRecognizer
//
//  Created by Didier Brun on 15/03/2015.
//  Copyright (c) 2015 Didier Brun. All rights reserved.
//

import UIKit

class RenderView: UIView {

    var context: CGContext? = nil
    
    // MARK: *Line drawn gesture colors:
    let rightGestureColor = UIColor.red
    let downGestureColor = UIColor.blue
    let upArrowGestureColor = UIColor.green
    let downArrowGestureColor = UIColor.yellow
    let leftArrowGestureColor = UIColor.magenta
    let rightArrowGestureColor = UIColor.cyan
    let lightingGestureColor = UIColor.yellow
    let heartGestureColor = #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)

    let boyLeftGestureColor = UIColor.blue
    let boyRightGestureColor = UIColor.red
    let dogLeftGestureColor = UIColor.cyan
    let dogRightGestureColor = UIColor.red
    let downFishGestureColor = UIColor.cyan
    let upFishGestureColor = UIColor.green
    let mGestureColor = UIColor.cyan
    let nGestureColor = UIColor.cyan
    let nReservedGestureColor = UIColor.red
    let noseGestureColor = UIColor.purple
    let noseReservedGestureColor = UIColor.purple
    let pLeftGestureColor = UIColor.green
    let pRightGestureColor = UIColor.yellow
    let wGestureColor = UIColor.yellow
    let zGestureColor = UIColor.green

    
    var gestureName: String = ""
    
    var pointsToDraw:[Int] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = .clear
        self.isMultipleTouchEnabled = false
    }
    
    override func draw(_ rect: CGRect) {
        context = UIGraphicsGetCurrentContext()!
        context?.clear(self.bounds)
        context?.setLineWidth(10.0)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineCap(CGLineCap.round)
        context?.setLineJoin(CGLineJoin.round)
        
        if pointsToDraw.count > 4 {
            
            context?.move(to: CGPoint(x: CGFloat(pointsToDraw[0]), y: CGFloat(pointsToDraw[1])))
            
            for i in 2..<pointsToDraw.count {
                if i % 2 == 0 {
                    context?.addLine(to: CGPoint(x: CGFloat(pointsToDraw[i]), y: CGFloat(pointsToDraw[i + 1])))
                }
            }
        }
        self.setCGContextColor()
        // Draw
        context?.strokePath();
    }
    
    func getContext() -> CGContext{
        return context!
    }
    
    func setPointsToDraw(drawPoints: [Int]) {
         self.pointsToDraw = drawPoints
    }
    
    func setCGContextColor() {
        switch gestureName {
        case "right":
            self.rightGestureColor.setStroke()
        case "upArrow":
            self.upArrowGestureColor.setStroke()
        case "downArrow":
            self.downArrowGestureColor.setStroke()
        case "down":
            self.downGestureColor.setStroke()
        case "leftArrow":
            self.leftArrowGestureColor.setStroke()
        case "rightArrow":
            self.rightArrowGestureColor.setStroke()
        case "lighting":
            self.lightingGestureColor.setStroke()
        case "heart":
           // UIColor.init(red: 1, green: 51/255, blue: 200/255, alpha: 1).setStroke()
            self.heartGestureColor.setStroke()
        case "boyLeft":
            self.boyLeftGestureColor.setStroke()
        case "boyRight":
            self.boyRightGestureColor.setStroke()
        case "dogLeft":
            self.dogLeftGestureColor.setStroke()
        case "dogRight":
            self.dogRightGestureColor.setStroke()
        case "downFish":
            self.downFishGestureColor.setStroke()
        case "upFish":
            self.upFishGestureColor.setStroke()
        case "m":
            self.mGestureColor.setStroke()
        case "w":
            self.wGestureColor.setStroke()
        case "n":
            self.nGestureColor.setStroke()
        case "nReserved":
            self.nReservedGestureColor.setStroke()
        case "nose":
            self.noseGestureColor.setStroke()
        case "noseReserved":
            self.noseReservedGestureColor.setStroke()
        case "pLeft":
            self.pLeftGestureColor.setStroke()
        case "pRight":
            self.pRightGestureColor.setStroke()
        case "z":
            self.zGestureColor.setStroke()
        default:
            UIColor.white.setStroke()
        }
    }

    func clear() {
        context?.setAlpha(0)
        self.setNeedsDisplay()
    } 
 
}
