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

enum MazeError : Error {
    case NotEnoughLines
    case BadHeader
    case ParseWidth
    case ParseHeight
    case BadHeight
    case BadWidth(line: Int)
}

enum Corner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

struct Tile {
    let position: (Int, Int)
    
    let topWall: Bool
    let leftWall: Bool
    let bottomWall: Bool
    let rightWall: Bool
    
    let corners: [Corner]
    
    init(position: (Int, Int), topWall: Bool, leftWall: Bool, bottomWall: Bool, rightWall: Bool) {
        self.position = position
        
        self.topWall = topWall
        self.leftWall = leftWall
        self.bottomWall = bottomWall
        self.rightWall = rightWall
        
        var theCorners = [Corner]()
        if topWall && leftWall {
            theCorners.append(.topLeft)
        }
        if topWall && rightWall {
            theCorners.append(.topRight)
        }
        if bottomWall && leftWall {
            theCorners.append(.bottomLeft)
        }
        if bottomWall && rightWall {
            theCorners.append(.bottomRight)
        }
        self.corners = theCorners
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
    
    let raw: String
    
    var name: String?
    
    let uuid: String
    var stlDownloaded: Bool = false
    
    init(width: Int, height: Int, tiles: [Tile], raw: String) {
        self.width = width
        self.height = height
        
        self.tiles = tiles
        
        self.raw = raw
        
        self.uuid = UUID().uuidString        
    }
    
    static var empty: Maze {
        return Maze(width: 0, height: 0, tiles: [], raw: "")
    }
    
    static func deserialize(mazeFile: String) throws -> Maze {
        var lines = mazeFile.components(separatedBy: "\n")
        if let lastLine = lines.last, lastLine == "" {
            lines.removeLast()
        }
        guard lines.count > 1 else { throw MazeError.NotEnoughLines }
        
        let header = lines[0]
        lines.remove(at: 0)
        let headerComponents = header.components(separatedBy: " ")
        guard headerComponents.count == 2 else { throw MazeError.BadHeader }
        
        guard let height = Int(headerComponents[0]) else { throw MazeError.ParseHeight }
        guard let width = Int(headerComponents[1]) else { throw MazeError.ParseWidth }
        
        guard lines.count == height else { throw MazeError.BadHeight }
        
        var tiles = [Tile]()
        
        for (y, line) in lines.enumerated() {
            guard line.characters.count == width else { throw MazeError.BadWidth(line: y) }
            
            for (x, char) in line.characters.enumerated() {
                let walls = strtoul(String(char), nil, 16)
                
                tiles.append(Tile(position: (x,y), walls: Int(walls)))
            }
        }
        
        return Maze(width: width, height: height, tiles: tiles, raw: mazeFile)
    }
}

func ==(lhs: Maze, rhs: Maze) -> Bool {
    return lhs.uuid == rhs.uuid
}
