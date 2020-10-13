//
//  BaseBubbleLayout.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

let  TimeLabelHeight:CGFloat = 20
let  NameLabelHeight:CGFloat = 20
let  CellWidth:CGFloat = UIScreen.main.bounds.width
let  AvatorSize:CGFloat = 40
let  Margin:CGFloat = 5
let  ContentLabelMaxWidth:CGFloat = CellWidth-AvatorSize-2*Margin-75
let BubbleViewMargin:CGFloat = 10
let StateViewSize:CGFloat = 15
let StateViewMargin:CGFloat = 5
let TextFont = UIFont.systemFont(ofSize: 12)
let ImgMaxLine:CGFloat = 200.0
let AudioSize = CGSize(width: 100, height: 20)
let LocationSize = CGSize(width: 200, height: 150)
let VCardSize = CGSize(width: 200, height: 100)
let OtherFileSize = CGSize(width: 200, height: 100)

class BaseBubbleLayout: NSObject {
   //Cannot use instance member 'AvatorSize' within property initializer; property initializers run before 'self' is available
    var message:ChatMessageObject?
    var timeLabelFrame:CGRect?
    var timeLabelText:String?
    var showTime:Bool?
    var nameLabelFrame:CGRect?
    var nameLabelTextAlignment:NSTextAlignment?
    var nameLabelText:String?
    var showName:Bool?
    var avatorViewFrame:CGRect?
    var avatorViewImage:UIImage?
    var stateViewFrame:CGRect?
    var stateViewImage:UIImage?
    var bubbleViewFrame:CGRect?
    var bubbleViewBackgroupColor:UIColor?
    var contentViewFrame:CGRect?
    var imdnId:String?
    
    func configWithMessage(_ message:ChatMessageObject?, _ showTime:Bool, _ showName:Bool){
        self.message = message;
        self.showTime = showTime;
        self.showName = showName;
        self.imdnId = message?.imdnId
        
        var avatorY:CGFloat = 0
        timeLabelText  = message?.timestamp as String?
        
        if showTime {
            timeLabelFrame = CGRect(x: 0, y: 0, width: CellWidth, height: TimeLabelHeight)
            avatorY += TimeLabelHeight
        }else{
            timeLabelFrame = CGRect.zero
        }
        
        switch message?.state {
            //'case' label in a 'switch' should have at least one executable statement == selove fallthrough
           case .MessageItemStateInit:fallthrough
           case .MessageItemStateSending:
           
            if message?.messageType != .MessageItemTypeText {
                stateViewImage = UIImage.init(named: "im_sending")
            }
            break
            
          case .MessageItemStateReceiveOK:fallthrough
          case .MessageItemStateRevoked:
            stateViewImage = nil
            break
            
         case .MessageItemStateDelivered:
              stateViewImage = UIImage.init(named: "im_dli")
            break
            
        case .MessageItemStateRead:
            
            stateViewImage = UIImage.init(named: "im_dli")
        break
            
        default:
        break
     }
      
        if (message?.messageTranDirection ==  .MessagirectionSend || message?.isCarbonCopy == true){
            stateViewImage = UIImage.init(named: "img_blueman_nor")
        } else{
            stateViewImage = UIImage.init(named: "img_greenman_nor")
        }
        
      
        if SDWebImageManager.isBlankString(nameLabelText){
            nameLabelText = message?.senderName
        }
    
        if showName {
            nameLabelFrame = CGRect(x: AvatorSize + 2 * Margin, y: timeLabelFrame?.size.height ?? 0, width: CellWidth - 2*(AvatorSize + 2 * Margin), height: NameLabelHeight)
            avatorY += NameLabelHeight
        }else{
            nameLabelFrame = CGRect.zero
        }
        
        let bubbleSize = calculateBubbleViewSize()
        
        if self.message?.messageTranDirection == .MessagirectionSend || self.message?.isCarbonCopy == true {
            nameLabelTextAlignment = .right
            avatorViewFrame = CGRect(x: CellWidth-(AvatorSize+Margin), y: avatorY+Margin, width: AvatorSize, height: AvatorSize)
            bubbleViewFrame = CGRect(x: CellWidth - (avatorViewFrame?.width ?? 0 + 2*Margin) - bubbleSize.width, y: avatorY+Margin, width: bubbleSize.width, height: bubbleSize.height)
            bubbleViewBackgroupColor = RGBCOLOR(244.0, 74.0, 79.0, 1.0)
            contentViewFrame = CGRect(x: BubbleViewMargin, y: BubbleViewMargin, width: bubbleSize.width-2*BubbleViewMargin, height: bubbleSize.height-2*BubbleViewMargin)
            stateViewFrame = CGRect(x: (bubbleViewFrame?.origin.x ?? 0)-StateViewMargin-StateViewSize, y: bubbleViewFrame?.midY ?? 0 - StateViewSize/2, width: StateViewSize, height: StateViewSize)
        }else{
            nameLabelTextAlignment = .left
            avatorViewFrame = CGRect(x: Margin, y: avatorY+Margin, width: AvatorSize, height: AvatorSize)
            bubbleViewFrame = CGRect(x: avatorViewFrame?.maxX ?? 0 + Margin, y: avatorY+Margin, width: bubbleSize.width, height: bubbleSize.height)
            bubbleViewBackgroupColor = .white
            contentViewFrame = CGRect(x: BubbleViewMargin, y: BubbleViewMargin, width: bubbleSize.width-2*BubbleViewMargin, height: bubbleSize.height-2*BubbleViewMargin)
            stateViewFrame = CGRect(x: bubbleViewFrame?.maxX ?? 0  + StateViewMargin, y: bubbleViewFrame?.midY ?? 0 - StateViewSize/2, width: StateViewSize, height: StateViewSize)
            
        }
        
  }
    
