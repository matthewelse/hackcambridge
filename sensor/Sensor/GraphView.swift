//
//  GraphView.swift
//  Sensor
//
//  Created by Matthew Else on 30/01/2016.
//  Copyright © 2016 Hackathon Team. All rights reserved.
//

import UIKit
import Foundation

class GraphView : UIView {
    var data: [Float] = []
    
    func addDataPoint(val: Float) {
        data.append(((Float(frame.height) * (val) / 1023.0) ))
        
        if data.count > 200 {
            data.removeFirst()
        }
        
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextSetLineWidth(ctx, 2.0)
        

        for (i, val) in data.enumerate() {
            CGContextMoveToPoint(ctx, CGFloat(i), frame.height);
            CGContextAddLineToPoint(ctx, CGFloat(i), frame.height - CGFloat(val))
            CGContextStrokePath(ctx)
        }
    }
}

