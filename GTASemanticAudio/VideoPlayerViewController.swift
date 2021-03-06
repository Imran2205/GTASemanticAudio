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

class VideoPlayerViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    var video_file:String = ""
    var json_file:String = ""
    var currentTime:Float64 = 0.0
    var fps:Float64 = 0.0
    var paused:Bool = true
    
    var vid_height = 0.0
    var vid_width = 0.0
    
    var vid_net_out_rat_h = 1.0
    var vid_net_out_rat_w = 1.0
    
    var vid_container_height = 350.0
    var vid_container_width = 350.0
    
    var img_to_frame_rat_h = 0.0
    var img_to_frame_rat_w = 0.0
    
    var point_offset_w = 0.0
    var original_frame_wodth = 690.0
    
    var video_frames = 0
    
    var img_id = 0
    var json_polygon_data = JsonData(frame_data: [FrameData(frame: "", classes: [Classes(class_id: 0, class_name: "", color: [0], contours: [[[0]]])])])
    
    var player: AVPlayer!
    let synthesizer = AVSpeechSynthesizer()
    
    var timeObserver: Any?
    
    @IBOutlet weak var image_button_view: UIView!
    
    @IBOutlet weak var class_name_label: UILabel!
    @IBOutlet weak var prev_but: UIButton!
    @IBOutlet weak var next_but: UIButton!
    @IBOutlet weak var back_but: UIButton!
    @IBOutlet weak var vid_progress_slider: UISlider!
    
    
    @IBAction func back_button(_ sender: Any) {
        self.removeFromParent()
        self.dismiss(animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    @IBAction func slider_value_changed(_ sender: Any) {
        // player?.pause()
        let seconds : Int64 = Int64(vid_progress_slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        // if player!.rate == 0
        // {
        //     player?.play()
        // }
        self.remove_views()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vid_container_width = (vid_width/vid_height)*vid_container_height
        
        img_to_frame_rat_h = vid_height/vid_container_height
        img_to_frame_rat_w = vid_width/vid_container_width
        
        /* print(vid_width)
        print(vid_height)
        print(vid_container_width)
        print(vid_container_height)
        print(img_to_frame_rat_w)
        print(img_to_frame_rat_h) */
        
        point_offset_w = (original_frame_wodth - vid_container_width) / 2.0
        
        if let localData = self.readLocalFile(forName: json_file) {
            self.json_polygon_data = self.parse(jsonData: localData)
        }
        
        let video_path = Bundle.main.url(forResource: video_file, withExtension: "mov")
        
        player = AVPlayer(url: video_path!)
        currentTime = Float64((player.currentItem?.currentTime().seconds)!)
        let asset = player.currentItem?.asset
        let tracks = asset?.tracks(withMediaType: .video)
        fps = Float64((tracks?.first!.nominalFrameRate)!)
    
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.image_button_view.bounds
        self.image_button_view.layer.addSublayer(playerLayer)
        
        vid_progress_slider.minimumValue = 0
                
        let duration : CMTime = asset!.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        video_frames = Int(Float64(fps) * seconds) - 1
        
        vid_progress_slider.maximumValue = Float(seconds)
        print(seconds)
        vid_progress_slider.isContinuous = true
        vid_progress_slider.tintColor = UIColor.green
        
        //vid_progress_slider.addTarget(self, action: #selector(self.slider_value_changed(_:)), for: .valueChanged)

        self.view.addSubview(vid_progress_slider)
        
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            self.updateVideoPlayerSlider()
        })
    }
    
    func updateVideoPlayerSlider() {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        // print(currentTimeInSeconds)
        vid_progress_slider.value = Float(currentTimeInSeconds)
        /*if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            vid_progress_slider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
        }*/
    }


    @IBAction func play(_ sender: Any) {
        self.paused = false
        player?.play()
        self.remove_views()
    }

    @IBAction func stop(_ sender: Any) {
        self.paused = true
        player?.pause()
        // usleep(1000000)
        self.currentTime = Float64((self.player.currentItem?.currentTime().seconds)!)
        self.img_id = Int(self.currentTime*self.fps)
        if(self.img_id > self.video_frames){
            self.img_id = self.video_frames
        }
        if(self.img_id < 0){
            self.img_id = 0
        }
        print(self.currentTime)
        self.show_image()
    }
    
    func show_image(){
        DispatchQueue.main.async { [self] in
            for view in image_button_view.subviews {
                //if let item = view as? UIButton
                //{
                    view.removeFromSuperview()
                //}
            }

            for cls in self.json_polygon_data.frame_data[self.img_id].classes {
                let class_id: Int = cls.class_id
                let color: [Int] = cls.color
                for contour in cls.contours {
                    var button_points: [CGPoint] = []
                    for pnt in contour {
                        let p = CGPoint(x: (Double(pnt[0]) * vid_net_out_rat_w / img_to_frame_rat_w + 1 + point_offset_w), y: (Double(pnt[1]) * vid_net_out_rat_h / img_to_frame_rat_h + 1))
                        button_points.append(p)
                    }
                    let polygon = PolyButton(points: button_points,
                                             color: UIColor(red: CGFloat(color[0])/255.0,
                                                            green: CGFloat(color[1])/255.0,
                                                            blue: CGFloat(color[2])/255.0, alpha: 0.5),
                                             frame: self.view.bounds)
                    polygon.tag = class_id
                    polygon.addTarget(self, action: #selector(didPressPolygon(_:)), for: UIControl.Event.touchUpInside)
                    image_button_view.addSubview(polygon)
                    image_button_view.bringSubviewToFront(polygon)
                }
            }
            
            
        }
    }
    
    func remove_views(){
        for view in image_button_view.subviews {
            //if let item = view as? UIButton
            //{
                view.removeFromSuperview()
            //}
        }
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func parse(jsonData: Data) -> JsonData {
        var decodedData = JsonData(frame_data: [FrameData(frame: "", classes: [Classes(class_id: 0, class_name: "", color: [0], contours: [[[0]]])])])
        do {
            decodedData = try JSONDecoder().decode(JsonData.self,
                                                       from: jsonData)
            
            //print("points: ", decodedData.frame_data[0].classes[14].contours)
            //print("===================================")
            return decodedData
        } catch {
            print(error)
        }
        return decodedData
    }
    
    @objc func didPressPolygon(_ sender: UIButton) {
        let classes = [
            0:  "unlabeled", 1:  "road",   2:  "sidewalk",      3: "building",     4:  "wall",
            5:  "fence",     6:  "pole",   7:  "traffic light", 8: "traffic sign", 9:  "vegetation",
            10: "terrain",   11: "sky",    12: "person",        13: "rider",       14: "car",
            15: "truck",     16: "bus",    17: "train",         18: "motorcycle",  19: "bicycle",
            20: "dynamic",   21: "ground", 22: "parking",       23: "rail track",  24: "guard rail",
            25: "bridge",    26: "tunnel", 27: "pole group",    28: "caravan",     29: "trailer"
        ]
        print("You clicked on : \(classes[sender.tag]!)")
        self.view.bringSubviewToFront(self.class_name_label)
        self.class_name_label.text = "\(classes[sender.tag]!)"
        let text = "\(classes[sender.tag]!)"
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    @objc func doubleTapped() {
        self.paused = !self.paused
        if(self.paused){
            player?.pause()
            // usleep(1000000)
            self.currentTime = Float64((self.player.currentItem?.currentTime().seconds)!)
            self.img_id = Int(self.currentTime*self.fps)
            if(self.img_id > self.video_frames){
                self.img_id = self.video_frames
            }
            if(self.img_id < 0){
                self.img_id = 0
            }
            print(self.currentTime)
            self.show_image()
        }
        else{
            player?.play()
            self.remove_views()
        }
    }
    
    @objc func action_func(_ sender: UIButton) {
        print("action_func")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
