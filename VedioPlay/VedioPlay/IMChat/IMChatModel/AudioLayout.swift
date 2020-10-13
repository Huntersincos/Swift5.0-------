//
//  AudioLayout.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/13.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

public let AudioMargin:CGFloat = 3
public let VoiceDurationLabelWidth:CGFloat = 30

class AudioLayout: BaseBubbleLayout {
    var durationLabelFrame:CGRect?
    var durationLabelText:String?
    var durationLabelAligment:NSTextAlignment?
    var durationLabelTextColor:UIColor?
    var imageViewFrame:CGRect?
    var audioImage:UIImage?
    var animationImages = [UIImage]()
    
    override func configWithMessage(_ message: ChatMessageObject?, _ showTime: Bool, _ showName: Bool) {
        super.configWithMessage(message, showTime, showName)
        
        durationLabelText = "\(String(describing: message?.fileMediaDuration))\'\'"
        
        
        var imageSepatorName = ""
        //var imageColor:UIColor?
        
        if (message?.messageTranDirection ==  .MessagirectionSend || message?.isCarbonCopy == true){
            durationLabelAligment = .left
            durationLabelTextColor = .white
            
            durationLabelFrame = CGRect(x: AudioMargin, y: 0, width: VoiceDurationLabelWidth, height: contentViewFrame?.size.height ?? 0)
            imageViewFrame = CGRect(x: durationLabelFrame?.maxX ?? 0 + AudioMargin, y: 0, width: contentViewFrame?.size.width ?? 0 - 3*AudioMargin-VoiceDurationLabelWidth, height: contentViewFrame?.size.height ?? 0)
            audioImage = UIImage.init(named: "SenderVoiceNodePlaying")
            
            imageSepatorName = "Sender"
            //imageColor = .white

        }else{
            durationLabelAligment = .right
            durationLabelTextColor =  RGBCOLOR(244.0, 74.0, 79.0, 1.0)
            
            durationLabelFrame = CGRect(x: AudioMargin, y: 0, width: (contentViewFrame?.size.width ?? 0) - 3*AudioMargin-VoiceDurationLabelWidth, height: contentViewFrame?.size.height ?? 0)
            imageViewFrame = CGRect(x: imageViewFrame?.maxX ?? 0 + AudioMargin, y: 0, width: VoiceDurationLabelWidth, height: contentViewFrame?.size.height ?? 0)
            audioImage = UIImage.init(named: "ReceiverVoiceNodePlaying")
            
            imageSepatorName = "Receiver"
            //imageColor = RGBCOLOR(244.0, 74.0, 79.0, 1.0)
        }
        var  i = 0
        for _  in 0...4 {
            
            let image = UIImage.init(named: "\(imageSepatorName)VoiceNodePlaying00\(i)")
            animationImages.append(image ?? UIImage.init())
            i += 1
            
        }
        
        
        
    }
    
    
}
