//
//  ThumbImageLayout.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/13.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

//public let durationLabelHeight:CGFloat = 20
//public let durationLabelMargin:CGFloat = 15

func  durationLabelHeight() -> CGFloat{
    return 20
}

func durationLabelMargin() ->CGFloat{
    
    return 15
}


class ThumbImageLayout: BaseBubbleLayout {
  
    var playBtnImage:UIImage?
    var thumbnail:UIImage?
    var showPlayBtn:Bool?
    var thumbnailFrame:CGRect?
    var playBtnFrame:CGRect?
    var showDurationLabel:Bool?
    var durationLabelFrame:CGRect?
    var durationLabelText:String?
    
    override func configWithMessage(_ message: ChatMessageObject?, _ showTime: Bool, _ showName: Bool) {
        super.configWithMessage(message, showTime, showName)
        
        if SDWebImageManager.isBlankString(message?.fileThumbPath) == false {
            thumbnail = UIImage.init(contentsOfFile: JRFileUtil.getAbsolutePathWithFileRelativePath(message?.fileThumbPath ?? ""))
            
        }
        
        showPlayBtn = message?.messageType == .MessageItemTypeVideo
        
        if message?.messageType == .MessageItemTypeVideo {
            playBtnImage = UIImage.init(named: "btn_play")
            durationLabelText = "\(String(describing: message?.fileMediaDuration))\'\'"
            showDurationLabel = true
        }else{
           playBtnImage = UIImage.init(named: "")
           showDurationLabel = false
        }
        
        thumbnailFrame = CGRect(x: 0, y: 0, width: contentViewFrame?.width ?? 0, height: contentViewFrame?.height ?? 0)
        playBtnFrame = CGRect(x: (thumbnailFrame?.size.width ?? 0)/2  - 25, y: (thumbnailFrame?.size.height ?? 0)/2  - 25, width: 25, height: 25)
        durationLabelFrame = CGRect(x: durationLabelMargin(), y: (thumbnailFrame?.size.height ?? 0) - durationLabelHeight() - durationLabelMargin(), width: (thumbnailFrame?.size.width ?? 0) - 2*durationLabelMargin(), height: durationLabelHeight())
        bubbleViewBackgroupColor  = .clear
    }
}
