//
//  TubeViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 25.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import UIKit
import SpriteKit

class TubeViewController: UIViewController {
    var instruments = InstrumentsViewController(title: nil, message: nil, preferredStyle: .actionSheet)
    var frets = FretsViewController(title: nil, message: nil, preferredStyle: .actionSheet)
    var filters = FiltersViewController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    var tuner = Tuner.sharedInstance
    
    var tubeView: SKView?
    var tubeScene: TubeScene?
    
    var panel: PanelView?
    
    let processing = ProcessingAdapter(pointCount: 128)
    
    var source: MicSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tuner.delegate = self

        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "SciTuner".localized()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: tuner.instrument.localized(),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(TubeViewController.showInstruments))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "settings".localized(),
            style: UIBarButtonItemStyle.plain,
            target: self.parent,
            action: #selector(ViewController.showSettings))

        let navbarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController!).navigationBar.frame.size.height

        let panelFrame = getOptimalPanelFrame(navbarHeight, size: self.view.frame.size)
        
        panel = PanelView(frame: panelFrame)
        self.view.addSubview(panel!)

        let sampleRate = 44100
        let sampleCount = 2048

        //let source = Source(sampleRate: sampleRate, sampleCount: sampleCount)
        source = MicSource(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        
        let tubeFrame = getOptimalTubeFrame(navbarHeight, size: self.view.frame.size)
        //showTube(source: source, frame: tubeFrame, proc: processing)
        showTubeView(source!, frame: tubeFrame, proc: processing)
        
        panel?.modebar?.fretMode?.addTarget(self, action: #selector(TubeViewController.showFrets), for: .touchUpInside)
        panel?.modebar?.filterMode?.addTarget(self, action: #selector(TubeViewController.showFilters), for: .touchUpInside)
        
        panel?.targetFrequency!.text = String(format: "%.2f %@", self.tuner.targetFrequency(), "Hz".localized())
        
        switch tuner.filter {
        case .on:
            processing.enableFilter()
        case .off:
            processing.disableFilter()
        }
    }
    
    func showTubeView<T: MicSource>(_ source: T, frame: CGRect, proc: ProcessingAdapter) {
        tubeView = SKView(frame: frame)
        
        var wavePoints = [Double](repeating: 0, count: Int(proc.pointCount-1))
        
        if let tb = tubeView {
            self.view.addSubview(tb)
            
            //tb.showsFPS = true
            //skView.showsNodeCount = true
            tubeScene = TubeScene(size: tb.bounds.size)
            tb.presentScene(tubeScene)
            //mainScene?.clipSceneDelegate = self
            tb.ignoresSiblingOrder = true
        }
        
        source.onData = {()->Void in
            if self.tuner.isPaused {
                return
            }
            proc.setTargetFrequency(self.tuner.targetFrequency())
            
            proc.Push(&source.sample)
            proc.SavePreview(&source.preview)
            
            proc.Recalculate()
            
            proc.buildSmoothStandingWave2(&wavePoints, length: wavePoints.count)
            
            self.tuner.setFrequency(proc.getFrequency() + proc.getSubFrequency())
            
            self.tubeScene?.draw(wave: wavePoints)
        }
        
        source.activate()
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

extension TubeViewController: TunerDelegate {
    func didSettingsUpdate() {
        // didInstrumentChange
        self.navigationItem.leftBarButtonItem?.title = self.tuner.settings.instrument.localized()
        // didFrequencyChange
        self.panel?.actualFrequency?.text = String(format: "%.2f %@", self.tuner.actualFrequency(), "Hz".localized())
        self.panel?.frequencyDeviation!.text = String(format: "%.0fc", self.tuner.frequencyDeviation())
        
        self.panel?.notebar?.pointerPosition = self.tuner.stringPosition()
        self.panel?.notebar?.pointerPosition = self.tuner.frequencyDeviation()
        //didTuningChange()
        self.panel?.stringbar?.strings = self.tuner.tuning.strings
        self.panel?.stringbar?.stringIndex = self.tuner.stringIndex
        //didStringChange()
        self.panel?.targetFrequency?.text = String(format: "%.2f %@", self.tuner.targetFrequency(), "Hz".localized())
        
        self.panel?.stringbar?.stringIndex = self.tuner.stringIndex
        //self.panel?.notebar?.notes = self.tuner.notes
        // didPitchChange()
        // didFretChange()
        // didFilterChange
        
        switch self.tuner.settings.filter {
        case .on: self.processing.enableFilter()
        case .off: self.processing.disableFilter()
        }
    }
    
    func didFrequencyChange() {
        self.panel?.targetFrequency?.text = String(format: "%.2f %@", self.tuner.targetFrequency(), "Hz".localized())
    }
    
    func didStatusChange() {
        if self.tuner.status == "active" {
            self.source?.activate()
        } else {
            self.source?.inactivate()
        }
    }
}
