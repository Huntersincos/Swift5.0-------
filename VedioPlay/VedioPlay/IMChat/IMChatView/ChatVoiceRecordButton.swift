//
//  ChatVoiceRecordButton.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/9.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

@objc protocol  ChatVoiceRecordButtonDelegate{
    
    func voiceRecordBeginRecord(_ button:ChatVoiceRecordButton)
    func voiceRecordEndRecord(_ button:ChatVoiceRecordButton, _ duration:Int)
    func voiceRecordCancelRecord(_ button:ChatVoiceRecordButton)
    func voiceRecordContinueRecord(_ button:ChatVoiceRecordButton)
    func voiceRecordWillCancelRecord(_ button:ChatVoiceRecordButton)
    func voiceRecordRecordTimeSmall(_ button:ChatVoiceRecordButton)
    func voiceRecordRecordTimeBig(_ button:ChatVoiceRecordButton)

}

class ChatVoiceRecordButton: UIView {
    
    var isRecord:Bool = false
    var cancel:Bool = false
    var time:Timer?
    var second:Int?
    weak var delegate:ChatVoiceRecordButtonDelegate?
    var normalBorderColor:UIColor?
    lazy var styleView:UILabel = {
        let styleLable =  UILabel.init(frame: CGRect(x: 0, y: 0, width:  viewFrame?.size.width ?? 0, height: viewFrame?.size.height ?? 0))
        styleLable.isUserInteractionEnabled = false
        styleLable.textAlignment = .center
        self.addSubview(styleLable)
        return styleLable
    }()
    
    
    var viewFrame:CGRect?
    
   override var frame:CGRect{
       didSet {
          let newFrame = frame
          super.frame = newFrame
          viewFrame = newFrame
         //if styleView != nil {
          styleView.frame = CGRect(x: 0, y: 0, width: viewFrame?.size.width ?? 0, height: viewFrame?.size.height ?? 0)
         //}
          initView()
      }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewFrame = frame
        initView()
    }
    
    func initView(){
        styleView.text =   NSLocalizedString("RECORD_TIPS",tableName: nil, comment: "")
        styleView.textColor = RGBCOLOR(244.0, 74.0, 79.0, 1.0)
        styleView.font = UIFont.systemFont(ofSize: 16)
        styleView.backgroundColor = .clear
        styleView.layer.cornerRadius = 7
        styleView.layer.borderWidth = 0.3
        styleView.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.normalBorderColor = .gray
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRecord == false {
            second = 0
            time = Timer.init(timeInterval: 1, target: self, selector: #selector(timeAction), userInfo: nil, repeats: true)
            isRecord = true
            cancel = false
            styleView.textColor =  RGBCOLOR(230.0, 230.0, 230.0, 0.9)
            styleView.text =   NSLocalizedString("RECORD_COMPLETE",tableName: nil, comment: "")
            styleView.layer.borderColor = self.normalBorderColor?.cgColor
            self.delegate?.voiceRecordBeginRecord(self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRecord == false {
            return
        }
        
        isRecord = false
        if cancel {
            self.delegate?.voiceRecordCancelRecord(self)
            styleView.text =   NSLocalizedString("RECORD_TIPS",tableName: nil, comment: "")
            styleView.textColor = .clear
            styleView.layer.borderColor = self.normalBorderColor?.cgColor
        }else{
            if second ?? 0 <= 1 {
                self.delegate?.voiceRecordRecordTimeSmall(self)
                self.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.styleView.text =   NSLocalizedString("RECORD_TIPS",tableName: nil, comment: "")
                    self.styleView.textColor = .clear
                    self.styleView.layer.borderColor = self.normalBorderColor?.cgColor
                    
                }
            }else{
                self.delegate?.voiceRecordEndRecord(self, second ?? 0)
                styleView.text =   NSLocalizedString("RECORD_TIPS",tableName: nil, comment: "")
                styleView.textColor = .clear
                styleView.layer.borderColor = self.normalBorderColor?.cgColor
            }
        }
        
        time?.invalidate()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouch()
    }
    
    func endTouch(){
        if isRecord == false {
           return
        }
        isRecord = false
        if cancel {
            self.delegate?.voiceRecordCancelRecord(self)
            styleView.text =   NSLocalizedString("RECORD_TIPS",tableName: nil, comment: "")
            styleView.textColor = .clear
            styleView.layer.borderColor = self.normalBorderColor?.cgColor
        }else{
            if second ?? 0 <= 1 {
                self.delegate?.voiceRecordRecordTimeSmall(self)
                self.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.styleView.text =   NSLocalizedString("RECORD_TIPS",tableName: nil, comment: "")
                    self.styleView.textColor = .clear
                    self.styleView.layer.borderColor = self.normalBorderColor?.cgColor
                    
                }
            }else if(second ?? 0 >= 60){
                self.delegate?.voiceRecordRecordTimeBig(self)
                self.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.styleView.text =   NSLocalizedString("RECORD_TIPS",tableName: nil, comment: "")
                    self.styleView.textColor = .clear
                    self.styleView.layer.borderColor = self.normalBorderColor?.cgColor
                    
                }
                
            }else{
                self.delegate?.voiceRecordEndRecord(self, second ?? 0)
                styleView.text =   NSLocalizedString("RECORD_TIPS",tableName: nil, comment: "")
                styleView.textColor = .clear
                styleView.layer.borderColor = self.normalBorderColor?.cgColor
            }
            
        }
        
        time?.invalidate()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = (touches as NSSet ).anyObject() as! UITouch
        let point = touch.location(in: self)
        if point.x < 0 || point.y < 0 || point.x > self.frame.size.width || point.y > self.frame.size.height {
            if cancel == false {
                cancel = true
                self.delegate?.voiceRecordWillCancelRecord(self)
            }
            
        }else{
            if cancel == true {
                cancel = false
                self.delegate?.voiceRecordContinueRecord(self)
            }
        }
    }
    @objc func timeAction(){
        second = (second ?? 0) + 1
        if second ?? 0 > 59 {
            endTouch()
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
