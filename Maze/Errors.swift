//
//  Errors.swift
//  Maze
//
//  Created by Evan Bernstein on 12/3/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import Foundation
import UIKit

class ErrorHandler {
    static func showError(error: Error, onViewController viewController: UIViewController) {
        var errorString = "Whoops!"
        switch error {
        case KeyError.NoKeyFile:
            errorString = "Missing RSA Private Key File"
        case FileError.CouldNotLocateDocumentsDirectory:
            errorString = "Could not locate app's documents directory"
        case FileError.NoSTLFileSaved:
            errorString = "STL file not found"
        case FileError.CouldNotLoadMainBundle:
            errorString = "Could not load app's main bundle"
        case SessionError.UnverifiedSessionKey:
            errorString = "Session key has not been verified"
        case SessionError.SessionKeyNoLongerValid:
            errorString = "The session key is no longer valid"
        case MazeError.NotEnoughLines:
            errorString = "Not enough lines in maze file"
        case MazeError.BadHeader:
            errorString = "Bad header in maze file"
        case MazeError.ParseWidth:
            errorString = "Could not parse width in maze file"
        case MazeError.ParseHeight:
            errorString = "Could not parse height in maze file"
        case MazeError.BadHeight:
            errorString = "Height in header does not match height of maze file"
        case MazeError.BadWidth(let line):
            errorString = "Width in header does not match width of line " + String(line)
        case DataError.UTF8Serialization:
            errorString = "Could not serialize maze data as UTF-8"
        case DataError.HTTPResponse:
            errorString = "Could not read HTTP response data"
        case DataError.BadSTLParam:
            errorString = "There was a problem generating the STL file for these parameters"
        default:
            errorString = error.localizedDescription
        }
        
        let alert = UIAlertController(title: "An Error Occured", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // Avoid this function is possible
    static func showErrorOnRootViewController(error: Error) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController {
            showError(error: error, onViewController: rootViewController)
        }
    }
}
