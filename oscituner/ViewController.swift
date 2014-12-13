//
//  ViewController.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 11.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let f = self.view.frame
        NSLog("%@ %@ %@ %@", f.origin.x, f.origin.y, f.size.width, f.size.height)
        
        var source = Source()
        // var source = MicSource()
        
        let tubeFrame = getOptimalTubeFrame(self.view.frame.size)
        var tube = TubeView(frame: tubeFrame)
        
        
        
        
        self.view.addSubview(tube)
        
        let panelFrame = getOptimalPanelFrame(self.view.frame.size)
        self.view.addSubview(PanelView(frame: panelFrame))
        
        self.view.backgroundColor = UIColor.redColor()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getOptimalTubeFrame(size: CGSize) -> CGRect {
        var height: CGFloat = 100.0
        
        if size.width > 568 { // 6
            height = 117.2
        }
        
        if size.width > 667 { //6s
            height = 177.5
        }
        
        return CGRectMake(0, 0, size.width, size.height - height)
    }
    
    func getOptimalPanelFrame(size: CGSize) -> CGRect {
        var height: CGFloat = 100.0
        
        if size.width > 568 { // 6
            height = 117.2
        }
        
        if size.width > 667 { //6s
            height = 177.5
        }
        
        return CGRectMake(0, size.height - height, size.width, height)
    }
}
