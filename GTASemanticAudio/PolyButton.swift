//
//  PolygonButton.swift
//  GTASemanticAudio
//
//  Created by Imran Kabir on 5/4/22.
//

import UIKit


class PolyButton: UIButton {
    
    /// The path outlining the button.
    var bezierPath: UIBezierPath = UIBezierPath()
    
    var class_name : String = ""
    
    /// Button action - Only use if you want the button event target to be the button itself.
    var action: ((AnyObject?) -> ())? = nil
    
    init(points: [CGPoint], color: UIColor, frame: CGRect) {
        super.init(frame: .zero)
        
        if points.count < 3 {
            print("Cannot create a polygonal button with less than three points.")
            return
        }
        self.frame = frame
        self.backgroundColor = color
        
        bezierPath.move(to: points[0])
        let up_range = points.count-1
        for index in 0...up_range {
            bezierPath.addLine(to: points[index])
        }
        bezierPath.close()
        
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = bezierPath.cgPath
        self.layer.mask = mask
        self.addTarget(self, action: #selector(buttonAction(_ :)), for: UIControl.Event.touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        action?(sender)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if bezierPath.contains(point) {
            return self
        }
        return nil
    }
}