    func calculateCellHeight() -> CGFloat{
        
        var height:CGFloat = 0
        
        if showTime ?? false {
            height +=  TimeLabelHeight
        }
        
        if showName ?? false {
            height +=  NameLabelHeight
        }
        
        let bubbleHeight = calculateBubbleViewSize().height
        
        if bubbleHeight + 2*BubbleViewMargin<AvatorSize {
            height += AvatorSize
        }else{
             height += (bubbleHeight+2*BubbleViewMargin)
        }
        height += Margin*2;
        return height;
        
    }
    
    func calculateBubbleViewSize() ->CGSize{
        
        var size = CGSize.zero
        
        switch self.message?.messageType {
        case .MessageItemTypeUnknow:
            break
        case .MessageItemTypeText:
            let attributes = [NSAttributedString.Key.font:TextFont]
            let contetSize = self.message?.content.boundingRect(with: CGSize(width: ContentLabelMaxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
            size = CGSize(width: contetSize?.width ?? 0 + 2 * BubbleViewMargin , height: contetSize?.height ?? 0  + 2*BubbleViewMargin)
            break
        case .MessageItemTypeVideo:fallthrough
        case .MessageItemTypeImage:
            if SDWebImageManager.isBlankString(self.message?.fileThumbPath) == false {
                let image = UIImage.init(contentsOfFile: JRFileUtil.getAbsolutePathWithFileRelativePath(self.message?.fileThumbPath ?? ""))
                var height,width:CGFloat
                
                if image?.size.height ?? 0 > image?.size.width ?? 0 {
                   height = ImgMaxLine
                   width =  ImgMaxLine * (image?.size.width ?? 0)/(image?.size.height ?? 1)
                }else{
                    width = ImgMaxLine
                    height =  ImgMaxLine * (image?.size.height ?? 0)/(image?.size.width ?? 1)
                }
                
                size = CGSize(width: width+2*BubbleViewMargin, height: height+2*BubbleViewMargin)
                
            }else{
                size = CGSize(width: 100+2*BubbleViewMargin, height: 100+2*BubbleViewMargin)
            }
            
            break
            
        case .MessageItemTypeAudio:
            size = CGSize(width: AudioSize.width+2*BubbleViewMargin, height: AudioSize.height+2*BubbleViewMargin)
            break
            
        case .MessageItemTypeVcard:
             size = CGSize(width: VCardSize.width+2*BubbleViewMargin, height: VCardSize.height+2*BubbleViewMargin)
             break
        case .MessageItemTypeGeo:
            
            size = CGSize(width: LocationSize.width+2*BubbleViewMargin, height: LocationSize.height+2*BubbleViewMargin)
             break
            
        case  .MessageItemTypeOtherFile:
            
            size = CGSize(width: OtherFileSize.width+2*BubbleViewMargin, height: OtherFileSize.height+2*BubbleViewMargin)
            break
            
        default:
            break
        }
        
        return size
    }
    
}
