//
//  AudioMessageTableViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AVFoundation
class AudioMessageTableViewCell: BaseMessageCellTableViewCell,AudioPlayHelperDelegate {
    
    

    var  messageVoiceAniamtionImageView:UIImageView?
    var voiceDurationLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override class func superclass() -> AnyClass? {
        return AudioLayout.self
    }
    
    override func configWithLayou(_ layout: BaseBubbleLayout?) {
        
        super.configWithLayou(layout)
        
        if messageVoiceAniamtionImageView == nil{
           messageVoiceAniamtionImageView = UIImageView.init(frame: CGRect.zero)
           messageVoiceAniamtionImageView?.contentMode = .scaleToFill
            messageVoiceAniamtionImageView?.isUserInteractionEnabled = true
           msgContentView?.addSubview(messageVoiceAniamtionImageView!)
        }
               
       if voiceDurationLabel == nil {
           voiceDurationLabel = UILabel.init(frame: CGRect.zero)
           voiceDurationLabel?.font = TextFont()
           voiceDurationLabel?.backgroundColor = .clear
           msgContentView?.addSubview(voiceDurationLabel!)
       }
        
        if layout?.message?.state == .MessageItemStateReceiveOK || layout?.message?.messageTranDirection == .MessagirectionSend{
            msgContentView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(playAudio)))
        }
        
        let  tempLayout = layout as! AudioLayout
        voiceDurationLabel?.textAlignment = tempLayout.durationLabelAligment ?? .left
        voiceDurationLabel?.text = tempLayout.durationLabelText
        voiceDurationLabel?.textColor = tempLayout.durationLabelTextColor
        
        messageVoiceAniamtionImageView?.image = tempLayout.audioImage
        messageVoiceAniamtionImageView?.animationImages = tempLayout.animationImages
        messageVoiceAniamtionImageView?.animationDuration  = 1.0
        messageVoiceAniamtionImageView?.stopAnimating()
        
    
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let  tempLayout = layout as! AudioLayout
        voiceDurationLabel?.frame = tempLayout.durationLabelFrame ?? CGRect.zero
        messageVoiceAniamtionImageView?.frame = tempLayout.imageViewFrame ?? CGRect.zero
        
    }
    
    @objc func playAudio(){
        
        AudioPlayHelper.shareInstance.delegate = self
        
        if layout?.message?.state == .MessageItemStateReceiveOK || layout?.message?.messageTranDirection == .MessagirectionSend {
            
            if AudioPlayHelper.shareInstance.filePath == JRFileUtil.getAbsolutePathWithFileRelativePath(layout?.message?.filePath ?? "") && AudioPlayHelper.shareInstance.isPlaying ?? false {
                AudioPlayHelper.shareInstance.stopAudio()
            }else{
                AudioPlayHelper.shareInstance.stopAudio()
            AudioPlayHelper.shareInstance.playAudioWithFilePath(JRFileUtil.getAbsolutePathWithFileRelativePath(layout?.message?.filePath ?? ""))
                
            }
        }
        
    }
    
    func audioPlayerDidBeginPlay(_ audioPlay: AVAudioPlayer) {
        messageVoiceAniamtionImageView?.startAnimating()
    }
    
    func audioPlayerDidStopPlay(_ audioPlay: AVAudioPlayer) {
        messageVoiceAniamtionImageView?.stopAnimating()
    }
    
    func audioPlayerDidPausePlay(_ audioPlay: AVAudioPlayer) {
        messageVoiceAniamtionImageView?.stopAnimating()
    }
    
    func startAniamtion(){
        messageVoiceAniamtionImageView?.startAnimating()
    }
    
    func stopAniamtion(){
        messageVoiceAniamtionImageView?.stopAnimating()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
