//
//  PointerView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class PointerView: UIView{
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layer.borderColor = UIColor.white.cgColor
        
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
}
