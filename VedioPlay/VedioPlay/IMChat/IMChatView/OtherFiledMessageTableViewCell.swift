//
//  OtherFiledMessageTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class OtherFiledMessageTableViewCell: BaseMessageCellTableViewCell {

    var fileThumbImageView:UIImageView?
    var fileNameLabel:UILabel?
    var fileSizeLabel:UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override class func superclass() -> AnyClass? {
        
        return OtherFileLayout.self
    }
    
    override func configWithLayou(_ layout: BaseBubbleLayout?) {
        super.configWithLayou(layout)
        
        if fileThumbImageView == nil {
            fileThumbImageView = UIImageView.init()
            fileThumbImageView?.contentMode = .scaleToFill
            fileThumbImageView?.isUserInteractionEnabled = true
            msgContentView?.addSubview(fileThumbImageView!)
        }
        
        if fileNameLabel == nil {
           fileNameLabel = UILabel.init(frame: CGRect.zero)
           //durationLabel?.font = TextFont
           fileNameLabel?.backgroundColor = .clear
           fileNameLabel?.textAlignment = .left
           fileNameLabel?.textColor = .black
           fileNameLabel?.lineBreakMode = .byTruncatingMiddle
           msgContentView?.addSubview(fileNameLabel!)
        }
        
       if fileSizeLabel == nil {
             fileSizeLabel = UILabel.init(frame: CGRect.zero)
             //durationLabel?.font = TextFont
             fileSizeLabel?.backgroundColor = .clear
             fileSizeLabel?.textAlignment = .left
             //vNumberLabel?.textColor = .gray
             msgContentView?.addSubview(fileSizeLabel!)
         }
        
        
        let tempLayout = layout as! OtherFileLayout
        fileThumbImageView?.image = tempLayout.fileThumbImage
        fileNameLabel?.text = tempLayout.fileName
        fileSizeLabel?.text = tempLayout.fileSize
        bubbleView?.backgroundColor = layout?.bubbleViewBackgroupColor
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tempLayout = layout as! OtherFileLayout
        fileThumbImageView?.frame = tempLayout.fileThumbFrame ?? CGRect.zero
        fileNameLabel?.frame = tempLayout.fileNameFrame ?? CGRect.zero
        fileSizeLabel?.frame = tempLayout.fileSizeFrame ?? CGRect.zero
    }

}
