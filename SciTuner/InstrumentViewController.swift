//
//  InstrumentViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 26.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class InstrumentViewController: UIAlertController {
    override func viewDidLoad() {
        addAction(UIAlertAction(
            title: "✓ guitar  ", style: UIAlertActionStyle.Default, handler: nil))
        
        addAction(UIAlertAction(
            title: "ukulule", style: UIAlertActionStyle.Default, handler: nil))
        
        addAction(UIAlertAction(
            title: "violin", style: UIAlertActionStyle.Default, handler: nil))
        
        addAction(UIAlertAction(
            title: "free mode", style: UIAlertActionStyle.Default, handler: nil))
        
        addAction(UIAlertAction(
            title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
    }
}