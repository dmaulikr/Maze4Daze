//
//  MazeFetcher.swift
//  Maze
//
//  Created by Evan Bernstein on 11/15/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import Foundation

func readMaze(fromFilename filename: String, type: String) -> Maze? {
    if let path = Bundle.main.path(forResource: filename, ofType: type) {
        do {
            let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            return Maze.deserialize(mazeFile: text)
        } catch _ {
            return nil
        }
    }
    
    return nil
}
