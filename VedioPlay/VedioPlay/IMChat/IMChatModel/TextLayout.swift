//
//  TextLayout.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/13.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class TextLayout: BaseBubbleLayout {
   
    var contentLabelFrame:CGRect?
    var contentLabelText:String?
    var contentLabelTextColor:UIColor?
    override func configWithMessage(_ message: ChatMessageObject?, _ showTime: Bool, _ showName: Bool) {
        super.configWithMessage(message, showTime, showName)
        contentLabelText = self.message?.content
        
         if (message?.messageTranDirection ==  .MessagirectionSend || message?.isCarbonCopy == true){
            
            contentLabelTextColor = .white
            
            }else{
              
             contentLabelTextColor = .black
          }
        
         contentLabelFrame = CGRect(x: 0, y: 0, width: self.contentLabelFrame?.width ?? 0, height: self.contentLabelFrame?.height ?? 0)
        
    }
}
