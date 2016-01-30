//
//  GameScene.swift
//  ArmPong
//
//  Created by Matthew Else on 30/01/2016.
//  Copyright (c) 2016 Corpus/King's Hackathon Team. All rights reserved.
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
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = NSColor(calibratedRed: 0.24, green: 0.24, blue: 0.28, alpha: 1.0)
        
        instructionLabel = SKLabelNode(fontNamed:"American Typewriter")
        
        instructionLabel!.text = "Calibrate Sensor"
        instructionLabel!.fontSize = 45
        instructionLabel!.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))

        self.addChild(instructionLabel!)
        
        calibrationState = .Tense
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
        }
    }
    
    func checkData(data: [Int]) {
        
        // maybe it's a good idea to see what we can do about this data...
        // it might make some sense to try and look at the minima and maxima in each of the datasets?
        
        if data.count < 10 {
            print(String(data.count) + "/10")
            return
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
                
                self.view!.presentScene(PongScene(size:self.view!.bounds.size))
            case .Finished:
                0
            }
        } else {
            print("this difference isn't small enough: " + String(maxval - minval))
        }

    }
    
    func handleAdcValue(value: Int) {
        // we can use this to calibrate it
        
        switch calibrationState! {
        case .Tense:
            // add to our collection of tense data
            tenseData.append(value)
            checkData(tenseData)
        case .Relax:
            // add to our collection of relax data
            relaxData.append(value)
            checkData(relaxData)
        case .Finished:
            0
        }
    }
}
