//
//  StoryCategoryModel.swift
//  StoryPlayer
//
//  Created by Furkan Bekil on 19.06.2020.
//  Copyright © 2020 Furkan Bekil. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class StoryCategoryModel {
    
    // Keys
    private let kId: String = "id"
    private let kTitle: String = "title"
    private let kmedia: String = "image"
    private let kStories: String = "stories"
    
    // Properties
    public var ID: Int?
    public var title: String?
    public var media: String?
    public var stories: [StoryDetailModel]?
    
    
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
        if let storiesArrayJson = json[kStories].array {
            let storiesArray: [StoryDetailModel] = storiesArrayJson.map {StoryDetailModel(json: $0)}
            self.stories = storiesArray
        }
    
    }
    
}
