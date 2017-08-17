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
    
    var tuning: Tuning? {
        didSet {
            labels.forEach { $0.removeFromSuperview() }
            labels.removeAll()
            
            for note in tuning?.strings ?? [] {
                let label = UILabel()
                label.backgroundColor = .red
                label.text = note.string
                labels.append(label)
                stackView.addArrangedSubview(label)
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
        
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    //override func draw(_ rect: CGRect) {
    //}
}
