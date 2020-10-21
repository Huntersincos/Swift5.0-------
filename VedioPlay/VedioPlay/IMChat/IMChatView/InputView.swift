//
//  InputView.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/2.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit



@objc protocol InputViewDelegate{
    
    func menuViewHide()
    func menuViewShow()
    func locationBtnClicked()
    func photoBtnClicked()
    func cameraBtnClicked()
    func otherFilesBtnClicked()
    
    func didAtMemberInGroupChat()
    func didBeginEditing()
    func sendMessage(_ message:String?)
    
    func didVoiceRecordBeginRecord(_ button:ChatVoiceRecordButton)
    func didVoiceRecordEndRecord(_ button:ChatVoiceRecordButton, _ duration:Int)
    func didVoiceRecordCancelRecord(_ button:ChatVoiceRecordButton)
    func didVoiceRecordContinueRecord(_ button:ChatVoiceRecordButton)
    func didVoiceRecordWillCancelRecord(_ button:ChatVoiceRecordButton)
    func didVoiceRecordRecordTimeSmall(_ button:ChatVoiceRecordButton)
    func didVoiceRecordRecordTimeBig(_ button:ChatVoiceRecordButton)
}

public let InputHeadViewHeight:CGFloat = 90
public let InputMenuViewHeight:CGFloat = 216
public let  kKeyboardX:CGFloat = 5;
public let  kInputViewMaxHeight:CGFloat = 60

