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
    let tuner = Tuner.sharedInstance
    
    var fretMode: UIButton?
    var filterMode: UIButton?
    
    var fret: Int {
        set{
            switch newValue {
            case 5:
                self.fretMode!.setTitle("5th fret", forState: .Normal)
                self.fretMode!.backgroundColor = self.tintColor
                self.fretMode!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 7:
                self.fretMode!.setTitle("7th fret", forState: .Normal)
                self.fretMode!.backgroundColor = self.tintColor
                self.fretMode!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 12:
                self.fretMode!.setTitle("12th fret", forState: .Normal)
                self.fretMode!.backgroundColor = self.tintColor
                self.fretMode!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            default:
                self.fretMode!.setTitle("tune on fret", forState: .Normal)
                self.fretMode!.backgroundColor = self.backgroundColor
                self.fretMode!.setTitleColor(self.tintColor, forState: .Normal)
            }
        }
        get{ return 0 }
    }
    
    var filter: String {
        set{
            switch newValue {
            case "off":
                self.filterMode!.setTitle("filter: off", forState: .Normal)
                self.filterMode!.backgroundColor = self.tintColor
                self.filterMode!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            default:
                self.filterMode!.setTitle("filter: on", forState: .Normal)
                self.filterMode!.backgroundColor = self.backgroundColor
                self.filterMode!.setTitleColor(self.tintColor, forState: .Normal)
            }
        }
        get{ return "" }
    }
    
    var notes: [String] = ["G#4", "A4", "B#4"]
    var tuningMode: UIButton?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var width = frame.size.width;
        var margin: CGFloat = 10;
        var left = frame.origin.x + margin;
        var top = frame.origin.y + margin;
        
        var defaultColor = self.tintColor
        
        fretMode = CustomButton(frame: CGRectMake(5, 5, 110, 20))
        fretMode!.setTitle("tune on fret", forState: .Normal)
        fretMode!.titleLabel?.textAlignment = .Left
        fretMode!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        fretMode!.layer.cornerRadius = 3.0
        fretMode!.backgroundColor = defaultColor
        self.addSubview(fretMode!)
        
        filterMode = CustomButton(frame: CGRectMake(width-100, 5, 100, 20))
        filterMode!.setTitle("filter: on", forState: .Normal)
        filterMode!.titleLabel?.textAlignment = .Right
        filterMode!.layer.cornerRadius = 3.0
        filterMode!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        filterMode!.backgroundColor = defaultColor
        self.addSubview(filterMode!)
        
        tuner.on("fretChange", {()in
            self.fret = self.tuner.fret
        })
        
        self.fret = self.tuner.fret
        
        tuner.on("filterChange", {()in
            self.filter = self.tuner.filter
        })
        
        self.filter = self.tuner.filter
    }
}