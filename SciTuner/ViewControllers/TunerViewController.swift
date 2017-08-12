//
//  TunerViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 25.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import UIKit
import SpriteKit
import RealmSwift

class TunerViewController: UIViewController {
    typealias `Self` = TunerViewController
    
    let realm = try! Realm()
    
    var settingsViewController = SettingsViewController()
    
    var instrumentsAlertController = InstrumentsAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    var frets = FretsViewController(title: nil, message: nil, preferredStyle: .actionSheet)
    var filters = FiltersViewController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    var tuner = Tuner.sharedInstance
    
    var tubeView: SKView?
    var tubeScene: TubeScene?
    
    var panel: PanelView?
    
    let processing = Processing(pointCount: 128)
    
    var microphone: Microphone?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tuner.delegate = self
        
        self.instrumentsAlertController.parentDelegate = self

        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "SciTuner".localized()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: tuner.instrument.localized(),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(Self.showInstrumentsAlertController))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "settings".localized(),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(Self.showSettingsViewController))

        let navbarHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController!).navigationBar.frame.size.height

        let panelFrame = getOptimalPanelFrame(navbarHeight, size: self.view.frame.size)
        
        panel = PanelView(frame: panelFrame)
        self.view.addSubview(panel!)

        let sampleRate = 44100
        let sampleCount = 2048

        microphone = Microphone(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        microphone?.delegate = self
        
        let tubeFrame = getOptimalTubeFrame(navbarHeight, size: self.view.frame.size)
        tubeView = SKView(frame: tubeFrame)
        
        if let tb = tubeView {
            self.view.addSubview(tb)
            
            //tb.showsFPS = true
            //skView.showsNodeCount = true
            tubeScene = TubeScene(size: tb.bounds.size)
            tb.presentScene(tubeScene)
            //mainScene?.clipSceneDelegate = self
            tb.ignoresSiblingOrder = true
        }
        
        microphone?.activate()
        
        panel?.modebar?.fretMode?.addTarget(self, action: #selector(TunerViewController.showFrets), for: .touchUpInside)
        panel?.modebar?.filterMode?.addTarget(self, action: #selector(TunerViewController.showFilters), for: .touchUpInside)
        
        panel?.targetFrequency!.text = String(format: "%.2f %@", self.tuner.targetFrequency(), "Hz".localized())
        
        switch tuner.filter {
        case .on:
            processing.enableFilter()
        case .off:
            processing.disableFilter()
        }
    }
    
    func showSettingsViewController() {
        self.navigationController?.pushViewController(settingsViewController, animated: true)
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

    func showInstrumentsAlertController() {
        self.present(self.instrumentsAlertController, animated: true, completion: nil)
    }
    
    func showFrets() {
        self.present(self.frets, animated: true, completion: nil)
    }
    
    func showFilters() {
        self.present(self.filters, animated: true, completion: nil)
    }
}

extension TunerViewController: TunerDelegate {
    func didSettingsUpdate() {
        // didInstrumentChange
        
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
            self.microphone?.activate()
        } else {
            self.microphone?.inactivate()
        }
    }
}

extension TunerViewController: MicrophoneDelegate {
    func microphone(_ microphone: Microphone?, didReceive data: [Double]?) {
        if self.tuner.isPaused {
            return
        }
        self.processing.setTargetFrequency(self.tuner.targetFrequency())
        
        guard let micro = self.microphone else {
            return
        }
        
        var wavePoints = [Double](repeating: 0, count: Int(self.processing.pointCount-1))
        
        self.processing.push(&micro.sample)
        self.processing.savePreview(&micro.preview)
        
        self.processing.recalculate()
        
        self.processing.buildSmoothStandingWave2(&wavePoints, length: wavePoints.count)
        
        self.tuner.setFrequency(self.processing.getFrequency() + self.processing.getSubFrequency())
        
        self.tubeScene?.draw(wave: wavePoints)
    }
}

extension TunerViewController: InstrumentsAlertControllerDelegate {
    func didChange(instrument: Instrument) {
        try! self.realm.write {
            self.tuner.settings.instrument = instrument
        }
        
        self.navigationItem.leftBarButtonItem?.title = self.tuner.instrument.localized()
    }
}
