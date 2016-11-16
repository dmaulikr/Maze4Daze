//
//  MazeFetcher.swift
//  Maze
//
//  Created by Evan Bernstein on 11/15/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import Foundation
import Alamofire

protocol MazeObserver {
    func identifier() -> String
    func currentMazeDidChange(newMaze: Maze?)
}

class MazeHandler {
    static let sharedInstance = MazeHandler()
    
    var currentMaze: Maze? = nil
    
    var mazeObservers = [MazeObserver]()
    
    func readMaze(fromFilename filename: String, type: String) -> Maze? {
        if let path = Bundle.main.path(forResource: filename, ofType: type) {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                currentMaze = try Maze.deserialize(mazeFile: text)
                currentMaze?.name = filename
                self.notifyObserversOfNewMaze()
                return currentMaze
            } catch _ {
                return nil
            }
        }
        
        return nil
    }
    
    typealias MazeCompletion = (Maze?) -> ()
    
    func generateMaze(width: Int, height: Int, completion: MazeCompletion?) {
        let serverURL = "http://52.34.211.66:9000/"
        let generateURL = serverURL + "generate/"
        let queryURL = generateURL + String(format: "?d=%d&w=%d", height, width)
        Alamofire.request(queryURL).response { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                do {
                    self.currentMaze = try Maze.deserialize(mazeFile: utf8Text)
                    self.currentMaze?.name = nil
                    completion?(self.currentMaze)
                    self.notifyObserversOfNewMaze()
                } catch let mazeError {
                    print(mazeError)
                    completion?(nil)
                }
            } else {
                completion?(nil)
            }
        }
    }
    
    func addObserver(observer: MazeObserver) {
        if !containsObserver(array: mazeObservers, observer: observer) {
            mazeObservers.append(observer)
        }
    }
    
    func removeObserver(observer: MazeObserver) {
        for (idx, anObserver) in mazeObservers.enumerated() {
            if anObserver.identifier() == observer.identifier() {
                mazeObservers.remove(at: idx)
                return
            }
        }
    }
    
    func containsObserver(array: [MazeObserver], observer: MazeObserver) -> Bool {
        for anObserver in array {
            if observer.identifier() == anObserver.identifier() {
                return true
            }
        }
        return false
    }
    
    func notifyObserversOfNewMaze() {
        for observer in mazeObservers {
            observer.currentMazeDidChange(newMaze: currentMaze)
        }
    }
}



