//
//  LoactionLayout.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/13.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class LoactionLayout: BaseBubbleLayout {
   
    var iconImage:UIImage?
    var iconImageFrame:CGRect?
    var titleLabelText:String?
    var titleLabelFrame:CGRect?
    var titleLabelTextColor:UIColor?
    
    override func configWithMessage(_ message: ChatMessageObject?, _ showTime: Bool, _ showName: Bool) {
        super.configWithMessage(message, showTime, showName)
        iconImage = UIImage.init(named: "message_map")
        iconImageFrame = CGRect(x: 0, y: 50, width: LocationSize().width, height: LocationSize().height - 50)
        titleLabelText = message?.geoFreeText
        titleLabelFrame = CGRect(x: 0, y: 0, width: LocationSize().width, height: 50)
        titleLabelTextColor = .black
        bubbleViewBackgroupColor = .clear
        
    }
    
}
