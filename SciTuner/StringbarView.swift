//
//  StringbarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class StringbarView: UIView {
    let tuner = Tuner.sharedInstance
    
    let margin: CGFloat = 10;

    var count = 0
    var labels: [UILabel?] = []
    var lines: [UIView?] = []
    var underline = UIView()

    var strings: [String] {
        set{
            for la in labels { la!.hidden = true }
            for li in lines { li!.hidden = true }

            count = newValue.count
            
            let width = frame.size.width;
            let left = margin;
            let top = margin;
            let step = (width - 2 * margin) / CGFloat(count);

            for(var i = 0; i < count; i += 1){
                let shift = step * (CGFloat(i) + 0.5)
                let line = lines[i]!
                line.frame = CGRectMake(left + shift, top, 3.5 * (1.0 - CGFloat(i) / CGFloat(count)), 7.0)
                line.hidden = false

                let label = labels[i]!
                label.frame = CGRectMake(left + shift - 9, top + 7, 30 , 20)
                label.text = newValue[i].uppercaseString
                label.hidden = false
                label.adjustsFontSizeToFitWidth = true
            }
        }
        get {
            var result = [String]()
            for(var i = 0; i < count; i += 1){
                result.append(labels[i]!.text!)
            }
            return result
        }
    }


    var pointer: PointerView?
    var position: Double = 0.0

    var stringIndex: Int {
        set{
            let width = frame.size.width;
            let left = margin;
            let top = margin;
            let step = (width - 2 * margin) / CGFloat(count);
            let shift = step * (CGFloat(newValue) + 0.5)

            underline.frame = CGRectMake(left + shift - 9, top + 25, 20 , 1)
            underline.hidden = false
        }
        get{
            return 0
        }
    }

    var pointerPosition: Double {
        set{
            position = newValue

            let step = (frame.width - 2*margin) / CGFloat(count)

            var shift: Double = position + 0.5;

            if position < 0.0 {
                shift = 0.5 * exp(position);
            }

            if position > Double(count) - 1.0 {
                shift = Double(count) - 0.5 * exp(-position+Double(count)-1);
            }

//            var width: CGFloat = frame.size.width;
            pointer!.frame.origin.x = CGFloat(shift) * step + 5.5;
        }
        get{
            return position
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        underline.backgroundColor = UIColor.blackColor()
        underline.hidden = true
        self.addSubview(underline)

        for(var i=0; i < 10; i = i+1) {
            let line = UIView()
            line.backgroundColor = UIColor.blackColor()
            line.hidden = true
            lines.append(line)
            self.addSubview(line)
            
            let label = UILabel()
            label.hidden = true
            labels.append(label)
            self.addSubview(label)
        }

        let width = frame.size.width;
        let left = margin;
        let top = margin;

        let baseline = UIView(frame: CGRectMake(left, top, width - 2 * margin, 1))
        baseline.backgroundColor = UIColor.blackColor()

        pointer = PointerView(frame: CGRectMake(left + width/1.5, top - 10, 10, 10))
        self.addSubview(pointer!)
        self.addSubview(baseline)
        
        tuner.on("tuningChange", {()in
            self.strings = self.tuner.strings
            self.stringIndex = self.tuner.stringIndex
        })
        
        tuner.on("frequencyChange", {()in
            self.pointerPosition = self.tuner.stringPosition()
        })
        
        tuner.on("stringChange", {()in
            self.stringIndex = self.tuner.stringIndex
        })
        
        self.strings = self.tuner.strings
        self.stringIndex = self.tuner.stringIndex
    }
}
