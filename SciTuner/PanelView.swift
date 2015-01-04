//
//  PanelView.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 13.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit

class PanelView: UIView {
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.greenColor()
        
        var lockButton = UIButton(frame: CGRectMake(10, 10, 100, 100))
        lockButton.titleLabel?.text = "lock"
        self.addSubview(lockButton)
        
        NSLog("wtf ???")
        // ...
    }
}