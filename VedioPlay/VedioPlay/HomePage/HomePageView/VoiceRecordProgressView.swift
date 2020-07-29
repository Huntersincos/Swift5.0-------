//
//  VoiceRecordProgressView.swift
//  VedioPlay
//
//  Created by wenze on 2020/7/22.
//  Copyright © 2020 wenze. All rights reserved.
//



import UIKit

//#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1] oc写法

// swift 不支持宏定义语法的
func RGBCOLOR(r:CGFloat,_ g:CGFloat,_ b:CGFloat) -> UIColor
{
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: 1.0)
}


class VoiceRecordProgressView: UIView {
    
    /// <#Description#>
    var label:UILabel?
    
    /// 录音时间
    var timeLabel:UILabel?
    
    var voiceimage:UIImageView?
    
    /// <#Description#>
    var progressLeftImage:UIImageView?
    
    /// <#Description#>
    var progressRightImage:UIImageView?
    
    /// <#Description#>
    var cancelImage:UIImageView?
    
    /// <#Description#>
    var recordAniamtionLeftImageView:UIImageView?
    
    /// <#Description#>
    var recordAniamtionRightImageView:UIImageView?
    
    /// <#Description#>
    var timer:Timer?
    
    /// <#Description#>
    var firstFireDate:NSDate?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5;
        voiceimage = UIImageView.init(frame: <#T##CGRect#>)
        
    }
    
    
    /// 显示录音
    func show() {
        backgroundColor = RGBCOLOR(r: 73.0, 103, 122)
        firstFireDate = NSDate()
        timeLabel?.text = "0.00"
        timeLabel?.isHidden = false
        label?.isHidden = false
        label?.text = "上滑取消"
        cancelImage?.isHidden = true
        voiceimage?.isHidden = false
        progressLeftImage?.isHidden = false
        progressRightImage?.isHidden = false
        progressLeftImage?.startAnimating()
        progressRightImage?.startAnimating()
    }
    
    
    /// 隐藏录音
    func hide() {
        progressRightImage?.stopAnimating()
        progressLeftImage?.stopAnimating()
        self.removeFromSuperview()
        stopTimer()
    }
    
    
    /// 将要隐藏录音
    func willHide(){
        backgroundColor = RGBCOLOR(r: 255.0, 59.0, 48.0)
        timeLabel?.isHidden = true
        label?.text = "松开手指取消发送"
        label?.isHidden = false
        cancelImage?.isHidden = false
        voiceimage?.isHidden = true
        progressRightImage?.isHidden = true
        progressLeftImage?.isHidden = true
    }
    
    
    /// 已经录音
    func didShow(){
        backgroundColor  = RGBCOLOR(r: 73.0, 103, 122)
        timeLabel?.isHidden = false
        label?.isHidden = false
        label?.text = "上滑取消"
        cancelImage?.isHidden = true
        voiceimage?.isHidden = false
        progressRightImage?.isHidden = false
        progressLeftImage?.isHighlighted = false
        
    }
    
    
    
    /// 录音时间太短
    func recordTimeSmall(){
        
        backgroundColor = RGBCOLOR(r: 73.0, 103, 122)
        stopTimer()
        timeLabel?.isHidden = false
        timeLabel?.text  = "说话时间太长"
        label?.isHidden = true
        cancelImage?.isHidden = true
        voiceimage?.isHidden  = false
        progressLeftImage?.isHidden = false
        progressRightImage?.isHidden = false
        
        
        
        
    }
    
    func stopTimer(){
        if self.timer != nil {
            if self.timer?.isValid ?? false {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
   

}
