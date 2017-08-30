//
//  ViewController.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 11.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit

class ViewController: UINavigationController {
    var tunerViewController = TunerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Style.background
        
        pushViewController(tunerViewController, animated: false)
        
        UINavigationBar.appearance().tintColor = Style.text
        UINavigationBar.appearance().barTintColor = Style.background
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Style.text]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