class InputView: UIView,UITextViewDelegate,ChatVoiceRecordButtonDelegate,HBEmojiPageViewDelegate {
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var inputTextView:UITextView?
    var placeHolderLabel:UILabel?
    var audioBtn:UIButton?
    var emojiBtn:UIButton?
    var recordBtn:ChatVoiceRecordButton?
    var locationBtn:UIButton?
    var photoBtn:UIButton?
    var cameraBtn:UIButton?
    var cardBtn:UIButton?
    var otherFileBtn:UIButton?
    var menuView:UIView?
    var emojiPageView:HBEmojiPageView?
    var isMenuViewShow = false
    var isFirstLayout:Bool?
    weak var delegate:InputViewDelegate?
    var headHeight:CGFloat = 0
    var inputViewHeight:CGFloat?
    
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
        isFirstLayout = true
        isMenuViewShow = false
        headHeight = InputHeadViewHeight
    }
    
    func prepareLayout() {
        
        if inputTextView == nil {
            inputTextView = UITextView.init()
            inputTextView?.returnKeyType = .send
            inputTextView?.showsVerticalScrollIndicator = true
            inputTextView?.isScrollEnabled = false
            inputTextView?.font = UIFont.systemFont(ofSize: 16)
            inputTextView?.delegate = self
            inputTextView?.backgroundColor = RGBCOLOR(244, 244, 244, 1.0)
            inputTextView?.layer.cornerRadius = 7
            self.addSubview(inputTextView!)
        }
        
        if placeHolderLabel == nil {
            placeHolderLabel = UILabel.init()
            //1、0<minimumScaleFactor<1时才能达到效果。（字体10，想要最小字体5，设置0.5即可）
            //、另外要设置adjustsFontSizeToFitWidth=YES.
            //、还有需要UIlabel的行数是1的时候才有用,多行的label是不行的
            placeHolderLabel?.adjustsFontSizeToFitWidth = true
            placeHolderLabel?.font = UIFont.systemFont(ofSize: 16)
            placeHolderLabel?.minimumScaleFactor = 0.9
            placeHolderLabel?.textColor = RGBCOLOR(133, 133, 133, 1.0)
            placeHolderLabel?.isUserInteractionEnabled = false
            placeHolderLabel?.text = NSLocalizedString("INPUT_SOMETHING",tableName: nil, comment: "")
            self.addSubview(placeHolderLabel!)
            
        }
        
        if audioBtn == nil{
            audioBtn = UIButton.init(type: .custom)
            audioBtn?.setImage(UIImage.init(named: "btn_voice_nor"), for: .normal)
            audioBtn?.setImage(UIImage.init(named: "btn_voice_pre"), for: .highlighted)
            audioBtn?.addTarget(self, action: #selector(startRecord)
                , for: .touchUpInside)
            self.addSubview(audioBtn!)
        }
        
        if emojiBtn == nil{
           emojiBtn = UIButton.init(type: .custom)
           emojiBtn?.setImage(UIImage.init(named: "btn_smile_nor"), for: .normal)
           emojiBtn?.setImage(UIImage.init(named: "btn_smile_pre"), for: .highlighted)
           emojiBtn?.addTarget(self, action: #selector(showEmoji)
               , for: .touchUpInside)
           self.addSubview(emojiBtn!)
        }
        
        if recordBtn == nil {
            recordBtn = ChatVoiceRecordButton.init(frame: .zero)
            recordBtn?.delegate = self
            recordBtn?.isHidden = true
            self.addSubview(recordBtn ?? UIView.init())
        }
        
        if locationBtn == nil{
           locationBtn = UIButton.init(type: .custom)
           locationBtn?.setImage(UIImage.init(named: "message_location"), for: .normal)
           locationBtn?.setImage(UIImage.init(named: "message_location"), for: .highlighted)
           locationBtn?.addTarget(self, action: #selector(showLacation)
               , for: .touchUpInside)
           self.addSubview(locationBtn!)
        }
        
        if photoBtn == nil{
           photoBtn = UIButton.init(type: .custom)
           photoBtn?.setImage(UIImage.init(named: "message_photo"), for: .normal)
           photoBtn?.setImage(UIImage.init(named: "message_photo"), for: .highlighted)
           photoBtn?.addTarget(self, action: #selector(showPhotos)
               , for: .touchUpInside)
           self.addSubview(photoBtn!)
        }
        
        if cameraBtn == nil{
           cameraBtn = UIButton.init(type: .custom)
           cameraBtn?.setImage(UIImage.init(named: "message_camera"), for: .normal)
           cameraBtn?.setImage(UIImage.init(named: "message_camera"), for: .highlighted)
           cameraBtn?.addTarget(self, action: #selector(showCamera)
               , for: .touchUpInside)
           self.addSubview(cameraBtn!)
        }
        
        if cardBtn == nil{
           cardBtn = UIButton.init(type: .custom)
           cardBtn?.setImage(UIImage.init(named: "message_card"), for: .normal)
           cardBtn?.setImage(UIImage.init(named: "message_card"), for: .highlighted)
           cardBtn?.addTarget(self, action: #selector(showContacts)
              , for: .touchUpInside)
           self.addSubview(cardBtn!)
        }
        
        if otherFileBtn == nil{
           otherFileBtn = UIButton.init(type: .custom)
           otherFileBtn?.setImage(UIImage.init(named: "message_file"), for: .normal)
           otherFileBtn?.setImage(UIImage.init(named: "message_file"), for: .highlighted)
           otherFileBtn?.addTarget(self, action: #selector(showOtherFiles)
              , for: .touchUpInside)
           self.addSubview(otherFileBtn!)
        }
        
        if menuView == nil {
            menuView = UIView.init()
            menuView?.backgroundColor = .white
            self.addSubview(menuView!)
        }
        
        if emojiPageView == nil {
            emojiPageView = HBEmojiPageView.init(frame: .zero)
            emojiPageView?.isHidden = true
            emojiPageView?.delegate = self
            emojiPageView?.frame = .zero
            menuView?.addSubview(emojiPageView!)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isFirstLayout == true {
            inputViewHeight  = InputHeadViewHeight - 9 - 46
            isFirstLayout = false
        }
        
        audioBtn?.frame = CGRect(x: 4, y: self.frame.size.height - InputMenuViewHeight - 48 - 30, width: 30, height: 30)
        
    
        inputTextView?.frame = CGRect(x: (audioBtn?.frame.maxX ?? 0) + 8, y: 9, width: self.frame.size.width - ((audioBtn?.frame.maxX ?? 0) + 56), height: self.frame.size.height-InputMenuViewHeight-55)
        
        placeHolderLabel?.frame = CGRect(x: inputTextView?.frame.minX ?? 0 + kKeyboardX , y: 9, width: inputTextView?.frame.width ?? 0, height: inputTextView?.frame.height ?? 0)
        
        recordBtn?.frame = inputTextView?.frame ?? CGRect.zero
        
        emojiBtn?.frame = CGRect(x: (inputTextView?.frame.maxX ?? 0) + 11, y: audioBtn?.frame.origin.y ?? 0, width: 30, height: 30)
        
        menuView?.frame = CGRect(x: 0, y: self.frame.size.height - InputMenuViewHeight, width: self.frame.size.width, height: InputMenuViewHeight)
        
        emojiPageView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: InputMenuViewHeight)
        
        let  margin = (self.frame.size.width - 40*5)/7.0
        photoBtn?.frame = CGRect(x: margin, y: (inputTextView?.frame.maxY ?? 0) + 3, width: 40, height: 40)
        
        cameraBtn?.frame = CGRect(x: (photoBtn?.frame.maxX ?? 0) + margin, y: photoBtn?.frame.minY ?? 0, width: 40, height: 40)
        
        locationBtn?.frame = CGRect(x: (cameraBtn?.frame.maxX ?? 0)  + margin, y: cameraBtn?.frame.minY ?? 0, width: 40, height: 40)
        
        cardBtn?.frame = CGRect(x: (locationBtn?.frame.maxX ?? 0) + margin, y: locationBtn?.frame.minY ?? 0, width: 40, height: 40)
        
        otherFileBtn?.frame = CGRect(x: (cardBtn?.frame.maxX ?? 0) + margin, y: cardBtn?.frame.minY ?? 0, width: 40, height: 40)
    }
    
    func layout(){
        
        placeHolderLabel?.isHidden = inputTextView?.text.count ?? 0 > 0 ? true : false
        
        /**
          sizeToFit:会计算出最优的 size 而且会改变自己的size
          sizeThatFits:会计算出最优的 size 但是不会改变 自己的 size
         */
      
        let textSize = inputTextView?.sizeThatFits(CGSize(width: inputTextView?.frame.width ?? 0, height: CGFloat(MAXFLOAT)))
        let  offset:CGFloat = 10
        
        /// 有误差 error
        inputTextView?.isScrollEnabled = (textSize?.height ?? 0) > (kInputViewMaxHeight - offset)
        
        var inputFrame = inputTextView?.frame
        
        let minx = min(kInputViewMaxHeight, textSize?.height ?? 0)
        inputFrame?.size.height = CGFloat(max(inputViewHeight ?? 0, minx))
        inputTextView?.frame = inputFrame ?? CGRect.zero
        
        let maxY = self.frame.maxY
        
        var frame = self.frame
        
        frame.size.height = (inputTextView?.frame.height ?? 0) + 53 + InputMenuViewHeight
        frame.origin.y = maxY - frame.size.height
        self.frame = frame
        
        headHeight = self.frame.size.height  -  InputMenuViewHeight
        
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(CGLineCap.square)
        context?.setLineWidth(2.0)
       // context?.setStrokeColor(red: 244.0, green: 74.0, blue: 79.0, alpha: 1.0)
         context?.setStrokeColor(red: 244.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context?.beginPath()
        context?.move(to: CGPoint(x: 5, y: 0))
        context?.addLine(to: CGPoint(x: self.frame.size.width - 10, y: 0))
        context?.strokePath()
         
    }
    
    @objc func startRecord(){
        recordBtn?.isHidden = !(recordBtn?.isHidden ?? false)
        inputTextView?.isHidden = !(recordBtn?.isHidden ?? false)
        placeHolderLabel?.isHidden = !(recordBtn?.isHidden ?? false && inputTextView?.text.count == 0)
        if !(recordBtn?.isHidden ?? false) {
            audioBtn?.setImage(UIImage.init(named: "textNor"), for: .normal)
            audioBtn?.setImage(UIImage.init(named: "btn_voice_pre"), for: .highlighted)
            //回收键盘
            if inputTextView?.isFirstResponder ?? false {
                inputTextView?.resignFirstResponder()
            }
            
            if isMenuViewShow == true {
                self.delegate?.menuViewHide()
            }
        }else{
            audioBtn?.setImage(UIImage.init(named: "btn_voice_nor"), for: .normal)
            audioBtn?.setImage(UIImage.init(named: "btn_voice_pre"), for: .highlighted)
        }
        
    }
    
    @objc func showEmoji(){
        
        if inputTextView?.isFirstResponder ?? false {
            inputTextView?.resignFirstResponder()
        }
        if isMenuViewShow == true {
            self.delegate?.menuViewHide()
            emojiPageView?.isHidden = true
        }else{
            self.delegate?.menuViewShow()
            emojiPageView?.isHidden = false
            if !(recordBtn?.isHidden ?? false) {
                recordBtn?.isHidden = true
                inputTextView?.isHidden = false
                placeHolderLabel?.isHidden = inputTextView?.text.count ?? 0 > 0
                audioBtn?.setImage(UIImage.init(named: "btn_voice_nor"), for: .normal)
                audioBtn?.setImage(UIImage.init(named: "btn_voice_pre"), for: .highlighted)
            }
            
        }
        
    }
    
    @objc func showLacation(){
        self.delegate?.locationBtnClicked()
    }
       
    @objc func showPhotos(){
        self.delegate?.photoBtnClicked()
    }
    
    @objc func showCamera(){
        self.delegate?.cameraBtnClicked()
    }
    
    @objc func showContacts(){
       
    }
    
    @objc func showOtherFiles(){
        delegate?.otherFilesBtnClicked()
    }
    
    
    /// UITextView Delegate
    
    func textViewDidChange(_ textView: UITextView) {
        layout()
        if textView.text.count > 0 {
            let contentText:NSString = textView.text as NSString
            let lastChar = contentText.substring(from: textView.text.count - 1)
            if lastChar == "@"{
                self.delegate?.didAtMemberInGroupChat()
            }
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isMenuViewShow = false
        self.delegate?.didBeginEditing()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            self.delegate?.sendMessage(textView.text)
            textView.text = nil
            layout()
            return false
        }
    
        return true
    }
    
    func beginEditing(){
        inputTextView?.becomeFirstResponder()
    }
    
    func addContent(_ content:String){
        inputTextView?.text = (inputTextView?.text ?? "") + content
    }
    
 ///ChatVoiceRecordButtonDelegate
    func voiceRecordBeginRecord(_ button: ChatVoiceRecordButton) {
        self.delegate?.didVoiceRecordBeginRecord(button)
    }
    
    func voiceRecordEndRecord(_ button: ChatVoiceRecordButton, _ duration: Int) {
        self.delegate?.didVoiceRecordEndRecord(button, duration)
    }
    
    func voiceRecordCancelRecord(_ button: ChatVoiceRecordButton) {
        self.delegate?.didVoiceRecordCancelRecord(button)
    }
    
    func voiceRecordContinueRecord(_ button: ChatVoiceRecordButton) {
        self.delegate?.didVoiceRecordContinueRecord(button)
    }
    
    func voiceRecordWillCancelRecord(_ button: ChatVoiceRecordButton) {
        self.delegate?.didVoiceRecordWillCancelRecord(button)
    }
    
    func voiceRecordRecordTimeSmall(_ button: ChatVoiceRecordButton) {
        self.delegate?.didVoiceRecordRecordTimeSmall(button)
    }
    
    func voiceRecordRecordTimeBig(_ button: ChatVoiceRecordButton) {
        self.delegate?.didVoiceRecordRecordTimeBig(button)
    }
    
    /// HBEmotion Delegate
    func emojiPageView(_ emojiPageView: HBEmojiPageView!, iconClick iconString: String!) {
        let faceString:NSMutableString = NSMutableString.init(string: inputTextView?.text ?? "")
        faceString.append(iconString)
        inputTextView?.text = faceString as String
        layout()
        inputTextView?.scrollRangeToVisible(NSRange.init(location: (inputTextView?.text.count ?? 0) - 1, length: 1))
    }
    
    func emojiPageViewDeleteClick(_ emojiPageView: HBEmojiPageView!, actionBlock block: ((String?) -> String?)!) {
        inputTextView?.text = block(inputTextView?.text)
        layout()
    }
    
    func emojiPageViewSendClick(_ emojiPageView: HBEmojiPageView!) {
        self.delegate?.sendMessage(inputTextView?.text)
        inputTextView?.text = nil
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
