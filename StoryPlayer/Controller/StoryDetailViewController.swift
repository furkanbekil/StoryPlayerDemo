//
//  StoryDetailViewController.swift
//  StoryPlayer
//
//  Created by Furkan Bekil on 20.06.2020.
//  Copyright © 2020 Furkan Bekil. All rights reserved.
//

import UIKit
import Kingfisher
import SpriteKit
import AVFoundation

class StoryDetailViewController: UIViewController {

    // Loading View
    @IBOutlet weak var loadingView: UIView!
    
    // Cube View
    @IBOutlet weak var cubeView: OHCubeView!
    
    // Current Stories
    var allStoriesViewArray = [UIView]()
    var currentStories = [StoryDetailModel]()
    
    // Progress Container View
    var spb: SegmentedProgressBar!
    
    // Current Index
    var currentIndex = 0
    var currentStoryIndex = 0
    
    // Tap Recognizer
    var tap:UITapGestureRecognizer!
    
    // Current Player
    var currentPlayer: AVPlayer?
    var currentPlayerLayer: AVPlayerLayer?
    var isVideoPlaying = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(StoryDetailViewController.playerItemDidReachEnd),
              name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
              object: self.currentPlayer?.currentItem)
        
        // Cube View Delegate Assigning
        self.cubeView.cubeDelegate = self
        
        // Add Swipe Gestures
        self.addSwipe()
        
        //Add all subviews to the cube view
        self.addCubeViewForStories()
        
    }
    
    override var prefersStatusBarHidden: Bool {
      return false
    }
    
    func addCubeViewForStories() {
        
        for x in 0 ..< DataManager.allStories.count {
            
            let item = DataManager.allStories[x]
            let storyView = UIView()
            
            let videoURL = URL(string: (item.stories?[0].media)!)
            let player = AVPlayer.init(url: videoURL!)
            let playerLayer = AVPlayerLayer(player: player)
            let videoView = VideoView.init(frame: self.view.frame, player: player, playerLayer: playerLayer)
            
            playerLayer.frame = self.view.bounds
            videoView.layer.addSublayer(playerLayer)
            
            
            let imageView = UIImageView()
            imageView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
            storyView.addSubview(imageView)
            storyView.addSubview(videoView)
            
            if item.stories![0].isVideo! == 1 {
                
                storyView.subviews[0].isHidden = true
                storyView.subviews[1].isHidden = false
                
            } else {
                
                storyView.subviews[0].isHidden = false
                storyView.subviews[1].isHidden = true
                let url = URL(string: (item.stories?[0].media)!)
                imageView.kf.setImage(with: url)
                
            }
            
            
            allStoriesViewArray.append(storyView)
            cubeView.addChildView(storyView)
            
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        cubeView.addGestureRecognizer(longPressRecognizer)
        
        // Go to proper index and hide the loading view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.cubeView.scrollTo(horizontalPage: self.currentIndex)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.loadingView.isHidden = true
            self.adjustStoryCollection(DataManager.allStories[self.currentIndex])
        }
        
        
    }
    
    func adjustStoryCollection(_ item: StoryCategoryModel) {
        
        // Segmented Progress Bar UI Adjustments
        self.spb = SegmentedProgressBar(numberOfSegments: item.stories!.count, duration: 5)
        spb.frame = CGRect(x: 10, y: 52, width: view.frame.width - 20, height: 4)
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.white.withAlphaComponent(0.40)
        spb.padding = 2
        view.addSubview(spb)
        
        // This is for testing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.spb.startAnimation()
        }
        // Segmented Progress Bar Delegate Assigning
        spb.delegate = self
        
        // Get the current stories
        currentStories = item.stories!
        
//        self.tap.isEnabled = true
        
    }
    
}

// Swipe Adjustments
extension StoryDetailViewController {
    
    func addSwipe() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .right, .left]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
    }
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizer.Direction.down:
                    self.dismiss(animated: true, completion: nil)
            
                default:
                    break
            }
        }
        
    }
    
}

extension StoryDetailViewController: OHCubeViewDelegate {
    
    func cubeViewStartedToScroll() {
        self.stopProgress()
    }
    
    
    func cubeViewIndexChanged(_ index: Int) {
        
        if index == self.currentIndex {
            // No swipe happened
            self.spb.isPaused = false
        } else {
            self.changeIndex(isNext: true, withIndex: index)
        }
        
    }
    
}

extension StoryDetailViewController: SegmentedProgressBarDelegate {
    
    func segmentedProgressBarChangedIndex(index: Int) {
        
    }
    
    func segmentedProgressBarFinished() {
        
        self.goNext()
        
    }
    
    func nextAuto() {
        
        self.goNext()
        
    }
    
