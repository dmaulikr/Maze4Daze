//
//  PauseViewController.swift
//  Maze
//
//  Created by Evan Bernstein on 11/15/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var widthSlider: UISlider?
    @IBOutlet var heightSlider: UISlider?
    
    @IBOutlet var widthLabel: UILabel?
    @IBOutlet var heightLabel: UILabel?
    
    @IBOutlet var activityIndiactor: UIActivityIndicatorView?
    
    @IBOutlet var mazePicker: UIPickerView?
    var sampleMazes = ["small", "first", "second"]
    
    var mazeWidth = 20
    var mazeHeight = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.white
        
        addResumeGesture()
        
        if let currentMaze = MazeHandler.sharedInstance.currentMaze {
            mazeWidth = currentMaze.width
            mazeHeight = currentMaze.height
        }
        
        updateLabels()
        updateSliders()
        updatePicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addResumeGesture() {
        let resumeGesture = UITapGestureRecognizer(target: self, action: #selector(PauseViewController.resume))
        
        resumeGesture.numberOfTapsRequired = 3
        
        view.addGestureRecognizer(resumeGesture)
    }
    
    @IBAction func resume() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getNewMaze() {
        activityIndiactor?.startAnimating()
        MazeHandler.sharedInstance.generateMaze(width: mazeWidth, height: mazeHeight, completion: {
            _ in
            DispatchQueue.main.async {
                self.activityIndiactor?.stopAnimating()
                self.updatePicker()
            }
        })
    }
    
    @IBAction func sliderChanged(slider: UISlider) {
        if slider == widthSlider {
            mazeWidth = Int(slider.value)
        }
        if slider == heightSlider {
            mazeHeight = Int(slider.value)
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        widthLabel?.text = String(format: "%d", mazeWidth)
        heightLabel?.text = String(format: "%d", mazeHeight)
    }
    
    func updateSliders() {
        widthSlider?.value = Float(mazeWidth)
        heightSlider?.value = Float(mazeHeight)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updatePicker() {
        if let currentMaze = MazeHandler.sharedInstance.currentMaze, let name = currentMaze.name {
            if let idx = sampleMazes.index(of: name) {
                mazePicker?.selectRow(idx, inComponent: 0, animated: true)
            }
        } else {
            mazePicker?.selectRow(sampleMazes.count, inComponent: 0, animated: true)
        }
    }
    
    // MARK: - PickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sampleMazes.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row < sampleMazes.count ? sampleMazes[row] : "Custom"
    }
    
    // MARK: - PickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let _ = MazeHandler.sharedInstance.readMaze(fromFilename: sampleMazes[row], type: "maze")
        
        if let currentMaze = MazeHandler.sharedInstance.currentMaze {
            mazeWidth = currentMaze.width
            mazeHeight = currentMaze.height
        }
        
        updateLabels()
        updateSliders()
    }

}