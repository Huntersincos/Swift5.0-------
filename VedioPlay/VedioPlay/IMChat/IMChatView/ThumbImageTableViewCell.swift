//
//  ThumbImageTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class ThumbImageTableViewCell: BaseMessageCellTableViewCell {
   
    var thumbImage:UIImageView?
    var durationLabel:UILabel?
    var playBtn:UIImageView?
    
    override class func superclass() -> AnyClass? {
        
        return ThumbImageLayout.self
    }
    
    override func configWithLayou(_ layout: BaseBubbleLayout?) {
        super.configWithLayou(layout)
        
        if thumbImage == nil {
            thumbImage = UIImageView.init()
            thumbImage?.contentMode = .scaleToFill
            thumbImage?.layer.cornerRadius = 10.0
            thumbImage?.clipsToBounds = true
            msgContentView?.addSubview(thumbImage!)
        }
        
        if durationLabel == nil {
           durationLabel = UILabel.init(frame: CGRect.zero)
           //durationLabel?.font = TextFont
           durationLabel?.backgroundColor = .clear
           durationLabel?.textAlignment = .right
           durationLabel?.textColor = .white
           durationLabel?.backgroundColor = .clear
           msgContentView?.addSubview(durationLabel!)
        }
        
        if playBtn == nil {
            playBtn = UIImageView.init()
            msgContentView?.addSubview(playBtn!)
        }
        
        let tempLayout = layout as! ThumbImageLayout
        playBtn?.isHidden = tempLayout.showPlayBtn ?? true
        playBtn?.image = tempLayout.playBtnImage
        thumbImage?.image = tempLayout.thumbnail
        durationLabel?.isHidden = tempLayout.showDurationLabel ?? true
        durationLabel?.text = tempLayout.durationLabelText
        
        bubbleView?.backgroundColor = layout?.bubbleViewBackgroupColor
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tempLayout = layout as! ThumbImageLayout
        thumbImage?.frame = tempLayout.thumbnailFrame ?? CGRect.zero
        playBtn?.frame = tempLayout.playBtnFrame ?? CGRect.zero
        durationLabel?.frame = tempLayout.durationLabelFrame ?? CGRect.zero
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
