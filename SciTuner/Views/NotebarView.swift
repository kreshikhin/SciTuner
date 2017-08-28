//
//  NotebarView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 27.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class NotebarView: UIView {
    let tuner = Tuner.sharedInstance
    
    let margin: CGFloat = 10
    
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
            pointer!.frame.origin.x = CGFloat(shift) * (width - 2 * margin) + 6
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
        
        let baseline = UIView()
        baseline.translatesAutoresizingMaskIntoConstraints = false
        addSubview(baseline)
        baseline.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        baseline.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        baseline.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        baseline.backgroundColor = .black
        
        let stripe = UIView()
        stripe.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stripe)
        stripe.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stripe.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stripe.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1).isActive = true
        stripe.widthAnchor.constraint(equalToConstant: 3.0).isActive = true
        stripe.backgroundColor = .black
        
        pointer = PointerView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        addSubview(pointer!)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0/10.0).isActive = true
        
        backgroundColor = .green
        
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
