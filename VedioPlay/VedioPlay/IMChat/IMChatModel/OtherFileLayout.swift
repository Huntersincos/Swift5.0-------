//
//  OtherFileLayout.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/14.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

func  ThumbSize() -> CGFloat{
    return 50
}
func  LabelHeight() -> CGFloat{
    return 20
}

func  OtherFileMargin() -> CGFloat{
    return 10
}



// waring 这种定义方式 取值为空
//public let ThumbSize:CGFloat = 50
//public let LabelHeight:CGFloat = 20
//public let OtherFileMargin:CGFloat = 10

class OtherFileLayout: BaseBubbleLayout {
    
    var fileThumbImage:UIImage?
    var fileThumbFrame:CGRect?
    var fileName:String?
    var fileNameFrame:CGRect?
    var fileSize:String?
    var fileSizeFrame:CGRect?
    
    override func configWithMessage(_ message: ChatMessageObject?, _ showTime: Bool, _ showName: Bool) {
        super.configWithMessage(message, showTime, showName)
        if SDWebImageManager.isBlankString(message?.fileThumbPath) == false {
            fileThumbImage = UIImage.init(contentsOfFile: JRFileUtil.getAbsolutePathWithFileRelativePath(message?.fileThumbPath ?? ""))
        }else{
            fileThumbImage = UIImage.init(named: "ic_default_file")
        }
        
//        RGBCOLOR(<#T##r: CGFloat##CGFloat#>, <#T##g: CGFloat##CGFloat#>, <#T##b: CGFloat##CGFloat#>, <#T##alapha: CGFloat##CGFloat#>)
        
        fileThumbFrame = CGRect(x: OtherFileMargin(), y: OtherFileSize().height/2 - ThumbSize()/2, width: ThumbSize(), height: ThumbSize())
        fileName = message?.fileName
        fileNameFrame = CGRect(x: fileThumbFrame?.maxX ?? 0 + OtherFileMargin(), y: fileNameFrame?.origin.y ?? 0, width:  OtherFileSize().width - 3 * OtherFileMargin() - ThumbSize(), height: LabelHeight())
        let mb = (message?.fileSize ?? 0.0) / 1024.0 / 1024.0
        if mb != 0 {
            fileSize = "\(mb).MB"
        }else{
            fileSize = "\(mb * 1024).KB"
        }
        fileSizeFrame = CGRect(x: fileNameFrame?.origin.x ?? 0, y: fileNameFrame?.maxY ?? 0 + OtherFileMargin(), width: fileNameFrame?.size.width ?? 0, height: LabelHeight())
        bubbleViewBackgroupColor = .white
        
        
    }
    
}
