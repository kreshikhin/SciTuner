//
//  PanelView.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 13.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit

class PanelView: UIView {
    var target: UILabel?
    var actual: UILabel?
    var deviation: UILabel?
    
    var targetFrequency: UILabel?
    var actualFrequency: UILabel?
    var frequencyDeviation: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let margin: CGFloat = 10.0
        let third = (frame.size.width - 2*margin) / 3
        
        target = UILabel(frame: CGRect(x: margin, y: 2, width: third, height: 12))
        target!.text = "target frequency"
        target!.font = UIFont.systemFont(ofSize: 10)
        
        target!.textAlignment = .left
        self.addSubview(target!)
        
        actual = UILabel(frame: CGRect(x: margin+third, y: 2, width: third, height: 12))
        actual!.text = "actual frequency"
        actual!.font = UIFont.systemFont(ofSize: 10)
        actual!.textAlignment = .center
        self.addSubview(actual!)
        
        deviation = UILabel(frame: CGRect(x: margin+2*third, y: 2, width: third, height: 12))
        deviation!.text = "deviation"
        deviation!.font = UIFont.systemFont(ofSize: 10)
        deviation!.textAlignment = .right
        self.addSubview(deviation!)
        
        targetFrequency = UILabel(frame: CGRect(x: margin, y: 14, width: third, height: 20))
        targetFrequency!.text = "440Hz"
        targetFrequency!.textAlignment = .left
        self.addSubview(targetFrequency!)
        
        actualFrequency = UILabel(frame: CGRect(x: margin+third, y: 14, width: third, height: 20))
        actualFrequency!.text = "440Hz"
        actualFrequency!.textAlignment = .center
        self.addSubview(actualFrequency!)
        
        frequencyDeviation = UILabel(frame: CGRect(x: margin+2*third, y: 14, width: third, height: 20))
        frequencyDeviation!.text = "0c"
        frequencyDeviation!.textAlignment = .right
        self.addSubview(frequencyDeviation!)
    }
}
