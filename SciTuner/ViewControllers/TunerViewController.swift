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
    
    let processing = Processing(pointCount: Settings.processingPointCount)
    
    var microphone: Microphone?
    
    let stackView = UIStackView()
    
    let tuningView = TuningView()
    let modebar = ModebarView()
    let fineTuningView = FineTuningView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Style.background
        
        customizeNavigationBar()
        addStackView()
        customizeDelegates()
        
        addTubeView()
        addNoteBar()
        addTuningView()
        addModeBar()

        microphone = Microphone(sampleRate: Settings.sampleRate, sampleCount: Settings.sampleCount)
        microphone?.delegate = self
        microphone?.activate()
        
        switch tuner.filter {
        case .on:
            processing.enableFilter()
        case .off:
            processing.disableFilter()
        }
        
        modebar.fret = tuner.fret
        modebar.filter = tuner.filter
    }
    
    func customizeDelegates() {
        tuner.delegate = self
        instrumentsAlertController.parentDelegate = self
        fretsAlertController.parentDelegate = self
        filtersAlertController.parentDelegate = self
    }
    
    func customizeNavigationBar() {
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
    }
    
    func addTubeView() {
        tubeView = SKView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width))
        tubeView?.translatesAutoresizingMaskIntoConstraints = false
        tubeView?.heightAnchor.constraint(equalTo: tubeView!.widthAnchor, multiplier: 1.0).isActive = true
        stackView.addArrangedSubview(tubeView!)
        
        if let tb = tubeView {
            tb.showsFPS = Settings.showFPS
            tubeScene = TubeScene(size: tb.bounds.size)
            tb.presentScene(tubeScene)
            tb.ignoresSiblingOrder = true
            
            tubeScene?.customDelegate = self
        }
    }
    
    func addModeBar() {
        modebar.fretMode.addTarget(self, action: #selector(TunerViewController.showFrets), for: .touchUpInside)
        modebar.filterMode.addTarget(self, action: #selector(TunerViewController.showFilters), for: .touchUpInside)
        stackView.addArrangedSubview(modebar)
    }
    
    func addNoteBar() {
        stackView.addArrangedSubview(fineTuningView)
    }
    
    func addTuningView() {
        stackView.addArrangedSubview(tuningView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tuningView.tuning = tuner.tuning
    }
    
    func showSettingsViewController() {
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    func showInstrumentsAlertController() {
        present(instrumentsAlertController, animated: true, completion: nil)
    }
    
    func showFrets() {
        present(fretsAlertController, animated: true, completion: nil)
    }
    
    func showFilters() {
        present(filtersAlertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TunerViewController: TunerDelegate {
    func didSettingsUpdate() {
        switch tuner.filter {
        case .on: processing.enableFilter()
        case .off: processing.disableFilter()
        }
    }
    
    func didFrequencyChange() {
        //panel?.targetFrequency?.text = String(format: "%.2f %@", tuner.targetFrequency(), "Hz".localized())
    }
    
    func didStatusChange() {
        if tuner.isActive {
            microphone?.activate()
        } else {
            microphone?.inactivate()
        }
    }
}

extension TunerViewController: MicrophoneDelegate {
    func microphone(_ microphone: Microphone?, didReceive data: [Double]?) {
        if tuner.isPaused {
            return
        }
        
        if let tf = tuner.targetFrequency() {
            processing.setTargetFrequency(tf)
        }
        
        guard let micro = microphone else {
            return
        }
        
        var wavePoints = [Double](repeating: 0, count: Int(processing.pointCount-1))
        
        processing.push(&micro.sample)
        processing.savePreview(&micro.preview)
        
        processing.recalculate()
        
        processing.buildSmoothStandingWave2(&wavePoints, length: wavePoints.count)
        
        tuner.frequency = processing.getFrequency()
        tuner.updateTargetFrequency()
        
        tubeScene?.draw(wave: wavePoints)
        
        //panel?.actualFrequency?.text = String(format: "%.2f %@", tuner.frequency, "Hz".localized())
        //panel?.frequencyDeviation!.text = String(format: "%.0fc", tuner.frequencyDeviation())
        //self.panel?.notebar?.pointerPosition = self.tuner.stringPosition()
        fineTuningView.pointerPosition = tuner.noteDeviation()
        
        //print("f dev:", tuner.frequencyDeviation())
        
        tuningView.notePosition = CGFloat(tuner.stringPosition())
        
        if processing.pulsation() > 5 {
            tuningView.showPointer()
            fineTuningView.showPointer()
        } else {
            tuningView.hidePointer()
            fineTuningView.hidePointer()
        }
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
        try! realm.write {
            tuner.fret = fret
        }
        
        modebar.fret = fret
    }
}

extension TunerViewController: FiltersAlertControllerDelegate {
    func didChange(filter: Filter) {
        try! realm.write {
            tuner.filter = filter
        }
        
        modebar.filter = filter
    }
}

extension TunerViewController: TubeSceneDelegate {
    func getNotePosition() -> CGFloat {
        return CGFloat(tuner.notePosition())
    }
    
    func getPulsation() -> CGFloat {
        return CGFloat(processing.pulsation())
    }
}
