//
//  JSONStruct.swift
//  GTASemanticAudio
//
//  Created by Imran Kabir on 6/4/22.
//

import Foundation

struct Classes: Codable {
    var class_id: Int
    var class_name: String
    var color: [Int]
    var contours: [[[Int]]]
}

struct FrameData: Codable {
    var frame: String?
    var classes: [Classes]
}

struct JsonData: Codable {
    var frame_data: [FrameData]
}
