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
    
    var setPitch = {(pitch: String)->Void in}
    var setTuning = {(values: [String])->Void in}
    
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
        
        let panelFrame = getOptimalPanelFrame(navbarHeight, size: self.view.frame.size)
        var panel = PanelView(frame: panelFrame)
        self.view.addSubview(panel)
        
        let sampleRate = 44100
        let sampleCount = 2205
        
        //var source = Source(sampleRate: sampleRate, sampleCount: sampleCount)
        var source = MicSource(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        //var source = MicSource2(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        
        var processing = ProcessingAdapter(pointCount: 128)
        //processing.setFrequency(200)
        
        let tubeFrame = getOptimalTubeFrame(navbarHeight, size: self.view.frame.size)
        
        var tube = TubeView(frame: tubeFrame)
        
        tube.wavePoints = [Float](count: Int(processing.pointCount)*2*3*4, repeatedValue: 0)
        tube.waveLightPoints = [Float](count: Int(processing.pointCount)*4*3*4, repeatedValue: 0)
        
        //tube.spectrumPoints = [Float](count: 128, repeatedValue: 0)
        
        var tuner = Tuner()
        
        var t = 0.0
        var isPaused = false;
        
        source.onData = {()in
            if isPaused {
                return
            }
            
            processing.Push(&source.sample)
            processing.Recalculate()
            
            processing.buildSmoothStandingWave(&tube.wavePoints, light: &tube.waveLightPoints, length: tube.wavePoints.count, thickness: 0.1)
            
            //processing.buildSpectrumWindow(&tube.spectrumPoints, length: tube.spectrumPoints.count)
            
            tuner.frequency = processing.getFrequency()
            panel.setNotes(tuner.notes)
            
            panel.setNotePosition(tuner.frequencyDeviation())
            panel.setStringPosition(tuner.stringPosition())
            
            panel.stringbar!.targetStringNumber = tuner.targetStringNumber
            
            t += 0.01
            
            tube.setNeedsDisplay()
        }
        
        tube.onDraw = {(rect: CGRect) -> () in
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            tube.drawPoints(tube.wavePoints, lightPoints: tube.waveLightPoints)
        }
        
        self.view.addSubview(tube)
        
        instruments.onChange = {(title: String) -> Void in
            self.navigationItem.leftBarButtonItem!.title = title
        }
        
        panel.stringbar!.strings = ["E2", "A2", "B3", "G3", "D3", "E4", "E5"]
        
        panel.controlbar!.onNextString = {()in
            tuner.nextString()
            panel.stringbar!.targetStringNumber = tuner.targetStringNumber
        }
        
        panel.controlbar!.onPrevString = {()in
            tuner.prevString()
        }
        
        panel.controlbar!.onRecord = {()in
            isPaused = false
        }
        
        panel.controlbar!.onPause = {()in
            isPaused = true
        }
        
        setPitch = {(pitch: String)->Void in
            if pitch == "scientific" {
                tuner.baseFrequency = 256.0
                tuner.baseNote = "c4"
                return
            }
            
            tuner.baseFrequency = 440.0
            tuner.baseNote = "a4"
        }
        
        setTuning = {(values: [String])->Void in
            tuner.strings = values
        }
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

