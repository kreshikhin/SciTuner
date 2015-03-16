//
//  PanelView.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 13.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit

class PanelView: UIView {
    var notebar: NotebarView?
    var stringbar: StringbarView?
    var controlbar: ControlbarView?
    var modebar: ModebarView?
    
    var target: UILabel?
    var actual: UILabel?
    var deviation: UILabel?
    
    var targetFrequency: UILabel?
    var actualFrequency: UILabel?
    var frequencyDeviation: UILabel?
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        println(frame)
        
        let margin: CGFloat = 10.0;
        let half = frame.size.width / 2;
        let third = (frame.size.width - 2*margin) / 3;
        
        let step = frame.size.height / 5.0;
        
        target = UILabel(frame: CGRectMake(margin, 2, third, 12))
        target!.text = "target frequency"
        target!.font = UIFont.systemFontOfSize(10)
        
        target!.textAlignment = .Left
        self.addSubview(target!)
        
        actual = UILabel(frame: CGRectMake(margin+third, 2, third, 12))
        actual!.text = "actual frequency"
        actual!.font = UIFont.systemFontOfSize(10)
        actual!.textAlignment = .Center
        self.addSubview(actual!)
        
        deviation = UILabel(frame: CGRectMake(margin+2*third, 2, third, 12))
        deviation!.text = "deviation"
        deviation!.font = UIFont.systemFontOfSize(10)
        deviation!.textAlignment = .Right
        self.addSubview(deviation!)
        
        targetFrequency = UILabel(frame: CGRectMake(margin, 14, third, 20))
        targetFrequency!.text = "440Hz"
        targetFrequency!.textAlignment = .Left
        self.addSubview(targetFrequency!)
        
        actualFrequency = UILabel(frame: CGRectMake(margin+third, 14, third, 20))
        actualFrequency!.text = "440Hz"
        actualFrequency!.textAlignment = .Center
        self.addSubview(actualFrequency!)
        
        frequencyDeviation = UILabel(frame: CGRectMake(margin+2*third, 14, third, 20))
        frequencyDeviation!.text = "0c"
        frequencyDeviation!.textAlignment = .Right
        self.addSubview(frequencyDeviation!)
        
        notebar = NotebarView(frame: CGRectMake(0, step, half*2, 40))
        stringbar = StringbarView(frame: CGRectMake(0, 2*step, half*2, 40))
        controlbar = ControlbarView(frame: CGRectMake(0, 3*step, half*2, 40))
        modebar = ModebarView(frame: CGRectMake(0, frame.size.height - 35, half*2, 20))
        
        self.addSubview(notebar!)
        self.addSubview(stringbar!)
        self.addSubview(controlbar!)
        self.addSubview(modebar!)
    }
}