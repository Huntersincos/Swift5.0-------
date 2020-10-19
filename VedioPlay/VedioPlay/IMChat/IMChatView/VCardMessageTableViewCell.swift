//
//  VCardMessageTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class VCardMessageTableViewCell: BaseMessageCellTableViewCell {

    var vIconImageView:UIImageView?
    var vNameLabel:UILabel?
    var vNumberLabel:UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
      override class func superclass() -> AnyClass? {
           
           return CardLayout.self
       }
       
       override func configWithLayou(_ layout: BaseBubbleLayout?) {
           super.configWithLayou(layout)
           
           if vIconImageView == nil {
               vIconImageView = UIImageView.init()
               vIconImageView?.contentMode = .scaleToFill
               vIconImageView?.isUserInteractionEnabled = true
               msgContentView?.addSubview(vIconImageView!)
           }
           
           if vNameLabel == nil {
              vNameLabel = UILabel.init(frame: CGRect.zero)
              //durationLabel?.font = TextFont
              vNameLabel?.backgroundColor = .clear
              vNameLabel?.textAlignment = .center
              vNameLabel?.textColor = .black
              msgContentView?.addSubview(vNameLabel!)
           }
           
          if vNumberLabel == nil {
                vNumberLabel = UILabel.init(frame: CGRect.zero)
                //durationLabel?.font = TextFont
                vNumberLabel?.backgroundColor = .clear
                vNumberLabel?.textAlignment = .center
                vNumberLabel?.textColor = .gray
                msgContentView?.addSubview(vNumberLabel!)
            }
           
           
           let tempLayout = layout as! CardLayout
           vIconImageView?.image = tempLayout.vIconImage
           vNameLabel?.text = tempLayout.vName
           vNumberLabel?.text = tempLayout.vNumber
           bubbleView?.backgroundColor = layout?.bubbleViewBackgroupColor
           
           
       }
       
       override func layoutSubviews() {
           super.layoutSubviews()
           
           let tempLayout = layout as! CardLayout
           vIconImageView?.frame = tempLayout.vIconFrame ?? CGRect.zero
           vNameLabel?.frame = tempLayout.vNameLabelFrame ?? CGRect.zero
           vNumberLabel?.frame = tempLayout.vNumberLabelFrame ?? CGRect.zero
       }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
