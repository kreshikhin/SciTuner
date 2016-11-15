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
        addFret("5th fret", 5)
        addFret("7th fret", 7)
        addFret("12th fret", 12)
        addFret("open strings", 0)
        
        addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler: nil))
    }
    
    func addFret(_ title: String, _ fret: Int){
        let action = UIAlertAction(
            title: title, style: UIAlertActionStyle.default,
            handler: {(action: UIAlertAction) -> Void in
                self.tuner.setFret(fret)
        })
        
        addAction(action)
    }
}
