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
    var notes: [String] = ["G#4", "A4", "B#4"]
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var width = frame.size.width;
        var margin: CGFloat = 10;
        var left = frame.origin.x + margin;
        var top = frame.origin.y + margin;
        
        var baseline = UIView(frame: CGRectMake(left, top, width - 2 * margin, 1))
        baseline.backgroundColor = UIColor.blackColor()
        
        var step = (width - 2 * margin) / 27;
        for(var i: CGFloat = 0; i < 27; i++){
            var line = UIView(frame: CGRectMake(left + step * (i + 0.5), top, 1.0 , 4))
            line.backgroundColor = UIColor.blackColor()
            self.addSubview(line);
        }
        
        step = (width - 2 * margin) / 3;
        for(var i: CGFloat = 0; i < 3; i++){
            var line = UIView(frame: CGRectMake(left + step * (i + 0.5), top, 2.0 , 7))
            line.backgroundColor = UIColor.blackColor()
            self.addSubview(line);
            
            var label = UILabel(frame: CGRectMake(left + step * (i + 0.5) - 9, top + 7, 40 , 20))
            label.text = notes[Int(i)];
            self.addSubview(label);
        }
        
        var pointer = PointerView(frame: CGRectMake(left + width/2, top - 10, 10, 10))
        self.addSubview(pointer)
        
        self.addSubview(baseline)
    }
}