//
//  ViewController.swift
//  GTASemanticAudio
//
//  Created by Imran Kabir on 5/4/22.
//

import UIKit

class ViewController: UIViewController {
    
    let video_files:[String] = ["vid_1_blended", "vid_2_blended"]
    let json_files:[String] = ["polygons_vid_1", "polygons_vid_2"]

    @IBAction func switch_view(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "VideoScreen", bundle:nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "video_view") as? VideoViewController else {
            print("failed to load vc")
            return
        }
        vc.video_file = "adsaaaaa"
        present(vc, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    

}
