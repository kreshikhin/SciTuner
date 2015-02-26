//
//  ViewController.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 11.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit

class ViewController: UINavigationController {
    var tube = TubeViewController()
    var settings = SettingViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.pushViewController(tube, animated: false)
    }
    
    func showSettings(){
        self.pushViewController(settings, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
