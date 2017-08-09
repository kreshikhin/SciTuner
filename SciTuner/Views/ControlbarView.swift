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
        
        self.backgroundColor = UIColor.white
        
        let width = frame.size.width;
        let margin: CGFloat = 10;
        _ = frame.origin.x + margin;
        _ = frame.origin.y + margin;
        
        let rewind = RewindButton(frame: CGRect(x: width/2 - 60 - 32, y: 10, width: 32, height: 16))
        rewind.addTarget(self, action: #selector(ControlbarView.prevString), for: .touchUpInside)
        self.addSubview(rewind)
        
        let forward = ForwardButton(frame: CGRect(x: width/2 + 60, y: 10, width: 32, height: 16))
        forward.addTarget(self, action: #selector(ControlbarView.nextString), for: .touchUpInside)
        self.addSubview(forward)

        let record = RecordButton(frame: CGRect(x: width/2 - 10, y: 10, width: 20, height: 20))
        record.addTarget(self, action: #selector(ControlbarView.toggle), for: .touchUpInside)
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
