//
//  PanelView.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 13.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit

class PanelView: UIView {
    var notebar: NotebarView?
    var stringbar: StringbarView?
    var controlbar: ControlbarView?
    var modebar: ModebarView?
    
    
    var thick: UILabel?
    var thin: UILabel?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let half = frame.size.width / 2
        let third = frame.size.width / 3;
        
        thick = UILabel(frame: CGRectMake(10, 5, half - 10, 20))
        thick!.text = "thick"
        thick!.textAlignment = .Left
        self.addSubview(thick!)
        
        thin = UILabel(frame: CGRectMake(10+half, 5, half - 20, 20))
        thin!.text = "thin"
        thin!.textAlignment = .Right
        self.addSubview(thin!)
        
        notebar = NotebarView(frame: CGRectMake(0, 25, half*2, 40))
        stringbar = StringbarView(frame: CGRectMake(0, 65, half*2, 40))
        controlbar = ControlbarView(frame: CGRectMake(0, 105, half*2, 40))
        modebar = ModebarView(frame: CGRectMake(0, 150, half*2, 40))
        
        self.addSubview(notebar!)
        self.addSubview(stringbar!)
        self.addSubview(controlbar!)
        self.addSubview(modebar!)
    }
    
    func setNotes(notes: [String]) {
        notebar!.notes = notes;
    }
    
    func setNotePosition(position: Double) {
        notebar!.pointerPosition = position;
    }
    
    func setStrings(strings: [String]) {
        stringbar!.strings = strings;
    }
    
    func setStringPosition(position: Double) {
        stringbar!.pointerPosition = position;
    }
}