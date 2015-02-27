//
//  ModebarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class ModebarView: UIView {
    var notes: [String] = ["G#4", "A4", "B#4"]
    var tuningMode: UIButton?
    
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
        
        var defaultColor = self.tintColor
        
        var tuningMode = UIButton(frame: CGRectMake(5, 5, 110, 20))
        tuningMode.setTitle("tune on 5 fret", forState: .Normal)
        tuningMode.titleLabel?.textAlignment = .Left
        tuningMode.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        tuningMode.layer.cornerRadius = 3.0
        tuningMode.backgroundColor = defaultColor
        self.addSubview(tuningMode)
        
        var tubeMode = UIButton(frame: CGRectMake(width-100, 10, 100, 20))
        tubeMode.setTitle("spectrum", forState: UIControlState.Normal)
        tubeMode.titleLabel?.textAlignment = .Right
        tubeMode.setTitleColor(defaultColor, forState: .Normal)
        self.addSubview(tubeMode)
    }
}