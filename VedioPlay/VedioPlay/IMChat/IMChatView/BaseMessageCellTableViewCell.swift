//
//  BaseMessageCellTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/15.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

@objc protocol BaseMessageCellTableViewCellDelegate{
    
    @objc optional func tableView(_ tableView:UITableView , tapMessageCellContent message:ChatMessageObject)
    
     @objc optional func tableView(_ tableView:UITableView , tapMessageCellState message:ChatMessageObject)
    
     @objc optional func tableView(_ tableView:UITableView , tapMessageCellAvator message:ChatMessageObject)
    
    @objc optional func tableView(_ tableView:UITableView , revokeMessage message:ChatMessageObject)
    
    @objc optional func tableView(_ tableView:UITableView , acceptExchangeVCard message:ChatMessageObject)
    
    @objc optional func tableView(_ tableView:UITableView , complainMessage message:ChatMessageObject)
    
    @objc optional func tableView(_ tableView:UITableView , sendSMS message:ChatMessageObject)
    
}

class BaseMessageCellTableViewCell: UITableViewCell {
 
    var layout:BaseBubbleLayout?
    var timeLabel:UILabel?
    var avatorImage:UIImageView?
    var bubbleView:UIView?
    var nameLabel:UILabel?
    var stateView:UIImageView?
    var msgContentView:UIView?
    weak var delegate:BaseMessageCellTableViewCellDelegate?
    weak var wTableView:UITableView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = RGBCOLOR(240, 240, 240, 1)
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil
    ///当shouldRasterize设成true时，layer被渲染成一个bitmap，并缓存起来，等下次使用时不会再重新去渲染了。实现圆角本身就是在做颜色混合（blending），如果每次页面出来时都blending，消耗太大，这时shouldRasterize = yes，下次就只是简单的从渲染引擎的cache里读取那张bitmap，节约系统资 来实现组透明的效果，如果它被设置为YES，在应用透明度之前，图层及其子图层都会被整合成一个整体的图片
        
        /// 由于基于Layer的绘制是处理静态的Bitmap的，而bitmap的处理又是GPU所擅长的，所以它的效率要比基于View绘制的高很多，因为基于View绘制的每次都要进行drawRect的调用重新绘制
        ///  为了启用shouldRasterize属性，置了图层的rasterizationScale属性。默认情况下，所有图层拉伸都是1.0， 所以如果使用了shouldRasterize属性，就要确保你设置了rasterizationScale属性去匹配屏幕，以防止出现Retina屏幕像素化的问题。
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    
    }
    
    func configWithLayou(_ layout:BaseBubbleLayout?){
        self.layout = layout
        
        if timeLabel == nil {
            timeLabel = UILabel.init(frame: CGRect.zero)
            timeLabel?.textAlignment = .center
            timeLabel?.backgroundColor =  RGBCOLOR(240, 240, 240, 1)
            timeLabel?.textColor = .gray
            timeLabel?.font = UIFont.systemFont(ofSize: 13)
            contentView.addSubview(timeLabel!)
            
        }
        
        if avatorImage == nil {
            avatorImage = UIImageView.init(frame: CGRect.zero)
            avatorImage?.layer.cornerRadius = AvatorSize/2
            avatorImage?.isUserInteractionEnabled = true
            avatorImage?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapAvator)))
            contentView.addSubview(avatorImage!)
        }
        
        if bubbleView == nil {
            bubbleView = UIView.init(frame: CGRect.zero)
            contentView.addSubview(bubbleView!)
            bubbleView?.layer.cornerRadius = 15
            
        }
        
        
        if nameLabel == nil {
           nameLabel = UILabel.init(frame: CGRect.zero)
           nameLabel?.textAlignment = .center
           nameLabel?.backgroundColor =  RGBCOLOR(240, 240, 240, 1)
           nameLabel?.textColor = .gray
           nameLabel?.font = UIFont.systemFont(ofSize: 13)
           contentView.addSubview(nameLabel!)
                   
        }

        if stateView == nil {
          stateView = UIImageView.init(frame: CGRect.zero)
          stateView?.isUserInteractionEnabled = true
          stateView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapState)))
          contentView.addSubview(stateView!)
        }
        
        if msgContentView == nil {
             msgContentView = UIView.init(frame: CGRect.zero)
             msgContentView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapContent)))
             msgContentView?.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(setupNormalMenuController)))
             contentView.addSubview(msgContentView!)
        }
        
        timeLabel?.isHidden = layout?.showName ?? false
        timeLabel?.text = layout?.timeLabelText
        avatorImage?.image = layout?.avatorViewImage
        
        nameLabel?.isHidden = layout?.showName ?? false
        nameLabel?.textAlignment = layout?.nameLabelTextAlignment ?? .left
        nameLabel?.text = layout?.nameLabelText
        
        stateView?.image =  layout?.stateViewImage
        
        
        
    
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        timeLabel?.frame = layout?.timeLabelFrame ?? CGRect.zero
        nameLabel?.frame = layout?.nameLabelFrame ?? CGRect.zero
        avatorImage?.frame = layout?.avatorViewFrame ?? CGRect.zero
        stateView?.frame = layout?.stateViewFrame ?? CGRect.zero
        bubbleView?.frame = layout?.bubbleViewFrame ?? CGRect.zero
        bubbleView?.backgroundColor = layout?.bubbleViewBackgroupColor
        msgContentView?.frame = layout?.contentViewFrame ?? CGRect.zero
        
    }
    
    
    
    @objc func tapAvator(){
        
        
    }
    
    @objc func tapState(){
        
    }
     
    @objc func tapContent(){
        
    }
    
    @objc func setupNormalMenuController(_ longPressGestureRecognizer:UILongPressGestureRecognizer){
        
        if longPressGestureRecognizer.state == .began {
            super.becomeFirstResponder()
            /// 将self的一快rect转化到 self.bubbleView size不会发生改变 坐标系的位置在self.bubbleView
            let selectedCellMessageBubbleFrame = self.convert(bubbleView?.frame ?? CGRect.zero, to: self.bubbleView)
            
            let menu = UIMenuController.shared
            let deletItem = UIMenuItem.init(title: NSLocalizedString("DELETMESSAGE",tableName: nil, comment: ""), action: #selector(deletedClick))
            let revokeItem = UIMenuItem.init(title: NSLocalizedString("Revoke",tableName: nil, comment: ""), action: #selector(revoke))
            if layout?.message?.state == .MessageItemStateReceiveOK  || layout?.message?.state == .MessageItemStateRead  || layout?.message?.state == .MessageItemStateDelivered{
                menu.menuItems = [revokeItem,deletItem]
            }
            
            if #available(iOS 13.0, *) {
                menu.showMenu(from:  bubbleView ?? UIView.init(), rect: selectedCellMessageBubbleFrame)
            } else {
                // Fallback on earlier versions
                menu.setTargetRect(selectedCellMessageBubbleFrame, in: bubbleView ?? UIView.init())
            }
            
            menu.setMenuVisible(true, animated: true)
        }
        
    }
    
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//
//    }
    
    @objc func deletedClick() {
        
    }
    
    
    @objc func revoke(){
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
