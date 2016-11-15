//
//  TubeViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 25.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import UIKit

class TubeViewController: UIViewController {
    var instruments = InstrumentsViewController(title: nil, message: nil, preferredStyle: .actionSheet)
    var frets = FretsViewController(title: nil, message: nil, preferredStyle: .actionSheet)
    var filters = FiltersViewController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    var tuner = Tuner.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        self.navigationItem.title = "SciTuner"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: tuner.instrument,
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(TubeViewController.showInstruments))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "settings",
            style: UIBarButtonItemStyle.plain,
            target: self.parent,
            action: #selector(ViewController.showSettings))

        let navbarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController!).navigationBar.frame.size.height

        let panelFrame = getOptimalPanelFrame(navbarHeight, size: self.view.frame.size)
        let panel = PanelView(frame: panelFrame)
        self.view.addSubview(panel)

        let sampleRate = 44100
        let sampleCount = 2048

        //var source = Source(sampleRate: sampleRate, sampleCount: sampleCount)
        let source = MicSource(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        //var source = MicSource2(sampleRate: Double(sampleRate), sampleCount: sampleCount)

        let processing = ProcessingAdapter(pointCount: 128)
        let tubeFrame = getOptimalTubeFrame(navbarHeight, size: self.view.frame.size)
        let tube = TubeView(frame: tubeFrame)

        tube.wavePoints = [Float](repeating: 0, count: Int(processing.pointCount-1)*2*12)
        tube.waveLightPoints = [Float](repeating: 0, count: Int(processing.pointCount-1)*4*12)

        
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
        
        panel.modebar!.fretMode!.addTarget(self, action: #selector(TubeViewController.showFrets), for: .touchUpInside)
        panel.modebar!.filterMode!.addTarget(self, action: #selector(TubeViewController.showFilters), for: .touchUpInside)
        
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
        
        if self.tuner.filter == "on" {
            processing.enableFilter()
        } else {
            processing.disableFilter()
        }
        
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

    func getOptimalTubeFrame(_ verticalShift: CGFloat, size: CGSize) -> CGRect {
        var h = size.width;
        if size.height < 500 {
            h = 220
        }
        return CGRect(
            x: 0, y: verticalShift,
            width: size.width, height: h)
    }

    func getOptimalPanelFrame(_ verticalShift: CGFloat, size: CGSize) -> CGRect {
        var h = size.width;
        if size.height < 500 {
            h = 220
        }
        return CGRect(
            x: 0, y: verticalShift + h,
            width: size.width, height: size.height - h - verticalShift)
    }

    func showInstruments() {
        self.present(instruments, animated: true, completion: nil)
    }
    
    func showFrets() {
        self.present(self.frets, animated: true, completion: nil)
    }
    
    func showFilters() {
        self.present(self.filters, animated: true, completion: nil)
    }
}
