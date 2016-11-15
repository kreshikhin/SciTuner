//
//  ControlbarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class ControlbarView: UIView {
    let tuner = Tuner.sharedInstance
    var isPaused = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        let width = frame.size.width;
        let margin: CGFloat = 10;
        _ = frame.origin.x + margin;
        _ = frame.origin.y + margin;
        
        let rewind = RewindButton(frame: CGRectMake(width/2 - 60 - 32, 10, 32, 16))
        rewind.addTarget(self, action: #selector(ControlbarView.prevString), forControlEvents: .TouchUpInside)
        self.addSubview(rewind)
        
        let forward = ForwardButton(frame: CGRectMake(width/2 + 60, 10, 32, 16))
        forward.addTarget(self, action: #selector(ControlbarView.nextString), forControlEvents: .TouchUpInside)
        self.addSubview(forward)

        let record = RecordButton(frame: CGRectMake(width/2 - 10, 10, 20, 20))
        record.addTarget(self, action: #selector(ControlbarView.toggle), forControlEvents: .TouchUpInside)
        self.addSubview(record)
    }
    
    func prevString(){
        tuner.prevString()
    }
    
    func nextString(){
        tuner.nextString()
    }
    
    func toggle(){
        isPaused = !isPaused;
        self.tuner.isPaused = isPaused;
    }
}