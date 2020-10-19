//
//  RevokeMessageTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class RevokeMessageTableViewCell: UITableViewCell {
    var layout:RevokeLayout?
    var revokeHintLabel:UILabel?
    var message:ChatMessageObject?
    
//    override class func superclass() -> AnyClass? {
//        return RevokeLayout.self
//    }
    
    func configWithLayout(_ layout:RevokeLayout?){
        self.layout = layout
        
        if revokeHintLabel == nil {
           revokeHintLabel = UILabel.init(frame: CGRect.zero)
           revokeHintLabel?.font = TextFont
           revokeHintLabel?.backgroundColor = .clear
           revokeHintLabel?.textAlignment = .center
           revokeHintLabel?.textColor = .white
           revokeHintLabel?.layer.cornerRadius = 10
           revokeHintLabel?.clipsToBounds = true
           self.contentView.addSubview(revokeHintLabel!)
        }
        
        revokeHintLabel?.text = layout?.revokeHintLabelText
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        revokeHintLabel?.frame =  layout?.revokeHintLabelFrame ?? CGRect.zero
        revokeHintLabel?.backgroundColor =  layout?.revokeHintLabelColor
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
