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
    let fretMode = CustomButton()
    let filterMode = CustomButton()
    
    var fret: Fret = .openStrings {
        didSet{
            if fret == .openStrings {
                fretMode.backgroundColor = .clear
                fretMode.setTitleColor(.white, for: UIControlState())
                fretMode.setTitle("tune on fret", for: UIControlState())
                return
            }
            
            fretMode.backgroundColor = Style.highlighted0
            fretMode.setTitleColor(.white, for: UIControlState())
            fretMode.setTitle(fret.localized(), for: UIControlState())
        }
    }
    
    var filter: Filter = .on {
        didSet{
            if filter == .on {
                filterMode.backgroundColor = .clear
                filterMode.setTitleColor(.white, for: UIControlState())
            } else {
                filterMode.backgroundColor = Style.highlighted1
                filterMode.setTitleColor(.white, for: UIControlState())
            }
            
            filterMode.setTitle("filter: ".localized() + filter.localized(), for: UIControlState())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addFretModeButton()
        addFilterModeButton()
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
    }
    
    func addFretModeButton() {
        fretMode.translatesAutoresizingMaskIntoConstraints = false
        fretMode.titleLabel?.textAlignment = .left
        fretMode.layer.cornerRadius = 3.0
        
        fret = .openStrings
        addSubview(fretMode)
        
        fretMode.topAnchor.constraint(equalTo: topAnchor).isActive = true
        fretMode.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        fretMode.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0/3).isActive = true
        fretMode.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
    }
    
    func addFilterModeButton() {
        filterMode.translatesAutoresizingMaskIntoConstraints = false
        filterMode.titleLabel?.textAlignment = .right
        filterMode.layer.cornerRadius = 3.0
        
        filter = .off
        addSubview(filterMode)
        
        filterMode.topAnchor.constraint(equalTo: topAnchor).isActive = true
        filterMode.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        filterMode.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0/3).isActive = true
        filterMode.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
    }
}

