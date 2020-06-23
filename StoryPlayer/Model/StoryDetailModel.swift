//
//  StoryDetailModel.swift
//  StoryPlayer
//
//  Created by Furkan Bekil on 20.06.2020.
//  Copyright © 2020 Furkan Bekil. All rights reserved.
//

import Foundation
import SwiftyJSON

class StoryDetailModel {
    
    // Keys
    private let kId: String = "id"
    private let kTitle: String = "title"
    private let kmedia: String = "media"
    private let kIsVideo: String = "is_video"
    
    // Properties
    public var ID: Int?
    public var title: String?
    public var media: String?
    public var isVideo: Int?
    
    
    public required init(json: JSON) {
        
        if let id = json[kId].int {
            ID = id
        }
        if let titleString = json[kTitle].string {
            title = titleString
        }
        if let mediaString = json[kmedia].string {
            media = mediaString
        }
        if let isVideoBoolean = json[kIsVideo].int {
            isVideo = isVideoBoolean
        }
    
    }
    
}
