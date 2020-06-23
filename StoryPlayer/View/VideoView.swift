//
//  videoView.swift
//  StoryPlayer
//
//  Created by Furkan Bekil on 23.06.2020.
//  Copyright © 2020 Furkan Bekil. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoView: UIView {
    
    public var player: AVPlayer?
    public var playerLayer: AVPlayerLayer?
    
    convenience init(frame: CGRect, player: AVPlayer, playerLayer: AVPlayerLayer) {
        self.init(frame: frame)
        self.player = player
        self.playerLayer = playerLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
