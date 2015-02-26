//
//  TubeViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 25.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import UIKit

class TubeViewController: UIViewController {
    var wavePoints: [Double] = [Double](count: 512, repeatedValue: 0)
    var spectrumPoints: [Double] = [Double](count: 512, repeatedValue: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "SciTuner"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "guitar",
            style: UIBarButtonItemStyle.Plain,
            target: nil,
            action: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "settings",
            style: UIBarButtonItemStyle.Plain,
            target: self.parentViewController,
            action: Selector("showSettings"))
        
        let f = self.view.frame
        NSLog("%@ %@ %@ %@", f.origin.x, f.origin.y, f.size.width, f.size.height)
        
        let sampleRate = 44100
        let sampleCount = 2205
        
        //var source = Source(sampleRate: sampleRate, sampleCount: sampleCount)
        var source = MicSource(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        //var source = MicSource2(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        
        var processing = ProcessingAdapter()
        //processing.setFrequency(200)
        
        let tubeFrame = getOptimalTubeFrame(self.view.frame.size)
        var tube = TubeView(frame: tubeFrame)
        
        tube.wavePoints = [Float](count: 512, repeatedValue: 0)
        tube.spectrumPoints = [Float](count: 512, repeatedValue: 0)
        
        source.onData = { () -> () in
            processing.Push(&source.sample)
        
            processing.Recalculate()
        
            processing.buildStandingWave(&tube.wavePoints, length: tube.wavePoints.count)
            processing.buildSpectrumWindow(&tube.spectrumPoints, length: tube.spectrumPoints.count)
        
            var freq = processing.getFrequency()
            tube.frequency = String(format: "%.2f Hz", freq)
        
            tube.setNeedsDisplay()
        }
        
        tube.onDraw = {(rect: CGRect) -> () in
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
            var text = tube.frequency //"123.45 Hz"
        
            /*renderInFramebuffer({ () -> () in
            self.capture(self.blendProgram)
            self.drawPoints(self.wavePoints)
            self.drawPoints(self.spectrumPoints)
            self.drawText(text)
            })*/
        
            tube.bindDrawable()
        
            //capture(textureProgram)
            tube.drawPoints(tube.wavePoints)
            tube.drawPoints(tube.spectrumPoints)
            tube.drawText(text, x:0, y: 0, w: 0.05, h: 0.05, step: 0.07)
        }
        
        self.view.addSubview(tube)
        
        //let panelFrame = getOptimalPanelFrame(self.view.frame.size)
        //self.view.addSubview(PanelView(frame: panelFrame))
        
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
        
        return CGRectMake(0, 0, size.width, size.height)
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

