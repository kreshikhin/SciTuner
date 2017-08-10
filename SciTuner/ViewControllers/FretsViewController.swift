//
//  FretsViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 08.03.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class FretsViewController: UIAlertController {
    let tuner = Tuner.sharedInstance
    
    override func viewDidLoad() {
        Fret.allFrets.forEach { self.add(fret: $0) }
        
        addAction(UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel, handler: nil))
    }
    
    func add(fret: Fret){
        let action = UIAlertAction(
            title: fret.localized(), style: UIAlertActionStyle.default,
            handler: {(action: UIAlertAction) -> Void in
                self.tuner.settings.fret = fret
                self.tuner.updateSettings()
        })
        
        addAction(action)
    }
}
