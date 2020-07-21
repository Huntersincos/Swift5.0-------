//
//  AudioPlayHelper.swift
//  VedioPlay
//
//  Created by wenze on 2020/7/19.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AVFoundation
/**
 获取音频
 */
@objc protocol  AudioPlayHelperDelegate{
  
    // 开始播放
    func audioPlayerDidBeginPlay(_ audioPlay:AVAudioPlayer)

    // 播放结束
    func audioPlayerDidStopPlay(_ audioPlay:AVAudioPlayer)
    // 播放暂停

    func audioPlayerDidPausePlay(_ audioPlay:AVAudioPlayer)
}

class AudioPlayHelper: NSObject,AVAudioPlayerDelegate{
    fileprivate  static var  instacne = AudioPlayHelper()
    weak var delegate:AudioPlayHelperDelegate?
    var player:AVAudioPlayer?
    var filePath:String?
    var _isPlaying:Bool?
    public static var shareInstance:AudioPlayHelper{
        get{
            return instacne
        }
    }
    
    func stopAudio() {
        self.filePath = "";
        if player != nil {
            if player?.isPlaying ?? false{
                delegate?.audioPlayerDidStopPlay(player ?? AVAudioPlayer.init())
            }
        }
        // isProximityMonitoringEnabled 监听传感器状态 false 关闭了
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    func pauseAudio() {
        if player != nil {
            player?.pause()
            delegate?.audioPlayerDidPausePlay(player ?? AVAudioPlayer.init())
        }
    }
    
    func playAudioWithFilePath(_ filePath:String)  {
        
        if filePath.count > 0 {
            //AVAudioSession 管理多个App对音频硬件设备资源的使用
            // 1 设置自己的APP可以是否和其他App音频同时存在  还是中断App声音
            // 2 在静音模式 ,是否播放声音
            // 3 电话或者其他App中断自己App的处理事件
            // 4 指定音频输入和输入设备
            // 5 是否支持录音,录音的时候播放声音
            // 6 Category:(1) playback:只支持音频播放。音频不会被静音键和锁屏键静音。适用于音频是主要功能的APP,默认打断App,可以设置不打断 (2) ambient:只支持音频播放。这个 Category，音频会被静音键和锁屏键静音。并且不会打断其他应用的音频播放 (3)soloAmbient:默认的Category  音频会被静音键和锁屏键静音。会打断其他应用的音频播放
            // 7 defaultToSpeaker:设置默认输出音频到扬声器
            try?AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            if #available(iOS 10.0, *) {
                try?AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            } else {
                // Fallback on earlier versions
            }
            if self.filePath != nil {
                if self.player != nil{
                    if self.filePath == filePath {
                         self.player?.play()
                        UIDevice.current.isProximityMonitoringEnabled = true
                        self.delegate?.audioPlayerDidBeginPlay(self.player ?? AVAudioPlayer.init())
                    }
                }
            }else{
                if self.player != nil {
                    self.player?.stop()
                    self.player = nil;
                }
          //对于arm文件处理:在iOS4.3之后，AVAudioPlayer是不支持播放amr文件格式的音频，AudioServicesPlaySystemSound虽支持少于三十秒的amr文件播放，但是只能用做铃声播放，不能当音频来播放。 对此需要将amr格式转码成wav格式
                if filePath.hasSuffix("arm") {
                    //
                }
                self.player = try?AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: filePath))
                self.player?.delegate = self
                self.player?.play()
                UIDevice.current.isProximityMonitoringEnabled = true;
                self.delegate?.audioPlayerDidBeginPlay(self.player ?? AVAudioPlayer.init())
            }
            
            
        }
        
        self.filePath = filePath;
        
    }
    
    var isPlaying:Bool?{
        get{
            if self.player == nil{
                return false
            }
            return self.player?.isPlaying
        }
    }
    
    override init() {
        super.init()
        self.changeProximityMonitorEnableState(false)
        UIDevice.current.isProximityMonitoringEnabled = false
        
    }
    
    
    // avdiodelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stopAudio()
        self.delegate?.audioPlayerDidStopPlay(self.player ?? AVAudioPlayer.init())
    }
    
    
    deinit {
        self.changeProximityMonitorEnableState(true)
    }
    
    func changeProximityMonitorEnableState(_ enable:Bool)  {
        UIDevice.current.isProximityMonitoringEnabled = true
        if UIDevice.current.isProximityMonitoringEnabled {
            if enable {
                NotificationCenter.default .addObserver(self, selector: #selector(sensorStateChange), name: UIDevice.proximityStateDidChangeNotification, object: nil)
            }else{
                NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
                UIDevice.current.isProximityMonitoringEnabled = false
                
            }
        }
    }
    
   @objc private func sensorStateChange(noti: Notification) {
        print(noti)
    //proximityState 靠近传感器
    if  UIDevice.current.proximityState {
    try?AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        // 录音
    }else{
    try?AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        if self.player == nil || self.player?.isPlaying == false  {
            UIDevice.current.isProximityMonitoringEnabled = false
        }
        
    }
    
    
   }
    
    
}
