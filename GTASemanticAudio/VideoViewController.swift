//
//  VideoViewController.swift
//  GTASemanticAudio
//
//  Created by Imran Kabir on 10/4/22.
//

import AVFoundation
import AssetsLibrary
import UIKit

class VideoViewController: UIViewController, AVSpeechSynthesizerDelegate  {

    //@IBOutlet weak var vid_image_view: UIImageView!
    // private var vid_frames: [UIImage] = []
    
    var video_file:String = ""
    var json_file:String = ""
    
    @IBOutlet weak var image_button_view: UIView!

    @IBOutlet weak var current_frame_label: UILabel!
    @IBOutlet weak var total_frame_label: UILabel!
    @IBOutlet weak var class_name_label: UILabel!
    @IBOutlet weak var prev_but: UIButton!
    @IBOutlet weak var next_but: UIButton!
    @IBOutlet weak var back_but: UIButton!
    
    var vid_frames: [UIImage] = []
    var img_id = 0
    var json_polygon_data = JsonData(frame_data: [FrameData(frame: "", classes: [Classes(class_id: 0, class_name: "", color: [0], contours: [[[0]]])])])
    
    let screenSize: CGRect = UIScreen.main.bounds
    var screen_height: Double = 0.0
    var screen_width: Double = 0.0
    
    var multi = 0.0
    var multi_y = 0.0
    var multi_y_but = 0.0
    
    var img_to_frame_rat_h = 0.0
    var img_to_frame_rat_w = 0.0
    
    var image_frame_width = 1024.0
    var image_frame_height = 520.0
    
    let synthesizer = AVSpeechSynthesizer()
    
    var video_frames: Int = 0
    
    var frame_jump = 1
    var vid_time_scale = 1.0
    var img_id_multiplier = 1
    var fps = 1.0
    
    var paused:Bool = true
    
    var destroy:Bool = false
    
    var video_asset: AVAsset!
    var generator: AVAssetImageGenerator!
    
    @IBAction func prev_button(_ sender: Any) {
        paused = false
        get_image()
    }
    
    @IBAction func next_button(_ sender: Any) {
        paused = true
        get_image()
    }
    
