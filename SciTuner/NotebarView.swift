//
//  NotebarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class NotebarView: UIView {
    let tuner = Tuner.sharedInstance
    
    let margin: CGFloat = 10;
    
    var pointer: PointerView?
    var position: Double = 0.0
    
    var labels: [UILabel?] = []
    
    var notes: [String] {
        get{
            return ["", "", ""]
        }
        set{
            var index = 0
            for label in labels {
                label!.text = newValue[index].uppercaseString
                index++
            }
        }
    }
    
    var pointerPosition: Double {
        set{
            position = newValue
            
            var shift: Double = 0.0;
            
            if position < -100.0 {
                shift = 0.16666665 * exp(position/100 + 1.0);
            }
            
            if position > 100.0 {
                shift = 1.0 - 0.16666665 * exp(-position/100 + 1.0);
            }
            
            if -100.0 < position && position < 100.0 {
                shift = 0.16666665 + 0.666666 * (position + 100.0) / 200.0;
            }
            
            var width: CGFloat = frame.size.width;
            pointer!.frame.origin.x = CGFloat(shift) * (width - 2 * margin) + 6;
        }
        get{
            return position
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var width = frame.size.width;
        var notes = ["G#4", "A4", "B#4"]
        
        var baseline = UIView(frame: CGRectMake(margin, 10, width - 2 * margin, 1))
        baseline.backgroundColor = UIColor.blackColor()
        
        var step = (width - 2 * margin) / 30;
        for(var i: CGFloat = 1; i < 30; i++){
            var line = UIView(frame: CGRectMake(margin + step * i, margin, 1.0 , 4))
            line.backgroundColor = UIColor.blackColor()
            self.addSubview(line);
        }
        
        step = (width - 2 * margin) / 3;
        for(var i: CGFloat = 0; i < 3; i++){
            var line = UIView(frame: CGRectMake(margin + step * (i + 0.5), margin, 2.0 , 7))
            line.backgroundColor = UIColor.blackColor()
            
            self.addSubview(line);
            
            var label = UILabel(frame: CGRectMake(margin + step * (i + 0.5) - 9, margin + 7, 40 , 20))
            label.text = notes[Int(i)];
            labels.append(label)
            self.addSubview(label);
        }
        
        pointer = PointerView(frame: CGRectMake(margin + width/2, margin - 10, 10, 10))
        self.addSubview(pointer!)
        
        self.addSubview(baseline)
        
        self.tuner.on("frequencyChange", {()in
            self.pointerPosition = self.tuner.frequencyDeviation()
        })
        
        self.tuner.on("stringChange", {()in
            self.notes = self.tuner.notes
        })
    }
}