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
    let defaults = NSUserDefaults.standardUserDefaults()
    let tuner = Tuner()

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
        let sampleCount = 2048

        //var source = Source(sampleRate: sampleRate, sampleCount: sampleCount)
        var source = MicSource(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        //var source = MicSource2(sampleRate: Double(sampleRate), sampleCount: sampleCount)

        var processing = ProcessingAdapter(pointCount: 128)
        let tubeFrame = getOptimalTubeFrame(navbarHeight, size: self.view.frame.size)
        var tube = TubeView(frame: tubeFrame)

        tube.wavePoints = [Float](count: Int(processing.pointCount-1)*2*12, repeatedValue: 0)
        tube.waveLightPoints = [Float](count: Int(processing.pointCount-1)*4*12, repeatedValue: 0)

        var t = 0.0
        var isPaused = false;

        source.onData = {()in
            if isPaused {
                return
            }
            processing.setTargetFrequency(self.tuner.targetFrequency())

            processing.Push(&source.sample)
            processing.Recalculate()

            processing.buildSmoothStandingWave(&tube.wavePoints, light: &tube.waveLightPoints, length: tube.wavePoints.count, thickness: 0.1)

            tuner.frequency = processing.getFrequency() + processing.getSubFrequency()

            panel.thin!.text = String(format:"%f", processing.getFrequency())
            panel.thick!.text = String(format: "%f", processing.getFrequency() + processing.getSubFrequency())

            panel.setNotePosition(tuner.frequencyDeviation())
            panel.setStringPosition(tuner.stringPosition())

            panel.stringbar!.targetStringNumber = tuner.targetStringNumber

            t += 0.01

            tube.setNeedsDisplay()
        }

        processing.enableFilter()

        tube.onDraw = {(rect: CGRect) -> () in
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            tube.drawPoints(tube.wavePoints, lightPoints: tube.waveLightPoints)
        }

        self.view.addSubview(tube)

        instruments.onChange = {(title: String) -> Void in
            self.navigationItem.leftBarButtonItem!.title = title
            self.settings.instrument = title
        }

        tuner.onStringsChange = {()in
            panel.stringbar!.strings = ["E2", "A2", "B3", "G3", "D3", "E4"]
        }

        tuner.onStringChange = {()in
            panel.stringbar!.targetStringNumber = self.tuner.targetStringNumber
            panel.notebar!.notes = self.tuner.targetNotes()
        }

        // controlbar: prev, pause, next
        panel.controlbar!.onNextString = {()in
            self.tuner.nextString()
        }

        panel.controlbar!.onPrevString = {()in
            self.tuner.prevString()
        }

        panel.controlbar!.onRecord = {()in
            isPaused = false
        }

        panel.controlbar!.onPause = {()in
            isPaused = true
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
