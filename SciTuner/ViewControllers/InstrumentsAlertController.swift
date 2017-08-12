//
//  InstrumentAlertController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 26.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

protocol InstrumentsAlertControllerDelegate: class {
    func didChange(instrument: Instrument)
}

class InstrumentsAlertController: UIAlertController {
    weak var parentDelegate: InstrumentsAlertControllerDelegate?
    
    override func viewDidLoad() {
        Instrument.all.forEach { self.add(instrument: $0) }
        
        addAction(UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel, handler: nil))
    }
    
    func add(instrument: Instrument){
        let action = UIAlertAction(
            title: instrument.localized(), style: UIAlertActionStyle.default,
            handler: {(action: UIAlertAction) -> Void in
                self.parentDelegate?.didChange(instrument: instrument)
        })
        
        addAction(action)
    }
}
