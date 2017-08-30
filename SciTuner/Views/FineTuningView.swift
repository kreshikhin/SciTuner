//
//  FineTuningView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class FineTuningView: UIView {
    let tuner = Tuner.sharedInstance
    
    let margin: CGFloat = 10
    
    let baseline = UIView()
    let zero = UIView()
    
    var pointer: PointerView?
    var position: Double = 0.0
    
    var pointerPosition: Double {
        set{
            position = newValue
            
            var shift: Double = 0.0;
            
            if position < -100.0 {
                shift = 0.16666665 * exp(position/100 + 1.0)
            }
            
            if position > 100.0 {
                shift = 1.0 - 0.16666665 * exp(-position/100 + 1.0)
            }
            
            if -100.0 < position && position < 100.0 {
                shift = 0.16666665 + 0.666666 * (position + 100.0) / 200.0
            }
            
            let width: CGFloat = frame.size.width;
            pointer?.center.x = CGFloat(shift) * (width - 2 * margin) + 6
            pointer?.center.y = frame.height / 2
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
        addBaselineView()
        addZeroView()
        addPointerView()
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0/10.0).isActive = true
    }
    
    func addZeroView() {
        zero.translatesAutoresizingMaskIntoConstraints = false
        addSubview(zero)
        
        zero.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        zero.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        zero.heightAnchor.constraint(equalToConstant: 4.0).isActive = true
        zero.widthAnchor.constraint(equalToConstant: 4.0).isActive = true
        
        zero.layer.cornerRadius = 2.0
        zero.layer.masksToBounds = true
        
        zero.backgroundColor = .white
    }
    
    func addBaselineView() {
        baseline.translatesAutoresizingMaskIntoConstraints = false
        addSubview(baseline)
        
        baseline.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        baseline.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        baseline.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        baseline.backgroundColor = .white
    }
    
    func addPointerView() {
        pointer = PointerView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        addSubview(pointer!)
        hidePointer()
    }
    
    func hidePointer(){
        UIView.animate(withDuration: 0.100) {
            self.pointer?.alpha = 0.0
        }
    }
    
    func showPointer(){
        UIView.animate(withDuration: 0.100) {
            self.pointer?.alpha = 1.0
        }
    }
}
