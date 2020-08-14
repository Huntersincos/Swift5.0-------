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
func RGBCOLOR(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ alapha:CGFloat) -> UIColor
{
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: alapha)
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
        self.layer.cornerRadius = 13;
        voiceimage = UIImageView.init(frame: CGRect(x: 60, y: 24, width: 40, height: 63))
        self.addSubview(voiceimage ?? UIView.init())
        
        cancelImage = UIImageView.init(frame: CGRect(x: 60, y: 43, width: 40, height: 63))
        cancelImage?.image = UIImage.init(named: "ic-audio-delete")
        self.addSubview(cancelImage ?? UIView.init())
        cancelImage?.isHidden = true
        
        timeLabel = UILabel.init(frame: CGRect(x: 0, y: 109, width: 160, height: 22))
        timeLabel?.textColor = UIColor.white
        timeLabel?.font = UIFont.systemFont(ofSize: 16)
        timeLabel?.textAlignment = .center
        timeLabel?.backgroundColor = UIColor.clear
        self.addSubview(timeLabel ?? UIView.init())
        
        label = UILabel.init(frame: CGRect(x: 0, y: 135, width: 160, height: 22))
        label?.text = "上滑取消"
        label?.textColor = UIColor.white
        label?.font = UIFont.systemFont(ofSize: 12)
        label?.textAlignment = .center
        label?.backgroundColor = .clear
        self.addSubview(label ?? UIView.init())
        
        progressLeftImage = UIImageView.init(frame: CGRect(x: 15, y: 25, width: 40, height: 63))
        progressLeftImage?.animationDuration = 1.0
        progressLeftImage?.animationRepeatCount = 0
        self.addSubview(progressLeftImage ?? UIView.init())
        
        progressRightImage = UIImageView.init(frame: CGRect(x: 105, y: 25, width: 40, height: 63))
        progressRightImage?.animationDuration = 1.0
        progressRightImage?.animationRepeatCount = 0
        self.addSubview(progressRightImage ?? UIView.init())
    }
    
    
    /// 显示录音
    func show() {
        backgroundColor = RGBCOLOR(73.0, 103, 122,1.0)
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
        backgroundColor = RGBCOLOR(255.0, 59.0, 48.0,1.0)
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
        backgroundColor  = RGBCOLOR(73.0, 103, 122,1.0)
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
        
        backgroundColor = RGBCOLOR(73.0, 103, 122,1.0)
        stopTimer()
        timeLabel?.isHidden = false
        timeLabel?.text  = "说话时间太长"
        label?.isHidden = true
        cancelImage?.isHidden = true
        voiceimage?.isHidden  = false
        progressLeftImage?.isHidden = false
        progressRightImage?.isHidden = false
        // 延迟2秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hide()
        }
        
        
    }
    
    
    /// 录音时间太长
    func recordTimeLong(){
        backgroundColor = RGBCOLOR(73.0, 103, 122,1.0)
      stopTimer()
      timeLabel?.isHidden = false
      timeLabel?.text  = "说话时间太长"
      cancelImage?.isHidden = true
     voiceimage?.isHidden  = false
     progressLeftImage?.isHidden = false
     progressRightImage?.isHidden = false
     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.hide()
     }
      
   }
    
    
    /// 设置音量大小
    /// - Parameter level: 音量大小
    func setStrength(_ level:Int){
        var voimceLevel:Int  = level
        if level > 3 {
            voimceLevel = 3
        }
        let fileLeftName = "ic-audio-animation-left-\(voimceLevel)"
        let fileRightName = "ic-audio-animation-right-\(voimceLevel)"
        progressLeftImage?.image = UIImage.init(named: fileLeftName)
        progressRightImage?.image = UIImage.init(named: fileRightName)
        
    }
    
    func startTimer()  {
        timer = Timer.init(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime( _ timer:Timer) {
        let deltaTime:NSInteger = NSInteger(timer.fireDate.timeIntervalSince((firstFireDate ?? NSDate()) as Date) + 1)
        var time = ""
        if deltaTime < 10 {
            time = "0:0\(deltaTime)"

        }else if(deltaTime < 60){
            time = "0:\(deltaTime)"
        }else{
            let minute = deltaTime/60
            let second = deltaTime - minute * 60
            if second < 10 {
                time =  "\(minute):0\(second)"
            }else{
                time = "\(minute):\(second)"
            }
            
        }
        
        timeLabel?.text = time
    }

    func stopTimer(){
        if self.timer != nil {
            if self.timer?.isValid ?? false {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
        
    }
    
    func setVoiceRecord(){
        backgroundColor = RGBCOLOR(73.0, 103, 122,1.0)
        voiceimage?.image = UIImage.init(named: "ic-audio-record")
        //backgroundColor = RGBCOLOR(r: 73.0, 103, 122)
        progressLeftImage?.animationImages = [(UIImage.init(named: "ic-audio-animation-left-0") ?? UIImage.init()),(UIImage.init(named: "ic-audio-animation-left-1") ?? UIImage.init()),(UIImage.init(named: "ic-audio-animation-left-2") ?? UIImage.init()),(UIImage.init(named: "ic-audio-animation-left-3") ?? UIImage.init())]
        progressLeftImage?.image = UIImage.init(named: "ic-audio-animation-left-3")
        
        progressRightImage?.animationImages = [(UIImage.init(named: "ic-audio-animation-right-0") ?? UIImage.init()),(UIImage.init(named: "ic-audio-animation-right-1") ?? UIImage.init()),(UIImage.init(named: "ic-audio-animation-right-2") ?? UIImage.init()),(UIImage.init(named: "ic-audio-animation-right-3") ?? UIImage.init())]
        progressRightImage?.image = UIImage.init(named: "ic-audio-animation-right-3")
        
        
        
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
