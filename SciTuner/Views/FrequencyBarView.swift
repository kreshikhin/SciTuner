//
//  FrequencyBarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/12/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import UIKit

class FrequencyBarView: UIView {
    var target = UILabel()
    var actual = UILabel()
    var deviation = UILabel()
    
    var targetFrequency = UILabel()
    var actualFrequency = UILabel()
    var frequencyDeviation = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        [target, actual, deviation].forEach { addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false }
        [targetFrequency, actualFrequency, frequencyDeviation].forEach { addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false  }
        
        
        target.text = "target frequency".localized()
        actual.text = "actual frequency".localized()
        deviation.text = "deviation".localized()
        
        target.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        actual.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        deviation.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        [target, deviation, actual].forEach { (label) in
            label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3).isActive = true
        }
        
        targetFrequency.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        actualFrequency.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        frequencyDeviation.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        [targetFrequency, actualFrequency, frequencyDeviation].forEach { (label) in
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6).isActive = true
        }
        
        self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0/6).isActive = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
