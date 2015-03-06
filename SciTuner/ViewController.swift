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
    var settings = SettingsViewController()
    var defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()

        settings.onPitchChange = {(pitch: String)->Void in
            //self.defaults.setObjectForKey()

            if pitch == "scientific" {
                self.tube.tuner.baseFrequency = 256.0
                self.tube.tuner.baseNote = "c4"
                return
            }

            self.tube.tuner.baseFrequency = 440.0
            self.tube.tuner.baseNote = "a4"
        }

        settings.onTuningChange = {(values: [String])->Void in
            self.tube.tuner.strings = values
            self.tube.panel.stringbar!.strings = values
        }

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
