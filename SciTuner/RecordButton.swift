//
//  RecordButton.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class RecordButton: CustomButton{
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        self.addTarget(self, action: #selector(RecordButton.click), for: UIControlEvents.touchUpInside)
    }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()

        if(!self.isHighlighted) {
            ctx?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
            ctx?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            ctx?.setFillColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            ctx?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        }

        let width = rect.width

        if(isPaused()){
            let center = CGPoint(x: rect.midX, y: rect.midY)
            ctx?.addArc(center: center, radius: width/2, startAngle: 0, endAngle: 2 * CGFloat(M_PI), clockwise: false);
        }else{
            ctx?.addRect(CGRect(
                x: rect.minX, y: rect.minY,
                width: width/3, height: rect.height))


            ctx?.addRect(CGRect(
                x: rect.minX + width*2/3, y: rect.minY,
                width: width/3, height: rect.height))
        }

        ctx?.fillPath()
    }

    func click(){
        self.isSelected = !self.isSelected
    }

    func isPaused() -> Bool { return self.isSelected }
}
