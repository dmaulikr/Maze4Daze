//
//  PauseScene.swift
//  Maze
//
//  Created by Evan Bernstein on 11/15/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import SpriteKit

class PauseScene: SKScene {
    override func didMove(to view: SKView) {
        addResumeButton()
        
        backgroundColor = SKColor.white
    }
    
    func addResumeButton() {
        let button = SKLabelNode(text: "Resume")
        button.name = "ResumeButton"
        button.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(button)
    }
    
    func resume() {
        view?.presentScene(nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            if let node = nodes(at: location).first, node.name == "ResumeButton" {
                resume()
            }
        }
    }
}
