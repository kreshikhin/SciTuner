//
//  RewindButton.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKIt
import CoreGraphics

class RewindButton: CustomButton{
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func drawRect(rect: CGRect){
        var ctx = UIGraphicsGetCurrentContext()
        
        if(!self.highlighted) {
            CGContextSetRGBFillColor(ctx, 0, 0, 0, 1)
            CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1)
        } else {
            CGContextSetRGBFillColor(ctx, 0.5, 0.5, 0.5, 1)
            CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1)
        }
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMidY(rect))  // mid left
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect))  // mid top
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect))  // mid bottom
        CGContextClosePath(ctx)
        
        CGContextFillPath(ctx)
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint   (ctx, CGRectGetMidX(rect), CGRectGetMidY(rect))  // mid mid
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect))  // right top
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect))  // right bottom
        CGContextClosePath(ctx)
        CGContextFillPath(ctx)
    }
}