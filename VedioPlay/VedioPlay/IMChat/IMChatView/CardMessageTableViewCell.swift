//
//  CardMessageTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/19.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class CardMessageTableViewCell: BaseMessageCellTableViewCell {
    
    var vTextView:UITextView?
    var vAcceptButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override class func superclass() -> AnyClass? {
        return CardLayout.self
    }
    
    override func configWithLayou(_ layout: BaseBubbleLayout?) {
        super.configWithLayou(layout)
         
        if vTextView == nil {
            vTextView = UITextView.init(frame: CGRect.zero)
            vTextView?.font = UIFont.systemFont(ofSize: 17)
            vTextView?.isEditable = false
            msgContentView?.addSubview(vTextView!)
        }
        
        if vAcceptButton == nil {
            
            vAcceptButton = UIButton.init(type: .custom)
            vAcceptButton?.setTitleColor(RGBCOLOR(244, 74, 79, 1), for: .normal)
            vAcceptButton?.setTitle(NSLocalizedString("AGREE",tableName: nil, comment: ""), for: .normal)
            vAcceptButton?.layer.borderColor = RGBCOLOR(244, 74, 79, 1).cgColor
            vAcceptButton?.layer.borderWidth = 1
            vAcceptButton?.addTarget(self, action: #selector(accept), for: .touchUpInside)
            msgContentView?.addSubview(vAcceptButton!)
            
        }
        
        
        msgContentView?.layer.borderColor = RGBCOLOR(244, 74, 79, 1).cgColor
        msgContentView?.layer.borderWidth = 1
        
        let tempLayout = layout as! CardLayout
        
       // vTextView?.text = tempLayout.vc
    }
    
    
    @objc func accept(){
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
