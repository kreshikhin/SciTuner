//
//  TuningView.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 8/16/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import UIKit
import CoreText

class TuningView: UIView {
    var labels: [UILabel] = []
    let stackView = UIStackView()
    var pointerView = PointerView(frame: CGRect())
    
    let defaultMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    var tuning: Tuning? {
        didSet {
            labels.forEach { $0.removeFromSuperview() }
            labels.removeAll()
            
            for note in tuning?.strings ?? [] {
                let label = UILabel()
                label.backgroundColor = .red
                label.text = note.string
                labels.append(label)
                
                label.translatesAutoresizingMaskIntoConstraints = false
                label.heightAnchor.constraint(equalTo: label.widthAnchor).isActive = true
                
                label.textColor = UIColor.white
                label.backgroundColor = UIColor.clear
                
                stackView.addArrangedSubview(label)
            }
        }
    }
    
    var notePosition: CGFloat = 0 {
        didSet {
            let height = frame.size.height / 2
            
            let firstCenterX = labels.first?.center.x ?? 0
            let lastCenterX = labels.last?.center.x ?? frame.size.width
            
            if let count = tuning?.strings.count {
                let step = (lastCenterX - firstCenterX) / CGFloat(count - 1)
                var shift = notePosition
                
                print("noteposition", notePosition)
                
                if notePosition < 0.0 {
                    shift = 0.5 * exp(notePosition) - 0.5
                }
                
                if notePosition > CGFloat(count) - 1.0 {
                    shift = CGFloat(count) - 0.5 * exp(-notePosition+CGFloat(count)-1)
                }
                
                pointerView.frame.size = CGSize(width: height, height: height)
                pointerView.layer.cornerRadius = height / 2
                
                pointerView.center.x = CGFloat(shift) * step + firstCenterX
                pointerView.center.y = frame.size.height / 2
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        stackView.layoutMargins = defaultMargins
        stackView.isLayoutMarginsRelativeArrangement = true
        
        addSubview(pointerView)
        
        hidePointer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hidePointer(){
        UIView.animate(withDuration: 0.100) {
            self.pointerView.alpha = 0.0
        }
    }
    
    func showPointer(){
        UIView.animate(withDuration: 0.100) {
            self.pointerView.alpha = 1.0
        }
    }
}
