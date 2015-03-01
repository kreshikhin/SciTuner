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
    var onPrevString = {() -> Void in}
    var onNextString = {() -> Void in}
    var onPause = {() -> Void in}
    var onRecord = {() -> Void in}
    
    var isPaused = false
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        var width = frame.size.width;
        var margin: CGFloat = 10;
        var left = frame.origin.x + margin;
        var top = frame.origin.y + margin;
        
        var rewind = RewindButton(frame: CGRectMake(width/2 - 60 - 32, 10, 32, 16))
        rewind.addTarget(self, action: Selector("prevString"), forControlEvents: .TouchUpInside)
        self.addSubview(rewind)
        
        var forward = ForwardButton(frame: CGRectMake(width/2 + 60, 10, 32, 16))
        forward.addTarget(self, action: Selector("nextString"), forControlEvents: .TouchUpInside)
        self.addSubview(forward)

        var record = RecordButton(frame: CGRectMake(width/2 - 10, 10, 20, 20))
        record.addTarget(self, action: Selector("toggle"), forControlEvents: .TouchUpInside)
        self.addSubview(record)
    }
    
    func prevString(){
        self.onPrevString()
    }
    
    func nextString(){
        self.onNextString()
    }
    
    func toggle(){
        isPaused = !isPaused;
        if(isPaused){
            onPause()
        }else{
            onRecord()
        }
    }
}