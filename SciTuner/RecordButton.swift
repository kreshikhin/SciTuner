//
//  RecordButton.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKIt
import CoreGraphics

class RecordButton: CustomButton{
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        //self.backgroundColor = UIColor.redColor()
        
        self.addTarget(self, action: Selector("click"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func drawRect(rect: CGRect) {
        var ctx = UIGraphicsGetCurrentContext()
        
        if(!self.highlighted) {
            CGContextSetRGBFillColor(ctx, 0, 0, 0, 1)
            CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1)
        } else {
            CGContextSetRGBFillColor(ctx, 0.5, 0.5, 0.5, 1)
            CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1)
        }

        var width = CGRectGetWidth(rect)

        if(isPaused()){
            CGContextAddArc(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect), width/2, 0, 2 * CGFloat(M_PI), 0)
        }else{
            CGContextAddRect(ctx, CGRectMake(
                CGRectGetMinX(rect), CGRectGetMinY(rect),
                width/3, CGRectGetHeight(rect)))
            
            
            CGContextAddRect(ctx, CGRectMake(
                CGRectGetMinX(rect) + width*2/3, CGRectGetMinY(rect),
                width/3, CGRectGetHeight(rect)))
        }
        
        CGContextFillPath(ctx)
    }
    
    func click(){
        self.selected = !self.selected
        println(self.selected)
    }
    
    func isPaused() -> Bool { return self.selected }
}