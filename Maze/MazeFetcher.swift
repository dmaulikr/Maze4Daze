//
//  MazeFetcher.swift
//  Maze
//
//  Created by Evan Bernstein on 11/15/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import Foundation
import Alamofire

func readMaze(fromFilename filename: String, type: String) -> Maze? {
    if let path = Bundle.main.path(forResource: filename, ofType: type) {
        do {
            let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let maze = try Maze.deserialize(mazeFile: text)
            return maze
        } catch _ {
            return nil
        }
    }
    
    return nil
}


func generateMaze(width: Int, height: Int, completion: @escaping ((Maze?) -> Void)) {
    let serverURL = "http://52.34.211.66:9000/"
    let generateURL = serverURL + "generate/"
    let queryURL = generateURL + String(format: "?d=%d&w=%d", height, width)
    Alamofire.request(queryURL).response { response in
        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
            do {
                let maze = try Maze.deserialize(mazeFile: utf8Text)
                completion(maze)
            } catch _ {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
}
