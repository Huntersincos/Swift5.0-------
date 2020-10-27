//
//  TextMessageTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class TextMessageTableViewCell: BaseMessageCellTableViewCell {

    var contentLabel:UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override class func superclass() -> AnyClass? {
//        return TextLayout.self
//    }
    
    
    override func configWithLayou(_ layout: BaseBubbleLayout?) {
        super.configWithLayou(layout)
        
        if contentLabel == nil {
            contentLabel = UILabel.init(frame: CGRect.zero)
            contentLabel?.font = TextFont()
            contentLabel?.backgroundColor = .clear
            contentLabel?.numberOfLines = 0
            msgContentView?.addSubview(contentLabel!)
        }
        if layout == nil {
            return
        }
        let textLayout = layout as! TextLayout
        
        contentLabel?.text = textLayout.contentLabelText
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if layout != nil {
            let textLayout = layout as! TextLayout
            contentLabel?.textColor = textLayout.contentLabelTextColor
            contentLabel?.frame = textLayout.contentLabelFrame ?? CGRect.zero
        }
       
        
    }
    

}