    func goNext() {
        
//        self.tap.isEnabled = false
        if currentPlayer != nil {
            self.currentPlayer?.pause()
            self.currentPlayerLayer?.removeFromSuperlayer()
        }
        
        currentStoryIndex += 1
        
        if self.currentStoryIndex >= self.currentStories.count {
            // Means that changing to next section
            print("next section")
            self.changeIndex(isNext: true, withIndex: nil)
            self.currentStoryIndex = 0
            
        } else {
            // Means that changing to next media
            self.spb.skip()
            if currentStories[self.currentStoryIndex].isVideo == 1 {
                print("next video")
                self.adjustVideo()
            } else {
                print("next image")
                self.adjustImage()
            }
            
        }
        
    }
    
    func goPrevious() {
        
        currentStoryIndex -= 1
        
        if self.currentStoryIndex < 0 {
            // Means that changing to next section
            print("previous section")
            self.changeIndex(isNext: false, withIndex: nil)
            self.currentStoryIndex = 0
            
        } else {
            // Means that changing to next media
            print("previous image")
            self.adjustImage()
            self.spb.rewind()
            
        }
        
    }
    
    func adjustImage() {
        let videoView = allStoriesViewArray[self.currentIndex].subviews[1] as! VideoView
        let imageView = allStoriesViewArray[self.currentIndex].subviews[0] as! UIImageView
        
        videoView.isHidden = true
        imageView.isHidden = false
        
        let url = URL(string: (currentStories[self.currentStoryIndex].media!))
        imageView.kf.setImage(with: url)
        
//        self.tap.isEnabled = true
        
    }
    
    func adjustVideo() {
        spb.isPaused = true
        
        let videoView = allStoriesViewArray[self.currentIndex].subviews[1] as! VideoView
        let imageView = allStoriesViewArray[self.currentIndex].subviews[0] as! UIImageView
        
        videoView.isHidden = false
        imageView.isHidden = true
        
        
        let url = URL(string: (currentStories[self.currentStoryIndex].media!))
        videoView.player = AVPlayer.init(url: url!)
        videoView.playerLayer = AVPlayerLayer(player: videoView.player)
        videoView.playerLayer!.frame = self.view.bounds
        videoView.layer.addSublayer(videoView.playerLayer!)
        
        self.currentPlayer = videoView.player
        self.currentPlayerLayer = videoView.playerLayer
        
        videoView.player!.addObserver(self, forKeyPath: "reasonForWaitingToPlay", options: .new, context: .none)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == .none else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        // look at `change![.newKey]` to see what the status is, e.g.

        if keyPath == "reasonForWaitingToPlay" {
            NSLog("\(keyPath): \(change![.newKey])")
            
            if change![.newKey] as? AVPlayer.WaitingReason == .toMinimizeStalls || change![.newKey] as? AVPlayer.WaitingReason == .noItemToPlay || change![.newKey] as? AVPlayer.WaitingReason == .evaluatingBufferingRate {
                
                print("notReady")
                
            } else {
                
                if change![.newKey] as? AVPlayer.WaitingReason == nil {
                    
                    if !self.isVideoPlaying {
                        self.currentPlayer?.play()
                        self.isVideoPlaying = true
                        self.spb.isPaused = false
                    }
                    
                    print("ready")
                    print("seconds = \(self.currentPlayer?.currentItem?.asset.duration.seconds)")
                    
                    
                }
            }
            
        }
    }
    
    @objc func playerItemDidReachEnd() {
       
        // Video Bitti
        print("video ended")
        
    }
    
    func changeIndex(isNext: Bool, withIndex: Int?) {
        
        if let index = withIndex {
            self.currentIndex = index
        } else {
            if isNext {
                self.currentIndex += 1
            } else {
                self.currentIndex -= 1
            }
        }
        
        self.cubeView.scrollTo(horizontalPage: self.currentIndex)
        
        // Reset The Segmented Progress Bar
        self.spb.removeFromSuperview()
        
        if self.currentIndex < 0 || self.currentIndex >= DataManager.allStories.count {
            // Dismiss
            self.dismiss(animated: true, completion: nil)
        } else {
            let storyCategoryItem = DataManager.allStories[self.currentIndex]
            self.adjustStoryCollection(storyCategoryItem)
        }
        
    }
    
    func stopProgress() {
        
        self.spb.isPaused = true
        
    }
    
    func resumeProgress() {
        
        self.spb.isPaused = false
        
    }
    
}

// Gesture Tap
extension StoryDetailViewController {
    
    @objc func tap(sender:UITapGestureRecognizer){

        if sender.state == .ended {

            let touchLocation: CGPoint = sender.location(in: sender.view)
            let edge = 100
    
            if touchLocation.x >= self.view.frame.width / 2 + CGFloat(edge / 2) {
                // Means Next
                print("gesture next")
                self.goNext()
            } else if touchLocation.x <= self.view.frame.width / 2 - CGFloat(edge / 2) {
                // Means Previous
                print("gesture previous")
                self.goPrevious()
            }

        }
    }
    
    @objc func longPressed(sender:UILongPressGestureRecognizer){
        
        if sender.state == .ended{
            self.resumeProgress()
        } else if sender.state == .began {
            self.stopProgress()
        }
        
    }
    
}
