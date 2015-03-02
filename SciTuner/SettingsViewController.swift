//
//  SettingViewController.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 26.02.15.
//  Copyright (c) 2015 Denis Kreshikhin. All rights reserved.
//

import Foundation
import UIKit
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var onPitchChange = {(pitch: String)->Void in}
    var onTuningChange = {(strings: [String])->Void in}
    
    var tableView: SettingsView?
    let sections: [String] = ["pitch", "tuning"]
    
    let pitchs: [String] = ["Default A4=440Hz", "Scientific C4=256Hz"]
    let pitchValues: [String] = ["default", "scientific"]
    var pitchIndex: Int = 0
    
    var tuningIndex: Int = 0
    let tuningValues: [[String]] = [
        ["e2", "a2", "d3", "g3", "b3", "e4"],
        ["d2", "a2", "d3", "d#3", "a3", "d4"]
    ]
    let tunings: [String] = [
        "Standard E2 A2 D3 G3 B3 E4",
        "Open D2 A2 D3 F3♯ A3 D4"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = SettingsView(frame: self.view.frame)
        
        self.navigationItem.title = "settings"
        
        tableView?.delegate = self;
        tableView?.dataSource = self;
        
        self.view.addSubview(tableView!)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return pitchs.count
        }
        if(section == 1){
            return tunings.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        
        cell.accessoryType = .None
        
        if(indexPath.section == 0){
            if(indexPath.row == pitchIndex){
                cell.accessoryType = .Checkmark
            }
            
            cell.textLabel!.text = pitchs[indexPath.row]
        }
        if(indexPath.section == 1){
            if(indexPath.row == tuningIndex){
                cell.accessoryType = .Checkmark
            }
            
            cell.textLabel!.text = tunings[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if(indexPath.section == 0){
            pitchIndex = indexPath.row
            onPitchChange(pitchValues[pitchIndex])
        }
        if(indexPath.section == 1){
            tuningIndex = indexPath.row
            onTuningChange(tuningValues[tuningIndex])
        }
        
        println("You selected cell #\(indexPath.row)!")
        
        tableView.reloadData()
    }
}