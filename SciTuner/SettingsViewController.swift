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
    
    var instruments: [String:[String:String]] = [String:[String:String]]()
    
    // bingins
    var instrumentTitle: String = ""
    var tuningTitles: [String] = []
    var tuningStrings: [[String]]
    
    var instrument: String{
        set{
            instrumentTitle = newValue
            tuningTitles = []
            tuningStrings = []
            for (title, strings) in instruments[instrumentTitle]! {
                var splitStrings = split(strings) {$0 == " "}
                var titleStrings = join(" ", splitStrings.map({(note: String) -> String in
                    return note.repl
                })
                tuningTitles.append(title + " (" + titleNotes + ")"))
                //tuningStrings.append(strings.spl)
            }
        }
        get{
            return instrumentTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = SettingsView(frame: self.view.frame)
        
        self.navigationItem.title = "settings"
        
        tableView?.delegate = self;
        tableView?.dataSource = self;
        
        self.view.addSubview(tableView!)
        
        
        addInstrument("guitar", [
            "Standard": "e2 a2 d3 g3 b3 e4",
            "New Standard": "c2 g2 d3 a3 e4 g4",
            "Russian": "d2 g2 b2 d3 g3 b3 d4",
            "Drop D": "d2 a2 d3 g3 b3 e4",
            "Drop C": "c2 g2 c3 f3 a3 d4",
            "Drop G": "g2 d2 g3 c4 e4 a4",
            "Open D": "d2 a2 d3 f#3 a3 d4",
            "Open C": "c2 g2 c3 g3 c4 e4",
            "Open G": "g2 g3 d3 g3 b3 d4",
            "Lute": "e2 a2 d3 f#3 b3 e4",
            "Irish": "d2 a2 d3 g3 a3 d4",
        ])
        
        addInstrument("cello", [
            "Standard": "c2 g2 d3 a3",
            "Alternative": "c2 g2 d3 g3"
        ])
        
        addInstrument("violin", [
            "Standard": "g3 d4 a4 e5",
            "Tenor": "g2 d3 a3 e4",
            "Tenor alter.": "f2 c3 g3 d4"
        ])
        
        addInstrument("banjo", [
            "Standard": "g4 d3 g3 b3 d4",
        ])
        
        addInstrument("ukulule", [
            "Standard": "g4 c4 e4 a4",
            "D-tuning": "a4 d4 f#4 b4",
        ])
    }
    
    
    func addInstrument(name: String, _ tunings: [String: String]){
        instruments[name] = tunings
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return pitchs.count
        }
        if(section == 1){
            return instrumentTunings.count
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