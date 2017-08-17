//
//  TubeScene.swift
//  SciTuner
//
//  Created by Denis Kreshikhin on 7/18/17.
//  Copyright © 2017 Denis Kreshikhin. All rights reserved.
//

import UIKit
import SpriteKit

protocol TubeSceneDelegate: class {
    func getNotePosition() -> CGFloat
}

class TubeScene: SKScene {
    weak var customDelegate: TubeSceneDelegate?
    
    var waveNode = SKShapeNode()
    var lastPoints = [CGPoint]()
    
    class Ring{
        let node: SKShapeNode
        let point: SKShapeNode
        
        init(circleOfRadius: CGFloat) {
            node = SKShapeNode(circleOfRadius: circleOfRadius)
            node.fillColor = .clear
            node.strokeColor = .white
            node.lineWidth = 3
            node.glowWidth = 1
            point = SKShapeNode(circleOfRadius: 1)
            point.position.y += circleOfRadius
            point.strokeColor = .white
            point.lineWidth = 5
            point.glowWidth = 1
            node.addChild(point)
        }
    }
    
    var ring: Ring?
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0.35, alpha: 1)
        waveNode.fillColor = .clear
        waveNode.strokeColor = .white
        waveNode.lineWidth = 3
        waveNode.glowWidth = 1
        waveNode.position.y += size.height / 4
        self.addChild(waveNode)
        
        ring = Ring(circleOfRadius: self.size.width / 7)
        ring?.node.position.x = size.width / 2
        ring?.node.position.y = size.width / 4
        
        addChild(ring!.node)
    }
    
    func draw(wave: [Double]) {
        let count: CGFloat = CGFloat(wave.count)
        let n = 5
        
        var points = [CGPoint](repeating: CGPoint(), count: wave.count / n)
        
        for i in 0..<points.count {
            let u = wave[i * n]
            points[i] =  CGPoint(x: 1.06 * size.width * (CGFloat(i * n) + 0.3) / count, y: (CGFloat(u) + 1) * size.height / 2)
        }
        
        for i in 0..<points.count {
            if i >= lastPoints.count {
                break
            }
            
            points[i].y = (lastPoints[i].y + points[i].y) / 2
        }
        
        lastPoints = points
        
        waveNode.path = SKShapeNode(splinePoints: &points, count: points.count).path
        
        if let notePosition = customDelegate?.getNotePosition() {
            let angle = notePosition.truncatingRemainder(dividingBy: 1.0) * CGFloat.pi * 2.0
            ring?.node.zRotation = angle
        }
    }
}
