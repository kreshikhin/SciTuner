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
        addInstrument("guitar")
        addInstrument("ukulele")
        addInstrument("banjo")
        addInstrument("balalaika")
        addInstrument("cello")
        addInstrument("violin")
        //addInstrument("free mode")
        
        addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil))
    }
    
    func addInstrument(title: String){
        var action = UIAlertAction(
            title: title, style: UIAlertActionStyle.Default,
            handler: {(action: UIAlertAction?) -> Void in
                self.tuner.setInstrument(title)
        })
        
        addAction(action)
    }
}