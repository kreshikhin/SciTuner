//
//  TuningView
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
    var noteView = UIView()
    
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
                
                noteView.frame.size = CGSize(width: height, height: height)
                
                noteView.layer.cornerRadius = height / 2
                noteView.layer.masksToBounds = true
                noteView.layer.borderWidth = 2
                noteView.layer.borderColor = UIColor.white.cgColor
                
                noteView.center.x = CGFloat(shift) * step + firstCenterX
                noteView.center.y = frame.size.height / 2
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
        
        stackView.backgroundColor = .cyan
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        stackView.layoutMargins = defaultMargins
        stackView.isLayoutMarginsRelativeArrangement = true
        
        noteView.backgroundColor = .clear
        noteView.layer.borderColor = UIColor.white.cgColor
        noteView.layer.borderWidth = 1
        
        backgroundColor = .blue
        
        addSubview(noteView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    //override func draw(_ rect: CGRect) {
    //}
}
