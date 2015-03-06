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
        ["e2", "a2", "d3", "g3", "b3", "e4"], // standard
        ["c2", "g2", "d3", "a3", "e4", "g4"], // new standard
        ["d2", "g2", "b2", "d3", "g3", "b3", "d4"], // russian
        
        ["d2", "a2", "d3", "g3", "b3", "e4"], // drop D
        ["c2", "g2", "c3", "f3", "a3", "d4"], // drop C
        ["g2", "d2", "g3", "c4", "e4", "a4"], // drop G
        
        ["d2", "a2", "d3", "f#3", "a3", "d4"], // open D
        ["c2", "g2", "c3", "g3", "c4", "e4"], // open C
        ["g2", "g3", "d3", "g3", "b3", "d4"], // open G
    ]
    
    let tunings: [String] = [
        "Standard (E A D G B E)",
        "New Standard (C G D A E G)",
        "Russian (D G B D G B D)",
        
        "Drop D (D A D G B E)",
        "Drop C (C G C F A D)",
        "Drop G (G D G C E A)",
        
        "Open D (D A D F♯ A D)",
        "Open C (C G C G C E)",
        "Open G (G G D G B D)",
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