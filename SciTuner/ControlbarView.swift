//
//  ControlbarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class ControlbarView: UIView {
    var notes: [String] = ["G#4", "A4", "B#4"]
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        var width = frame.size.width;
        var margin: CGFloat = 10;
        var left = frame.origin.x + margin;
        var top = frame.origin.y + margin;
        
        var rewind = RewindButton(frame: CGRectMake(width/2 - 60 - 32, 10, 32, 16))
        self.addSubview(rewind)
        
        var forward = ForwardButton(frame: CGRectMake(width/2 + 60, 10, 32, 16))
        self.addSubview(forward)

        var record = RecordButton(frame: CGRectMake(width/2 - 8, 10, 16, 16))
        self.addSubview(record)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("controlbar began")
    }
}