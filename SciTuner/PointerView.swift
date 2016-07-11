//
//  PointerView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class PointerView: UIView{
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func drawRect(rect: CGRect){
        let ctx = UIGraphicsGetCurrentContext()
    
        CGContextBeginPath(ctx)
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect))  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect))  // top right
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect))  // mid bottom
        CGContextClosePath(ctx)
    
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 1)
        CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1)
        CGContextFillPath(ctx)
    }
}