//
//  InstrumentViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 26.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class InstrumentsViewController: UIAlertController {
    let tuner = Tuner.sharedInstance
    
    override func viewDidLoad() {
        addInstrument("guitar".localized())
        addInstrument("ukulele".localized())
        addInstrument("banjo".localized())
        addInstrument("balalaika".localized())
        addInstrument("cello".localized())
        addInstrument("violin".localized())
        
        addAction(UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel, handler: nil))
    }
    
    func addInstrument(_ title: String){
        let action = UIAlertAction(
            title: title, style: UIAlertActionStyle.default,
            handler: {(action: UIAlertAction) -> Void in
                self.tuner.setInstrument(title)
        })
        
        addAction(action)
    }
}
