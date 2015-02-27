//
//  StringbarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation

//
//  NotebarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class StringbarView: UIView {
    var strings: [String] = ["E2", "A2", "B3", "G3", "D3", "E4"]
    
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
        
        var step = (width - 2 * margin) / CGFloat(strings.count);
        
        for(var i = 0; i < strings.count; i++){
            var shift = step * (CGFloat(i) + 0.5);
            var line = UIView(frame: CGRectMake(left + shift, top, (7.0 - CGFloat(i))/2.0 , 7.0))
            line.backgroundColor = UIColor.blackColor()
            self.addSubview(line);
            
            var label = UILabel(frame: CGRectMake(left + shift - 9, top + 7, 25 , 20))
            label.text = strings[i];
            self.addSubview(label);
        }
        
        var pointer = PointerView(frame: CGRectMake(left + width/1.5, top - 10, 10, 10))
        self.addSubview(pointer)
        
        self.addSubview(baseline)
    }
}