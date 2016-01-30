//
//  GameScene.swift
//  ArmPong
//
//  Created by Matthew Else on 30/01/2016.
//  Copyright (c) 2016 Corpus/King's Hackathon Team. All rights reserved.
//

import SpriteKit
import CoreBluetooth

class PongScene: SKScene {
    
    // do some hysteresis?
    var upThreshold = 0
    var downThreshold = 0
    
    var leftPaddle: SKShapeNode?
    var rightPaddle: SKShapeNode?
    
    var ball: SKShapeNode?
    
    var ballvX: Float = 0.00001
    var ballvY: Float = 0.00001
    
    
    var ldy = 0.0
    var rdy = 0.0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = NSColor(calibratedRed: 0.24, green: 0.24, blue: 0.28, alpha: 1.0)
    
        leftPaddle = SKShapeNode(rectOfSize: CGSize(width: 30, height: 100))
        leftPaddle?.fillColor = SKColor.whiteColor()
        leftPaddle?.position = CGPoint(x:0, y:CGRectGetMidY(self.frame))
        
        self.addChild(leftPaddle!)
        
        
        rightPaddle = SKShapeNode(rectOfSize: CGSize(width: 30, height: 100))
        rightPaddle?.fillColor = SKColor.whiteColor()
        rightPaddle?.position = CGPoint(x:CGRectGetMaxX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(rightPaddle!)
        
        ball = SKShapeNode(ellipseOfSize: CGSize(width: 50, height: 50))
        ball?.fillColor = SKColor.whiteColor()
        ball?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
     
        self.addChild(ball!)
    }
    
    override func keyDown(theEvent: NSEvent) {
        print(theEvent.keyCode)
        if theEvent.keyCode == 125 {
            // move something upwards
            ldy = -5.0
        } else if theEvent.keyCode == 126 {
            // move it downwards
            ldy = +5.0
        }
        
        if theEvent.keyCode == 1 {
            // move something upwards
            rdy = -5.0
        } else if theEvent.keyCode == 13 {
            rdy = +5.0
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        if theEvent.keyCode == 125 || theEvent.keyCode == 126 {
            ldy = 0.0
        }
        
        if theEvent.keyCode == 1 || theEvent.keyCode == 13 {
            rdy = 0.0
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
    
    }
    
    func within(a: Float, low: Float, high: Float) -> Bool {
        return (low <= a) && (a <= high)
    }
    
    override func update(currentTime: CFTimeInterval) {
        // check collision status with the paddles
        
        if ball!.position.x <= leftPaddle!.frame.width && within(Float(ball!.position.y), low: Float(leftPaddle!.position.y) - Float(leftPaddle!.frame.height) / 2.0, high: Float(leftPaddle!.position.y) + Float(leftPaddle!.frame.height) / 2) {
            print("collision (left)")
            ballvX = -ballvX
        } else if ball!.position.x >= frame.width - rightPaddle!.frame.width && within(Float(ball!.position.y), low: Float(rightPaddle!.position.y) - Float(rightPaddle!.frame.height) / 2.0, high: Float(rightPaddle!.position.y) + Float(rightPaddle!.frame.height) / 2) {
            ballvX = -ballvX
        } else if ball!.position.x <= (ball!.frame.width / 2) {
            // collision with the left
            ballvX = -ballvX
        } else if ball!.position.x >= frame.width - (ball!.frame.width / 2) {
            // collision with the right
            ballvX = -ballvX
        }
        
        if ball!.position.y <= (ball!.frame.height / 2) {
            // collision with the top
            ballvY = -ballvY
        } else if ball!.position.y >= frame.height - (ball!.frame.height / 2) {
            // collision with the bottom
            ballvY = -ballvY
        }
        
        let dy = Double(_bits: currentTime.value) * Double(ballvY)
        let dx = Double(_bits: currentTime.value) * Double(ballvX)
     
        ball!.position.x += CGFloat(dx)
        ball!.position.y += CGFloat(dy)
        
        if (leftPaddle!.position.y + CGFloat(ldy) > leftPaddle!.frame.height / 2) && (leftPaddle!.position.y + CGFloat(ldy) < frame.height - leftPaddle!.frame.height / 2) {
            leftPaddle!.position.y += CGFloat(ldy)
        }
        
        if (rightPaddle!.position.y + CGFloat(rdy) > rightPaddle!.frame.height / 2) && (rightPaddle!.position.y + CGFloat(rdy) < frame.height - rightPaddle!.frame.height / 2) {
            rightPaddle!.position.y += CGFloat(rdy)
        }
    }
    
    
    func handleAdcValue(value: Int) {

        
    }
}
