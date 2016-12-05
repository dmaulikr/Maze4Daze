# Maze4Daze
The companion app for [aMAZEing](https://github.com/benmckibbenUC/aMAZEing), a DigiFab presents Final Project production, feat. 3D printer.

## Requirements

Xcode 8 or later.

## Installation

Install [cocoapods](https://cocoapods.org). In the root directory of the project, run `pod install`. This will install the dependencies for the application. Then build and run in a simulator or on an iOS device.

## Usage

When the app opens, the first thing it will do is display a saved 10x10 maze ("medium"). Tilt the device to move the marble. Double tap to reset the marble to its original position.

Triple tap to go to the pause menu. From there, you can choose one of three saved mazes (`small`, `medium`, and `large`) or generate a new maze by moving the sliders to the desired height and width and tapping `Generate New Maze`. The spinner will indicate when the download has completed. Tap done to return to the maze.

To print the current maze, tap the `Print` button on the pause menu. If this button is greyed-out, it means the app is currently downloading the maze's STL file from the server. Once the button is active, pressing it will attempt to send the file to OctoPrint to be sliced and printed.

## Bugs

- The OctoPrint API key is hard-coded. Although I wrote code for the OctoPrint handshake to obtain a session key, I have been unable to get it to work so far. (It seems to be an internal OctoPrint server error.)
  * The handshake code expects a file called maze_rsa.privKey. I have omitted it from the repository.
- Since error responses from OctoPrint are somtimes strings (instead of JSON), the app may report the wrong error, or no error at all.

## Code Structure

A singleton `MazeHandler` is responsible for requesting new mazes and STL files from the server. A singleton `PrintManager` is responsible for communicating with the OctoPrint API, including authentication (handshake when working), upload, slicing, and printing. It is also responsible for storing the STL file for the current maze on disk.

`GameViewController` is the entry point of the app. It adds an `SKView` to the view hierarchy, which in turn presents an `SKScene`. `GameScene` handles displaying the maze, controlling the marble, and simulating physics.

`PauseViewController` handles the UI for generating or selecting new mazes and printing the current maze.

Errors in the app are reported to `ErrorHandler`, which creates a pop-up alert that contains a string containing the error message.
