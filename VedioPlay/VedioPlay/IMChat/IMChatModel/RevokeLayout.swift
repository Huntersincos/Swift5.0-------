//
//  RevokeLayout.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class RevokeLayout: NSObject {
    public var  RevokeMargin:CGFloat = 10
    public var RevokeBubbleMargin:CGFloat = 10
    public var RevokeCellWidth:CGFloat = UIScreen.main.bounds.size.width
    public var RevokeContentLabelMaxWidth:CGFloat = UIScreen.main.bounds.size.width - 100
    
    var message:ChatMessageObject?
    var revokeHintLabelFrame:CGRect?
    var revokeHintLabelText:String?
    var revokeHintLabelColor:UIColor?
    var imdnId:String?
    
    func configWithMessage(_ message:ChatMessageObject){
        
        self.message = message
        self.imdnId = message.imdnId
        
        if message.messageTranDirection == MessageItemDirection.MessagirectionSend {
            revokeHintLabelText =  NSLocalizedString("MESSAGE_REVOKED",tableName: nil, comment: "")
        }else{
            revokeHintLabelText = NSLocalizedString("REVOKED",tableName: nil, comment: "")
        }
        
        revokeHintLabelColor = RGBCOLOR(50.0, 50.0, 50.0, 0.3)
        
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]
        
        //usesLineFragmentOrigin:那么整个文本将以每行组成的矩形为单位计算整个文本的尺寸。
        let contetSize = revokeHintLabelText?.boundingRect(with: CGSize(width: RevokeContentLabelMaxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        let centerY =  RevokeMargin + (contetSize?.height ?? 0)/2 + RevokeBubbleMargin
        let size =  CGSize(width: (contetSize?.width ?? 0) + 2 * RevokeBubbleMargin, height: contetSize?.height ?? 0 + 2 * RevokeBubbleMargin)
        let center = CGPoint(x: RevokeCellWidth/2, y: centerY)
        revokeHintLabelFrame = CGRect(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
    
    func calculateCellHeight() -> CGFloat{
         let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]
         let contetSize = revokeHintLabelText?.boundingRect(with:  CGSize(width: RevokeContentLabelMaxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        return  (contetSize?.height ?? 0) + 2*RevokeMargin + 2*RevokeBubbleMargin;
          
    }
    
}
