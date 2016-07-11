//
//  SettingViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 26.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tuner = Tuner.sharedInstance
    let sections: [String] = ["pitch", "tuning"]
    
    var tableView: SettingsView?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = SettingsView(frame: self.view.frame)

        self.navigationItem.title = "settings"

        tableView?.delegate = self;
        tableView?.dataSource = self;

        tuner.on("instrumentChange", {()in
            self.tableView!.reloadData()
        })
        
        self.view.addSubview(tableView!)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return tuner.pitchs.count
        }
        if(section == 1){
            return tuner.tunings.count
        }

        return 0
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: .Value1, reuseIdentifier: nil)

        cell.accessoryType = .None

        if(indexPath.section == 0){
            if(indexPath.row == tuner.pitchIndex){
                cell.accessoryType = .Checkmark
            }

            cell.textLabel!.text = tuner.pitchs[indexPath.row]
        }
        if(indexPath.section == 1){
            if(indexPath.row == tuner.tuningIndex){
                cell.accessoryType = .Checkmark
            }

            cell.textLabel!.text = tuner.tunings[indexPath.row]
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            tuner.setPitchIndex(indexPath.row)
        }

        if(indexPath.section == 1){
            tuner.setTuningIndex(indexPath.row)
        }

        tableView.reloadData()
    }
}
