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
    var currentTime:Float = 0.0
    var fps:Float = 0.0
    var paused:Bool = true
    
    var vid_height = 0.0
    var vid_width = 0.0
    
    var vid_container_height = 350.0
    var vid_container_width = 350.0
    
    var img_to_frame_rat_h = 0.0
    var img_to_frame_rat_w = 0.0
    
    var point_offset_w = 0.0
    var original_frame_wodth = 690.0
    
    var img_id = 0
    var json_polygon_data = JsonData(frame_data: [FrameData(frame: "", classes: [Classes(class_id: 0, class_name: "", color: [0], contours: [[[0]]])])])
    
    var player: AVPlayer!
    let synthesizer = AVSpeechSynthesizer()
    
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vid_container_width = (vid_width/vid_height)*vid_container_height
        
        img_to_frame_rat_h = vid_height/vid_container_height
        img_to_frame_rat_w = vid_width/vid_container_width
        
        point_offset_w = (original_frame_wodth - vid_container_width) / 2.0
        
        if let localData = self.readLocalFile(forName: json_file) {
            self.json_polygon_data = self.parse(jsonData: localData)
        }
        
        let video_path = Bundle.main.url(forResource: video_file, withExtension: "mp4")
        
        player = AVPlayer(url: video_path!)
        currentTime = Float((player.currentItem?.currentTime().seconds)!)
        let asset = player.currentItem?.asset
        let tracks = asset?.tracks(withMediaType: .video)
        fps = (tracks?.first!.nominalFrameRate)!
    
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.image_button_view.bounds
        self.image_button_view.layer.addSublayer(playerLayer)
    }
    

    @IBAction func play(_ sender: Any) {
        self.paused = false
        player?.play()
        self.remove_views()
    }

    @IBAction func stop(_ sender: Any) {
        self.paused = true
        player?.pause()
        usleep(100000)
        self.currentTime = Float((self.player.currentItem?.currentTime().seconds)!)
        self.img_id = Int(self.currentTime*self.fps)
        print(self.img_id)
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
                        let p = CGPoint(x: (Double(pnt[0])/img_to_frame_rat_w + 1 + point_offset_w), y: (Double(pnt[1])/img_to_frame_rat_h + 1))
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
            usleep(100000)
            self.currentTime = Float((self.player.currentItem?.currentTime().seconds)!)
            self.img_id = Int(self.currentTime*self.fps)
            print(self.img_id)
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
