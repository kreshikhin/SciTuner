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
    var fretsAlertController = FretsAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    var filtersAlertController = FiltersAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    var tuner = Tuner.sharedInstance
    
    var tubeView: SKView?
    var tubeScene: TubeScene?
    
    var panel: PanelView?
    
    let processing = Processing(pointCount: 128)
    
    var microphone: Microphone?
    
    let stackView = UIStackView()
    
    var frequencyBarView: FrequencyBarView?
    
    let tuningView = TuningView()
    let modebar = ModebarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeNavigationBar()
        addStackView()
        customizeDelegates()
        
        addTubeView()
        addTuningView()
        addModeBar()

        let sampleRate = 44100
        let sampleCount = 2048
        microphone = Microphone(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        microphone?.delegate = self
        
        microphone?.activate()
        
        //frequencyBarView = FrequencyBarView()
        //stackView.addArrangedSubview(frequencyBarView!)
        
        panel?.targetFrequency!.text = String(format: "%.2f %@", self.tuner.targetFrequency(), "Hz".localized())
        
        switch tuner.filter {
        case .on:
            processing.enableFilter()
        case .off:
            processing.disableFilter()
        }
    }
    
    func customizeDelegates() {
        tuner.delegate = self
        instrumentsAlertController.parentDelegate = self
        fretsAlertController.parentDelegate = self
        filtersAlertController.parentDelegate = self
    }
    
    func customizeNavigationBar() {
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
    }
    
    func addStackView() {
        stackView.frame = view.bounds
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        //stackView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func addTubeView() {
        tubeView = SKView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width))
        tubeView?.translatesAutoresizingMaskIntoConstraints = false
        tubeView?.heightAnchor.constraint(equalTo: tubeView!.widthAnchor, multiplier: 1.0).isActive = true
        stackView.addArrangedSubview(tubeView!)
        
        if let tb = tubeView {
            //tb.showsFPS = true
            //skView.showsNodeCount = true
            tubeScene = TubeScene(size: tb.bounds.size)
            tb.presentScene(tubeScene)
            //mainScene?.clipSceneDelegate = self
            tb.ignoresSiblingOrder = true
            
            tubeScene?.customDelegate = self
        }
    }
    
    func addModeBar() {
        modebar.fretMode?.addTarget(self, action: #selector(TunerViewController.showFrets), for: .touchUpInside)
        modebar.filterMode?.addTarget(self, action: #selector(TunerViewController.showFilters), for: .touchUpInside)
        stackView.addArrangedSubview(modebar)
    }
    
    func addTuningView() {
        stackView.addArrangedSubview(tuningView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tuningView.tuning = tuner.tuning
    }
    
    func showSettingsViewController() {
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    func showInstrumentsAlertController() {
        self.present(self.instrumentsAlertController, animated: true, completion: nil)
    }
    
    func showFrets() {
        self.present(self.fretsAlertController, animated: true, completion: nil)
    }
    
    func showFilters() {
        self.present(self.filtersAlertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TunerViewController: TunerDelegate {
    func didSettingsUpdate() {
        // didInstrumentChange
        
        // didFrequencyChange

        //didTuningChange()
        self.panel?.stringbar?.strings = self.tuner.tuning.strings
        self.panel?.stringbar?.stringIndex = self.tuner.stringIndex
        //didStringChange()
        

        
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
        
        self.tuner.frequency = self.processing.getFrequency()
        
        self.tubeScene?.draw(wave: wavePoints)
        
        self.panel?.actualFrequency?.text = String(format: "%.2f %@", self.tuner.frequency, "Hz".localized())
        self.panel?.frequencyDeviation!.text = String(format: "%.0fc", self.tuner.frequencyDeviation())
        //self.panel?.notebar?.pointerPosition = self.tuner.stringPosition()
        self.panel?.notebar?.pointerPosition = self.tuner.frequencyDeviation()
        self.panel?.targetFrequency?.text = String(format: "%.2f %@", self.tuner.targetFrequency(), "Hz".localized())
    }
}

extension TunerViewController: InstrumentsAlertControllerDelegate {
    func didChange(instrument: Instrument) {
        try! realm.write {
            tuner.instrument = instrument
        }
        
        tuningView.tuning = tuner.tuning
        navigationItem.leftBarButtonItem?.title = tuner.instrument.localized()
    }
}

extension TunerViewController: FretsAlertControllerDelegate {
    func didChange(fret: Fret) {
        try! self.realm.write {
            self.tuner.settings.fret = fret
        }
    }
}

extension TunerViewController: FiltersAlertControllerDelegate {
    func didChange(filter: Filter) {
        try! self.realm.write {
            self.tuner.settings.filter = filter
        }
    }
}

extension TunerViewController: TubeSceneDelegate {
    func getNotePosition() -> CGFloat {
        return CGFloat(tuner.notePosition())
    }
}
