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
    var onChange = {(title: String) -> Void in }
    
    override func viewDidLoad() {
        addInstrument("guitar")
        addInstrument("ukulule")
        addInstrument("violin")
        addInstrument("free mode")
        
        self.title = "guitar"
        
        addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil))
    }
    
    func addInstrument(title: String){
        var action = UIAlertAction(
            title: title, style: UIAlertActionStyle.Default,
            handler: {(action: UIAlertAction?) -> Void in
                self.onChange(action!.title)
        })
        
        addAction(action)
    }
}