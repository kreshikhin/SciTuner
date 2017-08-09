//
//  FiltersViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 17.03.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class FiltersViewController: UIAlertController {
    let tuner = Tuner.sharedInstance
    
    override func viewDidLoad() {
        addFilter("enable filter".localized(), "on".localized())
        addFilter("disable filter".localized(), "off".localized())
        
        addAction(UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel, handler: nil))
    }
    
    func addFilter(_ title: String, _ value: String){
        let action = UIAlertAction(
            title: title, style: UIAlertActionStyle.default,
            handler: {(action: UIAlertAction) -> Void in
                self.tuner.setFilter(value)
        })
        
        addAction(action)
    }
}
