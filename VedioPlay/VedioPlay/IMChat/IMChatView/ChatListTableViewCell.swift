//
//  ChatListTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/30.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var unreadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configWithConversation( _ conversation:ListConversationObject?){
        if conversation?.isGroup ?? false {
            self.iconView.image = UIImage.init(named:"avatar_group")
            
            
        }else{
            self.iconView.image = UIImage.init(named: "img_greenman_nor")
            self.titleLabel.text = conversation?.peerUserName
            if SDWebImageManager.isBlankString(conversation?.conversationTitleName) {
                
                 self.titleLabel.text =  conversation?.conversationTitleName
            }else{
                if conversation?.getAllMessages() == nil {
                    return
                }
                for item in (conversation?.getAllMessages())! {
                    let obj_c =  item.peerUserName
                    self.titleLabel.text  = obj_c
                    break;
                }
                
            }
        
        }
        
        if conversation?.getUnreadCount() == 0 {
            self.unreadLabel.isHidden = true
        }else{
            self.unreadLabel.isHidden = false
            self.unreadLabel.text = "\(conversation?.getUnreadCount() ?? 0)"
        }
        self.unreadLabel.layer.cornerRadius = 10
        // 子视图超出父视图 不显示圆角
        self.unreadLabel.clipsToBounds = true
        
        let updateTime = (conversation?.updateTime ?? "0") as NSString
        
        self.timeLabel.text = MHPrettyDate.prettyDate(from: Date.init(timeIntervalSince1970: updateTime.doubleValue/1000), with: MHPrettyDateFormat.init(rawValue: MHPrettyDateLongRelativeTime.rawValue))
            //conversation?.updateTime
        //if conversation?.getLastMessage() != nil {
        self.contentLabel.text = self.contentWithMessage((conversation?.getLastMessage()))
       // }
       
    }
    
    func contentWithMessage(_ message:ChatMessageObject?) -> String{
        if message == nil {
            return ""
        }
        
        
        if message?.state ==  JRMessageItemState.MessageItemStateRevoked {
            
            return NSLocalizedString("REVOKE_A_MESSAGE",tableName: nil, comment: "")
        }
        /// 群聊使用
        if message?.isAtMsg ?? false {
            
            return NSLocalizedString("BEEN_AT",tableName: nil, comment: "")
        }
        
        switch message?.messageType {
                case .MessageItemTypeUnknow:
                    return NSLocalizedString("MESSAGE_UNKNOW",tableName: nil, comment: "")
                    
                case .MessageItemTypeGeo:
                    return  NSLocalizedString("MESSAGE_LOCATION",tableName: nil, comment: "")
                    
                case .MessageItemTypeAudio:
                    return  NSLocalizedString("MESSAGE_AUDIO",tableName: nil, comment: "")
                    
                case .MessageItemTypeImage:
                     return  NSLocalizedString("MESSAGE_IMAGE",tableName: nil, comment: "")
                    
                case .MessageItemTypeVcard:
            
                   return  NSLocalizedString("MESSAGE_IMAGE",tableName: nil, comment: "")
            
                case .MessageItemTypeVideo:
                    
                    return  NSLocalizedString("MESSAGE_IMAGE",tableName: nil, comment: "")
            
                case .MessageItemTypeText:
                    return  message!.content
            
                case .MessageItemTypeNotify:
                     return  message!.content
             
                case  .MessageItemTypeOtherFile:
                    
                    return  NSLocalizedString("MESSAGE_FILE",tableName: nil, comment: "")
                default:
                    break
        }
        
        return ""
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
