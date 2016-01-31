//
//  GameScene.swift
//  ArmPong
//
//  Created by Matthew Else on 30/01/2016.
//  Copyright (c) 2016 Corpus/King's Hack Cambridge Team. All rights reserved.
//

import SpriteKit
import CoreBluetooth

enum CalibrationState {
    case Tense
    case Relax
    case Finished
}

let NUM_SAMPLES_CALIBRATION = 10
let CALIBRATION_RANGE = 10

class CalibrationScene: SKScene {
    
    var controlPeripheral: CBPeripheral?
    var instructionLabel: SKLabelNode?
    
    var calibrationState: CalibrationState?
    
    var tenseData: [Int] = []
    var relaxData: [Int] = []
    
    var tenseMin: Int?
    var tenseMax: Int?
    
    var relaxMin: Int?
    var relaxMax: Int?
    
    var pongScene: PongScene?
    
    var leftLabel: SKLabelNode?
    var rightLabel:SKLabelNode?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = NSColor(calibratedRed: 0.24, green: 0.24, blue: 0.28, alpha: 1.0)
        
        instructionLabel = SKLabelNode(fontNamed:"American Typewriter")
        
        instructionLabel!.text = "Calibrate Sensor"
        instructionLabel!.fontSize = 45
        instructionLabel!.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))

        leftLabel = SKLabelNode(fontNamed:"American Typewriter")
        leftLabel!.text = "0000"
        leftLabel!.fontSize = 30
        leftLabel!.position = CGPoint(x: 50.0, y: 0.0)
        
        rightLabel = SKLabelNode(fontNamed:"Americarn Typewriter")
        rightLabel!.text = "0000"
        rightLabel!.fontSize = 30
        rightLabel!.position = CGPoint(x: self.frame.width - 50.0, y: 0.0)
        
        self.addChild(leftLabel!)
        self.addChild(instructionLabel!)
        self.addChild(rightLabel!)
        
        calibrationState = .Finished
    }
    
    override func mouseDown(theEvent: NSEvent) {
        print("click!")
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        switch calibrationState! {
        case .Tense:
            instructionLabel!.text = "Tense your arm"
        case .Relax:
            instructionLabel!.text = "Relax your arm"
        case .Finished:
            instructionLabel!.text = "Finished"
            pongScene = PongScene(size:self.view!.bounds.size)
            
            self.view!.presentScene(pongScene)
        }
    }
    
    func checkData(var data: [Int]) {
        
        // maybe it's a good idea to see what we can do about this data...
        // it might make some sense to try and look at the minima and maxima in each of the datasets?
        
        if data.count < 10 {
            print(String(data.count) + "/10")
            return
        } else {
            data.removeFirst()
            print(data)
        }
        
        let maxval = data.reduce(0, combine: { (a, b) in
            max(a, b)
        } )
        
        let minval = data.reduce(1025, combine: { (a, b) in
            min(a, b)
        } )
        
        if maxval - minval < 20 {
            // this is ok
            switch calibrationState! {
            case .Tense:
                tenseMin = minval
                tenseMax = maxval
                
                // switch to relax calibration
                print("calibrating relaxed now")
                calibrationState! = .Relax
            case .Relax:
                relaxMin = minval
                relaxMax = maxval
                
                print("finished calibrating... values are: " + String(relaxMin) + "->" + String(relaxMax) + " and " + String(tenseMin) + "->" + String(tenseMax))
                
                
                calibrationState! = .Finished
                
                pongScene = PongScene(size:self.view!.bounds.size)
                
                self.view!.presentScene(pongScene)
            case .Finished:
                0
            }
        } else {
            print("this difference isn't small enough: " + String(maxval - minval))
        }

    }
    
    func handleAdcValue(valuel: Int, valuer: Int) {
        // we can use this to calibrate it
        
        self.leftLabel!.text = String(valuel);
        self.rightLabel!.text = String(valuer);
        
        switch calibrationState! {
        case .Tense:
            // add to our collection of tense data
            tenseData.append(valuel)
            checkData(tenseData)
        case .Relax:
            // add to our collection of relax data
            relaxData.append(valuel)
            checkData(relaxData)
        case .Finished:
            print(tenseData, relaxData)
        }
        
        if let pScene = pongScene {
            // TODO: update this for two values!!!
            pScene.handleAdcValues(valuel, valuer: valuer)
        }
    }
}
