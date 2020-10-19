//
//  LoactionTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class LoactionTableViewCell: BaseMessageCellTableViewCell {
    
    var iconView:UIImageView?
    var titleLabel:UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override class func superclass() -> AnyClass?{
        
        return  LoactionLayout.self
    }
    
    override func configWithLayou(_ layout: BaseBubbleLayout?) {
        super.configWithLayou(layout)
        
        if iconView == nil{
            iconView = UIImageView.init(frame: CGRect.zero)
            iconView?.contentMode = .scaleToFill
            msgContentView?.addSubview(iconView!)
        }
        
        if titleLabel == nil {
            titleLabel = UILabel.init(frame: CGRect.zero)
            titleLabel?.font = TextFont
            titleLabel?.backgroundColor = .clear
            titleLabel?.numberOfLines = 0
            titleLabel?.textAlignment = .center
            titleLabel?.textColor = .gray
            titleLabel?.backgroundColor = .white
            msgContentView?.addSubview(titleLabel!)
        }
        
        let tempLayout = layout as! LoactionLayout
        iconView?.image = tempLayout.iconImage
        titleLabel?.text = tempLayout.titleLabelText
        titleLabel?.textColor = tempLayout.titleLabelTextColor
        
        bubbleView?.backgroundColor = layout?.bubbleViewBackgroupColor
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tempLayout = layout as! LoactionLayout
        iconView?.frame = tempLayout.iconImageFrame ?? CGRect.zero
        titleLabel?.frame = tempLayout.titleLabelFrame ?? CGRect.zero
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
       
        
    }

}
