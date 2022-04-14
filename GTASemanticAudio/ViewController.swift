//
//  ViewController.swift
//  GTASemanticAudio
//
//  Created by Imran Kabir on 5/4/22.
//

import UIKit

class ViewController: UIViewController {
    
    // var view_switchewr: VideoViewController!
    
    let video_files:[String] = [
        "gameplay_video_1",
        "gameplay_video_2",
        "gameplay_video_3"
    ]
    let json_files:[String] = [
        "polygons_video_1",
        "polygons_video_2",
        "polygons_video_3"
    ]
    
    let vid_heights:[Double] = [1080, 1080, 1080]
    let vid_widths:[Double] = [1920, 1920, 1920]
    
    let vid_net_out_rat_hs:[Double] = [1.875, 1.875, 1.875]
    let vid_net_out_rat_ws:[Double] = [1.875, 1.875, 1.875]
    
    @IBAction func play_vid_1(_ sender: Any) {
        switch_view_func_3(index: 0)
    }
    @IBAction func play_vid_2(_ sender: Any) {
        switch_view_func_3(index: 1)
    }
    @IBAction func play_vid_3(_ sender: Any) {
        switch_view_func_3(index: 2)
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
        // let storyBoard : UIStoryboard = UIStoryboard(name: "VideoScreen", bundle:nil)
        // view_switchewr = storyBoard.instantiateViewController(withIdentifier: "video_view") as? VideoViewController
    }
    
    func switch_view_func(index: Int){
        let storyBoard : UIStoryboard = UIStoryboard(name: "VideoFrameScreen", bundle:nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "video_frame_view") as? VideoFrmaeViewController else {
            print("failed to load vc")
            return
        }
        vc.video_file = video_files[index]
        vc.json_file = json_files[index]
        vc.destroy = false
        vc.vid_frames = []
        vc.img_id = 0
        vc.json_polygon_data = JsonData(frame_data: [FrameData(frame: "", classes: [Classes(class_id: 0, class_name: "", color: [0], contours: [[[0]]])])])
        present(vc, animated: true)
    }
    
    func switch_view_func_2(index: Int){
        let storyBoard : UIStoryboard = UIStoryboard(name: "VideoScreen", bundle:nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "video_view") as? VideoViewController else {
            print("failed to load vc")
            return
        }
        vc.video_file = video_files[index]
        vc.json_file = json_files[index]
        vc.destroy = false
        vc.vid_frames = []
        vc.img_id = 0
        vc.json_polygon_data = JsonData(frame_data: [FrameData(frame: "", classes: [Classes(class_id: 0, class_name: "", color: [0], contours: [[[0]]])])])
        present(vc, animated: true)
    }
    
    func switch_view_func_3(index: Int){
        let storyBoard : UIStoryboard = UIStoryboard(name: "VideoPlayer", bundle:nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "video_player") as? VideoPlayerViewController else {
            print("failed to load vc")
            return
        }
        vc.video_file = video_files[index]
        vc.json_file = json_files[index]
        vc.vid_height = vid_heights[index]
        vc.vid_width = vid_widths[index]
        vc.vid_net_out_rat_h = vid_net_out_rat_hs[index]
        vc.vid_net_out_rat_w = vid_net_out_rat_ws[index]
        present(vc, animated: true)
    }
    

}
