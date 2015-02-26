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
    var tableView: SettingsView?
    let sections: [String] = ["pitch", "tuning"]
    let pitchs: [String] = ["Default A4=440Hz", "Scientific C4=256Hz"]
    let tunings: [String] = [
        "Standard E2 A2 D3 G3 B3 E4",
        "Open D2 A2 D3 F3♯ A3 D4",
        "Open D2 A2 D3 F3♯ A3 D4",
        "Open D2 A2 D3 F3♯ A3 D4",
        "Open D2 A2 D3 F3♯ A3 D4",
        "Open D2 A2 D3 F3♯ A3 D4",
        "Open D2 A2 D3 F3♯ A3 D4",
        "Open D2 A2 D3 F3♯ A3 D4",
        "Open D2 A2 D3 F3♯ A3 D4",
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
        
        if(indexPath.row == 0){
            cell.accessoryType = .Checkmark
        }
        
        if(indexPath.section == 0){
            cell.textLabel!.text = pitchs[indexPath.row]
        }
        if(indexPath.section == 1){
            cell.textLabel!.text = tunings[indexPath.row]
        }
        
        println("wtf? 2?")
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }
}