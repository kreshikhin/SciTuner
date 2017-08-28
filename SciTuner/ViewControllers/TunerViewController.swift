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
    let notebar = NotebarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeNavigationBar()
        addStackView()
        customizeDelegates()
        
        addTubeView()
        addNoteBar()
        addTuningView()
        addModeBar()

        let sampleRate = 44100
        let sampleCount = 2048
        microphone = Microphone(sampleRate: Double(sampleRate), sampleCount: sampleCount)
        microphone?.delegate = self
        
        microphone?.activate()
        
        //frequencyBarView = FrequencyBarView()
        //stackView.addArrangedSubview(frequencyBarView!)
        
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
    
    func addNoteBar() {
        stackView.addArrangedSubview(notebar)
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
        // didInstrumentChange
        
        // didFrequencyChange

        //didTuningChange()
        panel?.stringbar?.strings = tuner.tuning.strings
        //self.panel?.notebar?.notes = self.tuner.notes
        // didPitchChange()
        // didFretChange()
        // didFilterChange
        
        switch tuner.settings.filter {
        case .on: processing.enableFilter()
        case .off: processing.disableFilter()
        }
    }
    
    func didFrequencyChange() {
        //panel?.targetFrequency?.text = String(format: "%.2f %@", tuner.targetFrequency(), "Hz".localized())
    }
    
    func didStatusChange() {
        if tuner.status == "active" {
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
        
        panel?.actualFrequency?.text = String(format: "%.2f %@", tuner.frequency, "Hz".localized())
        panel?.frequencyDeviation!.text = String(format: "%.0fc", tuner.frequencyDeviation())
        //self.panel?.notebar?.pointerPosition = self.tuner.stringPosition()
        notebar.pointerPosition = tuner.frequencyDeviation()
        
        print("f dev:", tuner.frequencyDeviation())
        
        tuningView.notePosition = CGFloat(tuner.stringPosition())
        
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
            tuner.settings.fret = fret
        }
    }
}

extension TunerViewController: FiltersAlertControllerDelegate {
    func didChange(filter: Filter) {
        try! realm.write {
            tuner.settings.filter = filter
        }
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
