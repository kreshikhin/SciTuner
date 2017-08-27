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

    var strings: [Note] {
        set{
            for la in labels { la!.isHidden = true }
            for li in lines { li!.isHidden = true }

            count = newValue.count
            
            let width = frame.size.width;
            let left = margin;
            let top = margin;
            let step = (width - 2 * margin) / CGFloat(count);

            for i in 0 ..< count {
                let shift = step * (CGFloat(i) + 0.5)
                let line = lines[i]!
                line.frame = CGRect(x: left + shift, y: top, width: 3.5 * (1.0 - CGFloat(i) / CGFloat(count)), height: 7.0)
                line.isHidden = false

                let label = labels[i]!
                label.frame = CGRect(x: left + shift - 9, y: top + 7, width: 30 , height: 20)
                label.text = newValue[i].string
                label.isHidden = false
                label.adjustsFontSizeToFitWidth = true
            }
        }
        get {
            var result = [Note]()
            for i in 0 ..< count {
                result.append(Note(labels[i]!.text!))
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

            underline.frame = CGRect(x: left + shift - 9, y: top + 25, width: 20 , height: 1)
            underline.isHidden = false
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

        underline.backgroundColor = UIColor.black
        underline.isHidden = true
        self.addSubview(underline)

        for _ in 0 ..< 10 {
            let line = UIView()
            line.backgroundColor = UIColor.black
            line.isHidden = true
            lines.append(line)
            self.addSubview(line)
            
            let label = UILabel()
            label.isHidden = true
            labels.append(label)
            self.addSubview(label)
        }

        let width = frame.size.width;
        let left = margin;
        let top = margin;

        let baseline = UIView(frame: CGRect(x: left, y: top, width: width - 2 * margin, height: 1))
        baseline.backgroundColor = UIColor.black

        pointer = PointerView(frame: CGRect(x: left + width/1.5, y: top - 10, width: 10, height: 10))
        self.addSubview(pointer!)
        self.addSubview(baseline)
    }
}
