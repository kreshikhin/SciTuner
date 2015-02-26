//
//  TubeViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 25.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import UIKit

class TubeViewController: UIViewController {
    let instruments = InstrumentsViewController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    var wavePoints: [Double] = [Double](count: 512, repeatedValue: 0)
    var spectrumPoints: [Double] = [Double](count: 512, repeatedValue: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = "SciTuner"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "guitar",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: Selector("showInstruments"))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "settings",
            style: UIBarButtonItemStyle.Plain,
            target: self.parentViewController,
            action: Selector("showSettings"))
        
        let navbarHeight = UIApplication.sharedApplication().statusBarFrame.size.height + (self.navigationController!).navigationBar.frame.size.height
        
        let f = self.view.frame;
        
        NSLog("%@ %@ %@ %@ %@", navbarHeight, f.origin.x, f.origin.y, f.size.width, f.size.height)
        
        let sampleRate = 44100
        let sampleCount = 2205
        
        var source = Source(sampleRate: sampleRate, sampleCount: sampleCount)
        //var source = MicSource(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        //var source = MicSource2(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        
        var processing = ProcessingAdapter()
        //processing.setFrequency(200)
        
        let tubeFrame = getOptimalTubeFrame(navbarHeight, size: self.view.frame.size)
        
        var tube = TubeView(frame: tubeFrame)
        
        tube.wavePoints = [Float](count: 128, repeatedValue: 0)
        tube.spectrumPoints = [Float](count: 128, repeatedValue: 0)
        
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
        
        let panelFrame = getOptimalPanelFrame(navbarHeight, size: self.view.frame.size)
        
        self.view.addSubview(PanelView(frame: panelFrame))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getOptimalTubeFrame(verticalShift: CGFloat, size: CGSize) -> CGRect {
        return CGRectMake(
            0, verticalShift,
            size.width, size.width)
    }
    
    func getOptimalPanelFrame(verticalShift: CGFloat, size: CGSize) -> CGRect {
        return CGRectMake(
            0, verticalShift + size.width,
            size.width, size.height - size.width - verticalShift)
    }
    
    func showInstruments() {
        self.presentViewController(instruments, animated: true, completion: nil)
    }
}

