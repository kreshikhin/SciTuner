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
    let frets = FretsViewController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let filters = FiltersViewController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    let tuner = Tuner.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()

        self.navigationItem.title = "SciTuner"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: tuner.instrument,
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

        let panelFrame = getOptimalPanelFrame(navbarHeight, size: self.view.frame.size)
        var panel = PanelView(frame: panelFrame)
        self.view.addSubview(panel)

        let sampleRate = 44100
        let sampleCount = 2048

        //var source = Source(sampleRate: sampleRate, sampleCount: sampleCount)
        var source = MicSource(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        //var source = MicSource2(sampleRate: Double(sampleRate), sampleCount: sampleCount)

        var processing = ProcessingAdapter(pointCount: 128)
        let tubeFrame = getOptimalTubeFrame(navbarHeight, size: self.view.frame.size)
        var tube = TubeView(frame: tubeFrame)

        tube.wavePoints = [Float](count: Int(processing.pointCount-1)*2*12, repeatedValue: 0)
        tube.waveLightPoints = [Float](count: Int(processing.pointCount-1)*4*12, repeatedValue: 0)

        
        source.onData = {()->Void in
            if self.tuner.isPaused {
                return
            }
            processing.setTargetFrequency(self.tuner.targetFrequency())

            processing.Push(&source.sample)
            processing.SavePreview(&source.preview)
            
            processing.Recalculate()

            processing.buildSmoothStandingWave(&tube.wavePoints, light: &tube.waveLightPoints, length: tube.wavePoints.count, thickness: 0.03)

            self.tuner.setFrequency(processing.getFrequency() + processing.getSubFrequency())

            tube.setNeedsDisplay()
        }
        
        source.activate()
        
        tube.onDraw = {(rect: CGRect) -> () in
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            tube.drawPoints(tube.wavePoints, lightPoints: tube.waveLightPoints)
        }

        self.view.addSubview(tube)

        tuner.on("instrumentChange", {() -> Void in
            self.navigationItem.leftBarButtonItem!.title = self.tuner.instrument
        })
        
        panel.modebar!.fretMode!.addTarget(self, action: Selector("showFrets"), forControlEvents: .TouchUpInside)
        panel.modebar!.filterMode!.addTarget(self, action: Selector("showFilters"), forControlEvents: .TouchUpInside)
        
        tuner.on("frequencyChange", {()in
            panel.actualFrequency!.text = String(format: "%.2fHz", self.tuner.actualFrequency())
            panel.frequencyDeviation!.text = String(format: "%.0fc", self.tuner.frequencyDeviation())
        })
        
        tuner.on("stringChange", {()in
            panel.targetFrequency!.text = String(format: "%.2fHz", self.tuner.targetFrequency())
        })
        
        tuner.on("fretChange", {()in
            panel.targetFrequency!.text = String(format: "%.2fHz", self.tuner.targetFrequency())
        })
        
        panel.targetFrequency!.text = String(format: "%.2fHz", self.tuner.targetFrequency())
        
        tuner.on("filterChange", {()in
            if self.tuner.filter == "on" {
                processing.enableFilter()
            } else {
                processing.disableFilter()
            }
        })
        
        tuner.on("statusChange", {()in
            if self.tuner.status == "active" {
                source.activate()
            } else {
                source.inactivate()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getOptimalTubeFrame(verticalShift: CGFloat, size: CGSize) -> CGRect {
        var h = size.width;
        if size.height < 500 {
            h = 220
        }
        return CGRectMake(
            0, verticalShift,
            size.width, h)
    }

    func getOptimalPanelFrame(verticalShift: CGFloat, size: CGSize) -> CGRect {
        var h = size.width;
        if size.height < 500 {
            h = 220
        }
        return CGRectMake(
            0, verticalShift + h,
            size.width, size.height - h - verticalShift)
    }

    func showInstruments() {
        self.presentViewController(instruments, animated: true, completion: nil)
    }
    
    func showFrets() {
        self.presentViewController(self.frets, animated: true, completion: nil)
    }
    
    func showFilters() {
        self.presentViewController(self.filters, animated: true, completion: nil)
    }
}
