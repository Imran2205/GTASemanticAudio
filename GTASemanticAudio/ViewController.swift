//
//  ViewController.swift
//  GTASemanticAudio
//
//  Created by Imran Kabir on 5/4/22.
//

import AVFoundation
import AssetsLibrary
import UIKit

class ViewController: UIViewController, AVSpeechSynthesizerDelegate  {

    //@IBOutlet weak var vid_image_view: UIImageView!
    // private var vid_frames: [UIImage] = []
    
    @IBOutlet weak var image_button_view: UIView!
    
    @IBOutlet weak var current_frame_label: UILabel!
    @IBOutlet weak var total_frame_label: UILabel!
    @IBOutlet weak var class_name_label: UILabel!
    @IBOutlet weak var next_but: UIButton!
    @IBOutlet weak var prev_but: UIButton!
    
    private var vid_frames: [UIImage] = []
    private var img_id = 0
    private var json_polygon_data = JsonData(frame_data: [FrameData(frame: "", classes: [Classes(class_id: 0, class_name: "", color: [0], contours: [[[0]]])])])
    
    let screenSize: CGRect = UIScreen.main.bounds
    var screen_height: Double = 0.0
    var screen_width: Double = 0.0
    
    var img_to_frame_rat = 0.0
    
    let synthesizer = AVSpeechSynthesizer()
    
    @IBAction func prev_button(_ sender: Any) {
        if (self.img_id > 0){
            self.img_id -= 1
        }
        get_image()
    }
    
    @IBAction func next_button(_ sender: Any) {
        if (self.img_id < 499){
            self.img_id += 1
        }
        get_image()
    }
    
    override public var shouldAutorotate: Bool {
        return false
    }
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*let p1 = CGPoint(x: 200, y: 50.0)
        let p2 = CGPoint(x: 300, y: 150.0)
        let p3 = CGPoint(x: 100, y: 150.0)
        
        let triangle = PolyButton(points: [p1,p2,p3], color: UIColor.green, frame: self.view.bounds)
        triangle.addTarget(self, action: #selector(didPressTriangle(_ :)), for: UIControl.Event.touchUpInside)

        let p4 = CGPoint(x: 150.0, y: 200.0)
        let p5 = CGPoint(x: 250.0, y: 200.0)
        let p6 = CGPoint(x: 250.0, y: 300.0)
        let p7 = CGPoint(x: 150.0, y: 300.0)
        
        let square = PolyButton(points: [p4,p5,p6,p7], color: UIColor.red, frame: self.view.bounds)
        square.addTarget(self, action: #selector(didPressSquare(_ :)), for: UIControl.Event.touchUpInside)
        
        let p8 = CGPoint(x: 200.0, y: 350.0)
        let p9 = CGPoint(x: 105.0, y: 419.0)
        let p10 = CGPoint(x: 141.0, y: 531.0)
        let p11 = CGPoint(x: 259.0, y: 531.0)
        let p12 = CGPoint(x: 295.0, y: 419.0)
        
        let pentagon = PolyButton(points: [p8,p9,p10,p11,p12], color: UIColor.blue, frame: self.view.bounds)
        pentagon.addTarget(self, action: #selector(didPressPentagon(_ :)), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(triangle)
        self.view.addSubview(square)
        self.view.addSubview(pentagon)*/
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
        if (screenSize.height < screenSize.width){
            screen_height = screenSize.height
            screen_width = screenSize.width
        }
        else {
            screen_height = screenSize.width
            screen_width = screenSize.height
        }
        
        image_button_view.frame.origin.x = 0.0912 * screen_width
        image_button_view.frame.origin.y = 0.0513 * screen_height
        image_button_view.frame.size.height = screen_height * 0.8975
        image_button_view.frame.size.width = 1.97  * screen_height * 0.8975
        
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
        next_but.frame.size.width = screen_width * 0.07109
        
        prev_but.frame.origin.x = 0.0106 * screen_width
        prev_but.frame.origin.y = 0.8231 * screen_height
        prev_but.frame.size.height = screen_height * 0.07949
        prev_but.frame.size.width = screen_width * 0.07109
        
        img_to_frame_rat = 520.0 / image_button_view.frame.size.height
        
        get_image()
        self.view.bringSubviewToFront(self.total_frame_label)
        self.total_frame_label.text = "tf:\(500)"
        if let localData = self.readLocalFile(forName: "polygons_vid_1") {
            self.json_polygon_data = self.parse(jsonData: localData)
        }
        //print("points: ", self.json_polygon_data.frame_data[0].classes[14].contours)
    }
    
    func get_image(){
        let video_path = Bundle.main.url(forResource: "vid_1_blended", withExtension: "mp4")
        let video_asset = AVAsset(url: video_path!)

        let t = CMTime(value: CMTimeValue(self.img_id*2), timescale: 1)
        let times_array:[NSValue] = [
            NSValue(time: t)
        ]

        let generator = AVAssetImageGenerator(asset: video_asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        generator.generateCGImagesAsynchronously(forTimes: times_array){ [self]
        requestedTime, image, actualTime, result, error in
            let img = UIImage(cgImage: image!)
            self.vid_frames = []
            self.vid_frames.append(img)
            show_image()
        }
        self.view.bringSubviewToFront(self.current_frame_label)
        self.current_frame_label.text = "cf:\(self.img_id+1)"
    }
    
    func show_image(){
        DispatchQueue.main.async { [self] in
            for view in image_button_view.subviews {
                view.removeFromSuperview()
            }
            image_button_view.addBackground(image: self.vid_frames[0], contentMode: .scaleAspectFit)
            
            
            for cls in self.json_polygon_data.frame_data[self.img_id].classes {
                let class_id: Int = cls.class_id
                let color: [Int] = cls.color
                for contour in cls.contours {
                    var button_points: [CGPoint] = []
                    for pnt in contour {
                        let p = CGPoint(x: (Double(pnt[0])/img_to_frame_rat + 1), y: (Double(pnt[1])/img_to_frame_rat + 1))
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
    
    /*func readJSONFromFile(fileName: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let json_data = try decoder.decode(JsonData.self, from: data)
                //json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("json data --->> \n\(json_data)")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }*/
    
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
    
    @objc func action_func(_ sender: UIButton) {
        print("action_func")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

