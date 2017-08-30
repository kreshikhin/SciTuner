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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fretMode = CustomButton()
        fretMode?.translatesAutoresizingMaskIntoConstraints = false
        fretMode!.setTitle("tune on fret", for: UIControlState())
        fretMode!.titleLabel?.textAlignment = .left
        fretMode!.setTitleColor(UIColor.white, for: UIControlState())
        fretMode!.layer.cornerRadius = 3.0
        fretMode!.backgroundColor = Style.highlighted1
        self.addSubview(fretMode!)
        
        fretMode?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        fretMode?.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        fretMode?.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0/3).isActive = true
        fretMode?.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        
        filterMode = CustomButton()
        filterMode?.translatesAutoresizingMaskIntoConstraints = false
        filterMode!.setTitle("filter: on", for: UIControlState())
        filterMode!.titleLabel?.textAlignment = .right
        filterMode!.layer.cornerRadius = 3.0
        filterMode!.setTitleColor(UIColor.white, for: UIControlState())
        filterMode!.backgroundColor = Style.highlighted0
        self.addSubview(filterMode!)
        
        filterMode?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        filterMode?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        filterMode?.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0/3).isActive = true
        filterMode?.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
    }
}

