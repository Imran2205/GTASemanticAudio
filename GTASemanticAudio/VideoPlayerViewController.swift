//
//  VideoPlayerViewController.swift
//  GTASemanticAudio
//
//  Created by Imran Kabir on 11/4/22.
//

import AVFoundation
import AVKit
import AssetsLibrary
import UIKit

class VideoPlayerViewController: UIViewController {
    
    var video_file:String = ""
    var json_file:String = ""
    
    var vid_frames: [UIImage] = []
    var img_id = 0
    var json_polygon_data = JsonData(frame_data: [FrameData(frame: "", classes: [Classes(class_id: 0, class_name: "", color: [0], contours: [[[0]]])])])
    
    var player: AVPlayer!
    
    @IBOutlet weak var image_button_view: UIView!
    
    @IBOutlet weak var class_name_label: UILabel!
    @IBOutlet weak var prev_but: UIButton!
    @IBOutlet weak var next_but: UIButton!
    @IBOutlet weak var back_but: UIButton!
    
    
    @IBAction func back_button(_ sender: Any) {
        self.removeFromParent()
        self.dismiss(animated: true, completion: nil)
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
        
        let video_path = Bundle.main.url(forResource: video_file, withExtension: "mp4")
        
        player = AVPlayer(url: video_path!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.image_button_view.bounds
        self.image_button_view.layer.addSublayer(playerLayer)

        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func play(_ sender: Any) {
        player?.play()
    }

    @IBAction func stop(_ sender: Any) {
        player?.pause()
    }
}
