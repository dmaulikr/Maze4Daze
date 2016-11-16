//
//  PauseViewController.swift
//  Maze
//
//  Created by Evan Bernstein on 11/15/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.white
        
        addResumeGesture()
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
    
    func resume() {
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
