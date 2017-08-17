//
//  SettingViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 26.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let realm = try! Realm()
    
    let tuner = Tuner.sharedInstance
    
    var tableView: SettingsView?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = SettingsView(frame: self.view.frame)

        self.navigationItem.title = "settings".localized()

        tableView?.delegate = self;
        tableView?.dataSource = self;
        
        self.view.addSubview(tableView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return Pitch.allPitches.count
        }
        if(section == 1){
            return tuner.instrument.tunings().count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Pitches".localized() }
        if section == 1 { return "Tunings".localized() }
        
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        cell.accessoryType = .none

        if(indexPath.section == 0){
            if(indexPath.row == tuner.pitch.index() ?? 0){
                cell.accessoryType = .checkmark
            }

            cell.textLabel?.text = Pitch.allPitches[indexPath.row].localized()
        }
        
        if(indexPath.section == 1){
            if(indexPath.row == tuner.tuning.index(instrument: tuner.instrument)) {
                cell.accessoryType = .checkmark
            }

            cell.textLabel?.text = tuner.instrument.tunings()[indexPath.row].localized()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            try! realm.write {
                tuner.settings.pitch = Pitch.allPitches[indexPath.row]
            }
            
        }

        if(indexPath.section == 1){
            try! realm.write {
                let tunings = tuner.instrument.tunings()
                tuner.settings.tuning = tunings[indexPath.row]
                print(tunings[indexPath.row])
                print(tuner.settings.tuning, indexPath.row)
            }
        }

        tableView.reloadData()
    }
}
