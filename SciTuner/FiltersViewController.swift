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
        addFilter("enable filter", "on")
        addFilter("disable filter", "off")
        
        addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil))
    }
    
    func addFilter(title: String, _ value: String){
        let action = UIAlertAction(
            title: title, style: UIAlertActionStyle.Default,
            handler: {(action: UIAlertAction) -> Void in
                self.tuner.setFilter(value)
        })
        
        addAction(action)
    }
}