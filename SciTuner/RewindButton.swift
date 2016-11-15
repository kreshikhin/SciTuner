//
//  RewindButton.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class RewindButton: CustomButton{
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    override func draw(_ rect: CGRect){
        let ctx = UIGraphicsGetCurrentContext()
        
        if(!self.isHighlighted) {
            ctx?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
            ctx?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            ctx?.setFillColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            ctx?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        ctx?.beginPath()
        ctx?.move   (to: CGPoint(x: rect.minX, y: rect.midY))  // mid left
        ctx?.addLine(to: CGPoint(x: rect.midX, y: rect.minY))  // mid top
        ctx?.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))  // mid bottom
        ctx?.closePath()
        
        ctx?.fillPath()
        
        ctx?.beginPath()
        ctx?.move   (to: CGPoint(x: rect.midX, y: rect.midY))  // mid mid
        ctx?.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))  // right top
        ctx?.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))  // right bottom
        ctx?.closePath()
        ctx?.fillPath()
    }
}
