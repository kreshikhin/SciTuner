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
                label!.text = newValue[index].uppercased()
                index += 1
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
            
            let width: CGFloat = self.frame.size.width;
            pointer!.frame.origin.x = CGFloat(shift) * (width - 2 * margin) + 6;
        }
        get{
            return position
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let width = frame.size.width;
        var notes = ["G#4", "A4", "B#4"]
        
        let baseline = UIView(frame: CGRect(x: margin, y: 10, width: width - 2 * margin, height: 1))
        baseline.backgroundColor = UIColor.black
        
        var step = (width - 2 * margin) / 30;
        for i in 1 ..< 30 {
            let line = UIView(frame: CGRect(x: margin + step * CGFloat(i), y: margin, width: 1.0 , height: 4))
            line.backgroundColor = UIColor.black
            self.addSubview(line);
        }
        
        step = (width - 2 * margin) / 3;
        for i in 0 ..< 3 {
            let line = UIView(frame: CGRect(x: margin + step * (CGFloat(i) + 0.5), y: margin, width: 2.0 , height: 7))
            line.backgroundColor = UIColor.black
            
            self.addSubview(line);
            
            let label = UILabel(frame: CGRect(x: margin + step * (CGFloat(i) + 0.5) - 9, y: margin + 7, width: 40 , height: 20))
            label.text = notes[Int(i)];
            labels.append(label)
            self.addSubview(label);
        }
        
        pointer = PointerView(frame: CGRect(x: margin + width/2, y: margin - 10, width: 10, height: 10))
        self.addSubview(pointer!)
        
        self.addSubview(baseline)
        
        self.tuner.on("frequencyChange", {()in
            self.pointerPosition = self.tuner.frequencyDeviation()
        })
        
        self.tuner.on("stringChange", {()in
            self.notes = self.tuner.notes
        })
        
        self.notes = self.tuner.notes
    }
}
