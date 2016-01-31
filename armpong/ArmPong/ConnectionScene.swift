//
//  ConnectionScene.swift
//  ArmPong
//
//  Created by Matthew Else on 30/01/2016.
//  Copyright (c) 2016 Corpus/King's Hack Cambridge Team. All rights reserved.
//

import Foundation
import SpriteKit

class ConnectionScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"American Typewriter")
        myLabel.text = "Connecting..."
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.backgroundColor = NSColor(calibratedRed: 0.24, green: 0.24, blue: 0.28, alpha: 1.0)
        
        self.addChild(myLabel)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
    }
    
    override func keyDown(theEvent: NSEvent) {
        print(theEvent.keyCode)
        if theEvent.keyCode == 11 {
            self.view?.presentScene(PongScene(size:self.view!.bounds.size))
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

}

