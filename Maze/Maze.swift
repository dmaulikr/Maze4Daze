//
//  Maze.swift
//  Maze
//
//  Created by Evan Bernstein on 11/15/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import Foundation

extension Bool {
    init<T : Integer>(_ integer: T){
        self.init(integer != 0)
    }
}

struct Tile {
    let position: (Int, Int)
    
    let topWall: Bool
    let leftWall: Bool
    let bottomWall: Bool
    let rightWall: Bool
    
    init(position: (Int, Int), topWall: Bool, leftWall: Bool, bottomWall: Bool, rightWall: Bool) {
        self.position = position
        
        self.topWall = topWall
        self.leftWall = leftWall
        self.bottomWall = bottomWall
        self.rightWall = rightWall
    }
    
    init(position: (Int, Int), walls: Int) {
        assert(walls >= 0 && walls < 16, "Walls Int must be in [0,16)")
        
        self.init(position: position, topWall: Bool(walls & 8), leftWall: Bool(walls & 2), bottomWall: Bool(walls & 4), rightWall: Bool(walls & 1))
    }
}

struct Maze {
    let width: Int
    let height: Int
    
    let tiles: [Tile]
    
    init(width: Int, height: Int, tiles: [Tile]) {
        self.width = width
        self.height = height
        
        self.tiles = tiles
    }
    
    static var empty: Maze {
        return Maze(width: 0, height: 0, tiles: [])
    }
    
    static func deserialize(mazeFile: String) -> Maze {
        var lines = mazeFile.components(separatedBy: "\n")
        if let lastLine = lines.last, lastLine == "" {
            lines.removeLast()
        }
        assert(lines.count > 1, "Not enough lines!")
        
        let header = lines[0]
        lines.remove(at: 0)
        let headerComponents = header.components(separatedBy: " ")
        assert(headerComponents.count == 2, "Bad header!")
        
        guard let width = Int(headerComponents[0]) else { assertionFailure("Could not parse width"); return Maze.empty }
        guard let height = Int(headerComponents[1]) else { assertionFailure("Could not parse height"); return Maze.empty }
        
        assert(lines.count == height, "Bad height!")
        
        var tiles = [Tile]()
        
        for (y, line) in lines.enumerated() {
            assert(line.characters.count == width, String(format: "Bad width on line %d!", y))
            
            for (x, char) in line.characters.enumerated() {
                let walls = strtoul(String(char), nil, 16)
                
                tiles.append(Tile(position: (x,y), walls: Int(walls)))
            }
        }
        
        return Maze(width: width, height: height, tiles: tiles)
    }
}
