# Maze4Daze
The companion app for [aMAZEing](https://github.com/benmckibbenUC/aMAZEing), a DigiFab presents Final Project production, feat. 3D printer.

## Requirements

Xcode 8 or later.

## Installation

Install [cocoapods](https://cocoapods.org). In the root directory of the project, run `pod install`. This will install the dependencies for the application. Then build and run in a simulator or on an iOS device.

## Usage

When the app opens, the first thing it will do is download a new 20x20 maze. If the maze generation server is down, you can load one of three sample mazes included in the app. To do this, triple tap to go to the pause menu, select one of the mazes from the picker wheel, and then tap done to return to the maze.

Tilt the device to move the marble. Double tap to reset the marble to its original position.

To generate a new maze, triple tap to go to the pause screen. Use the sliders to control the new maze's size. Tap `Generate New Maze` to download a new maze. The spinner will indicate when the download has completed. Tap done to return to the maze.

To print the current maze, tap the `Print` button on the pause menu. If this button is greyed-out, it means the app is currently downloading the maze's STL file from the server. Once the button is active, pressing it will attempt to send the file to OctoPrint to be sliced and printed.

## Bugs

- Failure is graceful but not verbose. Most actions will fail silently. Error alerts will be added time permitting.
- The OctoPrint IP address is hard-coded. I'm investigating using octopi.local for bonjour-compatible networks.
- The OctoPrint API key is hard-coded. Although I wrote code for the OctoPrint handshake to obtain a session key, I have been unable to get it to work so far. (It seems to be an internal OctoPrint server error.)
  * The handshake code expects a file called maze_rsa.privKey. I have omitted it from the repository.

## Code Structure

A singleton `MazeHandler` is responsible for requesting new mazes and STL files from the server. A singleton `PrintManager` is responsible for communicating with the OctoPrint API, including authentication (handshake when working), upload, slicing, and printing. It is also responsible for storing the STL file for the current maze on disk.

`GameViewController` is the entry point of the app. It adds an `SKView` to the view hierarchy, which in turn presents an `SKScene`. `GameScene` handles displaying the maze, controlling the marble, and simulating physics.

`PauseViewController` handles the UI for generating or selecting new mazes and printing the current maze.