    @IBAction func back_button(_ sender: Any) {
        /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "main_view") as? ViewController else {
            print("failed to load vc")
            return
        }
        destroy = true
        present(vc, animated: true)*/
        destroy = true
        self.removeFromParent()
        self.dismiss(animated: true, completion: nil)
    }
    /*override public var shouldAutorotate: Bool {
        return false
    }
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }*/
    
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
        
        if (screenSize.height < screenSize.width){
            screen_height = screenSize.height
            screen_width = screenSize.width
        }
        else {
            screen_height = screenSize.width
            screen_width = screenSize.height
        }
        
        if (screen_width/screen_height > 1.9) {
            multi = 0.8975
            multi_y = 0.0513
            multi_y_but = 0.07109
            next_but.titleLabel?.font = .systemFont(ofSize: 17)
            prev_but.titleLabel?.font = .systemFont(ofSize: 17)
        }
        else {
            multi = 0.735
            multi_y = 0.13
            multi_y_but = 0.08
            next_but.titleLabel?.font = .systemFont(ofSize: 8)
            prev_but.titleLabel?.font = .systemFont(ofSize: 8)
        }
        
        image_button_view.frame.origin.x = 0.0912 * screen_width
        image_button_view.frame.origin.y = multi_y * screen_height
        image_button_view.frame.size.height = screen_height * multi
        image_button_view.frame.size.width = (image_frame_width/image_frame_height) * screen_height * multi
        
        current_frame_label.frame.origin.x = 0.0106 * screen_width
        current_frame_label.frame.origin.y = 0.0513 * screen_height
        current_frame_label.frame.size.height = screen_height * 0.05213
        current_frame_label.frame.size.width = screen_width * 0.07109
        
        total_frame_label.frame.origin.x = 0.91825 * screen_width
        total_frame_label.frame.origin.y = 0.0513 * screen_height
        total_frame_label.frame.size.height = screen_height * 0.05213
        total_frame_label.frame.size.width = screen_width * 0.07109
        
        class_name_label.frame.origin.x = 0.91825 * screen_width
        class_name_label.frame.origin.y = 0.24359 * screen_height
        class_name_label.frame.size.height = screen_height * 0.5128
        class_name_label.frame.size.width = screen_width * 0.05924
        
        next_but.frame.origin.x = 0.91825 * screen_width
        next_but.frame.origin.y = 0.8231 * screen_height
        next_but.frame.size.height = screen_height * 0.07949
        next_but.frame.size.width = screen_width * multi_y_but
        
        prev_but.frame.origin.x = 0.0106 * screen_width
        prev_but.frame.origin.y = 0.8231 * screen_height
        prev_but.frame.size.height = screen_height * 0.07949
        prev_but.frame.size.width = screen_width * multi_y_but
        
        back_but.frame.origin.x = 0.0106 * screen_width
        back_but.frame.origin.y = 0.1718 * screen_height
        back_but.frame.size.height = screen_height * 0.07949
        back_but.frame.size.width = screen_width * multi_y_but
        
        img_to_frame_rat_h = image_frame_height / image_button_view.frame.size.height
        img_to_frame_rat_w = image_frame_width / image_button_view.frame.size.width
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*let video_path = Bundle.main.url(forResource: "vid_1_blended", withExtension: "mp4")
        let video_asset = AVAsset(url: video_path!)
        
        var times_array:[NSValue] = []
        for i in 1...499 {
            let t = CMTime(value: CMTimeValue(i*2), timescale: 1)
            times_array.append(NSValue(time: t))
        }
        
        let generator = AVAssetImageGenerator(asset: video_asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        generator.generateCGImagesAsynchronously(forTimes: times_array){ [self]
        requestedTime, image, actualTime, result, error in
            let img = UIImage(cgImage: image!)
            self.vid_frames.append(img)
            if (vid_frames.count == 499){
                show_image()
            }
        }*/
        print(video_file)
        img_to_frame_rat_h = image_frame_height / image_button_view.frame.size.height
        img_to_frame_rat_w = image_frame_width / image_button_view.frame.size.width
        if(video_file=="vid_1_blended"){
            frame_jump = 1
            vid_time_scale = 1.0
            img_id_multiplier = 1
        }
        else{
            frame_jump = 1
            vid_time_scale = 1.0
            img_id_multiplier = 1
        }
        let video_path = Bundle.main.url(forResource: video_file, withExtension: "mp4")
        video_asset = AVAsset(url: video_path!)
        
        let durationInSeconds = CMTimeGetSeconds(video_asset.duration);
        fps = Float64(video_asset.tracks(withMediaType: AVMediaType.video).first!.nominalFrameRate)
        vid_time_scale = 1.0/fps
        print(fps)
        print(vid_time_scale)
        video_frames = Int(durationInSeconds * fps)
        
        generator = AVAssetImageGenerator(asset: video_asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        self.total_frame_label.text = "tf:\(video_frames)"
        
        get_image()
        
        self.view.bringSubviewToFront(self.total_frame_label)
        if let localData = self.readLocalFile(forName: json_file) {
            self.json_polygon_data = self.parse(jsonData: localData)
        }

        DispatchQueue.global(qos: .background).async {
            var counter = 0
            while counter < self.video_frames{
                if(self.destroy){
                    break
                }
                self.img_id = counter
                // print(i)
                if(!self.paused){
                    self.get_image()
                    counter += 1
                }
                usleep(UInt32(self.vid_time_scale*1000000))
            }
        }
        //print("points: ", self.json_polygon_data.frame_data[0].classes[14].contours)
    }
    
    func get_image(){
        // let video_path = Bundle.main.url(forResource: video_file, withExtension: "mp4")
        // let video_asset = AVAsset(url: video_path!)
        
        /*let durationInSeconds = CMTimeGetSeconds(video_asset.duration);
        let fps = Float64(video_asset.tracks(withMediaType: AVMediaType.video).first!.nominalFrameRate)
        vid_time_scale = 1.0/fps
        video_frames = Int(durationInSeconds * fps) / frame_jump*/

        let t = CMTime(value: CMTimeValue(self.img_id), timescale: CMTimeScale(fps))
        let times_array:[NSValue] = [
            NSValue(time: t)
        ]
        
        generator.generateCGImagesAsynchronously(forTimes: times_array){ [self]
        requestedTime, image, actualTime, result, error in
            let img = UIImage(cgImage: image!)
            image_frame_width = img.size.width
            image_frame_height = img.size.height
            self.vid_frames = []
            self.vid_frames.append(img)
            self.show_image()
        }
        // self.view.bringSubviewToFront(self.current_frame_label)
    }
    
    func show_image(){
        DispatchQueue.main.async { [self] in
            for view in image_button_view.subviews {
                view.removeFromSuperview()
            }
            self.current_frame_label.text = "cf:\(self.img_id+1)"
            img_to_frame_rat_h = image_frame_height / image_button_view.frame.size.height
            image_button_view.frame.size.width = (image_frame_width/image_frame_height) * screen_height * multi
            img_to_frame_rat_w = image_frame_width / image_button_view.frame.size.width
            image_button_view.addBackground(image: self.vid_frames[0], contentMode: .scaleAspectFit)
            
            if(paused){
                for cls in self.json_polygon_data.frame_data[self.img_id].classes {
                    let class_id: Int = cls.class_id
                    let color: [Int] = cls.color
                    for contour in cls.contours {
                        var button_points: [CGPoint] = []
                        for pnt in contour {
                            let p = CGPoint(x: (Double(pnt[0])/img_to_frame_rat_h + 1), y: (Double(pnt[1])/img_to_frame_rat_w + 1))
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
                    }
                }
            }
            
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
        self.get_image()
    }
    
    @objc func action_func(_ sender: UIButton) {
        print("action_func")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


