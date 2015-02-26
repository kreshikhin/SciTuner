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
        
        let half = frame.size.width / 2
        let third = frame.size.width / 3;
        
        var thick = UILabel(frame: CGRectMake(10, 10, half - 10, 20))
        thick.text = "thick"
        thick.textAlignment = .Left
        self.addSubview(thick)
        
        var thin = UILabel(frame: CGRectMake(10+half, 10, half - 20, 20))
        thin.text = "thin"
        thin.textAlignment = .Right
        self.addSubview(thin)
        
        var re = UIBarButtonItem(barButtonSystemItem: .Rewind, target: nil, action: nil)
        var pl = UIBarButtonItem(barButtonSystemItem: .Play, target: nil, action: nil)
        var ff = UIBarButtonItem(barButtonSystemItem: .FastForward, target: nil, action: nil)
        
        NSLog("wtf ???")
    }
}