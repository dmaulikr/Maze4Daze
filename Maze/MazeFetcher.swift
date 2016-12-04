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
    func currentMazeGotSTLFile()
}

extension MazeObserver {
    func currentMazeDidChange(newMaze _: Maze?) { }
    func currentMazeGotSTLFile() { }
}

enum DataError: Error {
    case UTF8Serialization
    case HTTPResponse
}

class MazeHandler {
    static let sharedInstance = MazeHandler()
    
    var currentMaze: Maze? = nil
    
    var mazeObservers = [MazeObserver]()
    
    private static let serverURL = "http://52.34.211.66:9000/"
    
    typealias MazeCompletion = (Maze?, Error?) -> ()
    typealias SuccessCompletion = (Bool, Error?) -> ()
    
    func readMaze(fromFilename filename: String, type: String, completion: MazeCompletion? = nil) {
        if let path = Bundle.main.path(forResource: filename, ofType: type) {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                currentMaze = try Maze.deserialize(mazeFile: text)
                currentMaze?.name = filename
                self.notifyObserversOfNewMaze()
                completion?(currentMaze, nil)
            } catch let error {
                completion?(nil, error)
            }
        } else {
            completion?(nil, FileError.CouldNotLoadMainBundle)
        }
    }
    
    func generateMaze(width: Int, height: Int, completion: MazeCompletion? = nil) {
        let generateURL = MazeHandler.serverURL + "generate/"
        let queryURL = generateURL + String(format: "?d=%d&w=%d", height, width)
        Alamofire.request(queryURL).response { response in
            if let data = response.data, data.count > 0, let utf8Text = String(data: data, encoding: .utf8) {
                do {
                    self.currentMaze = try Maze.deserialize(mazeFile: utf8Text)
                    self.currentMaze?.name = nil
                    completion?(self.currentMaze, nil)
                    if let maze = self.currentMaze {
                        self.fetchSTL(maze: maze) {
                            _, error in
                            if let error = error {
                                ErrorHandler.showErrorOnRootViewController(error: error)
                            }
                        }
                    }
                    self.notifyObserversOfNewMaze()
                } catch let mazeError {
                    completion?(nil, mazeError)
                }
            } else {
                completion?(nil, DataError.UTF8Serialization)
            }
        }
    }
    
    func fetchSTL(maze: Maze, completion: SuccessCompletion? = nil) {
        do {
            try PrintManager.sharedInstance.clearSTLFile()
        } catch let error {
            completion?(false, error)
            return
        }
        let stlURL = MazeHandler.serverURL + "stl"
        let parameters: [String: Any] = ["maze": maze.raw, "marble": maze.marbleSize]
        Alamofire.request(stlURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response { response in
            if let currentMaze = self.currentMaze, currentMaze == maze {
                if let data = response.data, data.count > 0 {
                    do {
                        try PrintManager.sharedInstance.storeSTLFile(stlData: data)
                        self.currentMaze?.stlDownloaded = true
                        self.notifyObserversOfNewSTL()
                        completion?(true, nil)
                    } catch let error {
                        completion?(false, error)
                    }
                } else {
                    completion?(false, DataError.HTTPResponse)
                }
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
    
    func notifyObserversOfNewSTL() {
        for observer in mazeObservers {
            observer.currentMazeGotSTLFile()
        }
    }
}



