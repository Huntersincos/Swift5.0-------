//
//  MyAVPlayerItem.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AVFoundation

class MyAVPlayerItem: AVPlayerItem {
    weak var observer:AnyObject!
    deinit {
        if (self.observer != nil) {
            self.removeObserver(self.observer as! NSObject, forKeyPath: "status")
            self.removeObserver(self.observer as! NSObject, forKeyPath: "loadedTimeRanges")
            self.removeObserver(self.observer as! NSObject, forKeyPath: "playbackBufferEmpty")
            self.removeObserver(self.observer as! NSObject, forKeyPath: "playbackLikelyToKeepUp")
        }
    }
    
}
