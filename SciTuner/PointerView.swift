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
        self.backgroundColor = UIColor.white
    }
    
    override func draw(_ rect: CGRect){
        let ctx = UIGraphicsGetCurrentContext()
    
        ctx?.beginPath()
        ctx?.move   (to: CGPoint(x: rect.minX, y: rect.minY))  // top left
        ctx?.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))  // top right
        ctx?.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))  // mid bottom
        ctx?.closePath()
    
        ctx?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
        ctx?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        ctx?.fillPath()
    }
}
