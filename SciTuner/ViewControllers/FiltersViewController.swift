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
        Filter.allFilters.forEach { self.add(filter: $0) }
        
        addAction(UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel, handler: nil))
    }
    
    func add(filter: Filter){
        let action = UIAlertAction(
            title: filter.localized(), style: UIAlertActionStyle.default,
            handler: {(action: UIAlertAction) -> Void in
                self.tuner.settings.filter = filter
        })
        
        addAction(action)
    }
}
