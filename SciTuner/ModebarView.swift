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
                self.fretMode!.setTitle("5th fret", for: UIControlState())
                self.fretMode!.backgroundColor = self.tintColor
                self.fretMode!.setTitleColor(UIColor.white, for: UIControlState())
            case 7:
                self.fretMode!.setTitle("7th fret", for: UIControlState())
                self.fretMode!.backgroundColor = self.tintColor
                self.fretMode!.setTitleColor(UIColor.white, for: UIControlState())
            case 12:
                self.fretMode!.setTitle("12th fret", for: UIControlState())
                self.fretMode!.backgroundColor = self.tintColor
                self.fretMode!.setTitleColor(UIColor.white, for: UIControlState())
            default:
                self.fretMode!.setTitle("tune on fret", for: UIControlState())
                self.fretMode!.backgroundColor = self.backgroundColor
                self.fretMode!.setTitleColor(self.tintColor, for: UIControlState())
            }
        }
        get{ return 0 }
    }
    
    var filter: String {
        set{
            switch newValue {
            case "off":
                self.filterMode!.setTitle("filter: off", for: UIControlState())
                self.filterMode!.backgroundColor = self.tintColor
                self.filterMode!.setTitleColor(UIColor.white, for: UIControlState())
            default:
                self.filterMode!.setTitle("filter: on", for: UIControlState())
                self.filterMode!.backgroundColor = self.backgroundColor
                self.filterMode!.setTitleColor(self.tintColor, for: UIControlState())
            }
        }
        get{ return "" }
    }
    
    var notes: [String] = ["G#4", "A4", "B#4"]
    var tuningMode: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let width = frame.size.width;
        
        let defaultColor = self.tintColor
        
        fretMode = CustomButton(frame: CGRect(x: 5, y: 5, width: 110, height: 25))
        fretMode!.setTitle("tune on fret", for: UIControlState())
        fretMode!.titleLabel?.textAlignment = .left
        fretMode!.setTitleColor(UIColor.white, for: UIControlState())
        fretMode!.layer.cornerRadius = 3.0
        fretMode!.backgroundColor = defaultColor
        self.addSubview(fretMode!)
        
        filterMode = CustomButton(frame: CGRect(x: width-100, y: 5, width: 100, height: 25))
        filterMode!.setTitle("filter: on", for: UIControlState())
        filterMode!.titleLabel?.textAlignment = .right
        filterMode!.layer.cornerRadius = 3.0
        filterMode!.setTitleColor(UIColor.white, for: UIControlState())
        filterMode!.backgroundColor = UIColor.red
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
