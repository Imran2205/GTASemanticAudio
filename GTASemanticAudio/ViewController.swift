//
//  ViewController.swift
//  GTASemanticAudio
//
//  Created by Imran Kabir on 5/4/22.
//

import AVFoundation
import AssetsLibrary
import UIKit

class ViewController: UIViewController {

    //@IBOutlet weak var vid_image_view: UIImageView!
    // private var vid_frames: [UIImage] = []
    
    @IBOutlet weak var image_button_view: UIView!
    
    private var vid_frames: [UIImage] = []
    private var img_id = 0
    
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
        get_image()
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
    }
    
    func show_image(){
        DispatchQueue.main.async { [self] in
            for view in image_button_view.subviews {
                view.removeFromSuperview()
            }
            image_button_view.addBackground(image: self.vid_frames[0], contentMode: .scaleAspectFit)
        }
    }
    
    @objc func didPressTriangle(_ sender: AnyObject?) {
        print("Triangle")
    }
    
    @objc func didPressSquare(_ sender: AnyObject?) {
        print("Square")
    }
    
    @objc func didPressPentagon(_ sender: AnyObject?) {
        print("Pentagon")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

