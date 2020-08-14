//
//  AVVedioPlayView.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/10.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

// 扩展
// 1 添加计算属性 // 2 实例方法 类型方法 3 提供新的便利构造器 4 定义下标 5 定义和使用新的嵌套类型  6 协议
// 扩展可以向类添加新的便利构造器，但是它们不能向类添加新的指定构造器或析构器。指定构造器或析构器必须始终由原始类实现提供。


extension UIViewController {
    // 计算属性
//    var km :Double{
//        return 100.0
//    }
    // 构造器的个
    func vc_interfaceOrientation(_ orientation:UIInterfaceOrientation) {
        // oc SEL === swfit Selector
        let  selector = NSSelectorFromString("setOrientation:")
        // 'NSInvocation' is unavailable in Swift: NSInvocation and related APIs not available
        //  代替方案 https://stackoverflow.com/questions/24158427/alternative-to-performselector-in-swift/43714950#43714950
       //perform(selector, with: <#T##Any?#>, afterDelay: <#T##TimeInterval#>, inModes: <#T##[RunLoop.Mode]#>)
        
        let invocation:NSObject = unsafeBitCast(method_getImplementation(class_getClassMethod(NSClassFromString("NSInvocation"), NSSelectorFromString("invocationWithMethodSignature:"))!),to:(@convention(c)(AnyClass?,Selector,Any?)->Any).self)(NSClassFromString("NSInvocation"),NSSelectorFromString("invocationWithMethodSignature:"),unsafeBitCast(method(for: NSSelectorFromString("methodSignatureForSelector:"))!,to:(@convention(c)(Any?,Selector,Selector)->Any).self)(self,NSSelectorFromString("methodSignatureForSelector:"),selector)) as! NSObject
        
        unsafeBitCast(class_getMethodImplementation(NSClassFromString("NSInvocation"), NSSelectorFromString("setSelector:")),to:(@convention(c)(Any,Selector,Selector)->Void).self)(invocation,NSSelectorFromString("setSelector:"),selector)
         var localName = orientation
        
        withUnsafePointer(to: &localName) { unsafeBitCast(class_getMethodImplementation(NSClassFromString("NSInvocation"), NSSelectorFromString("setArgument:atIndex:")),to:(@convention(c)(Any,Selector,OpaquePointer,NSInteger)->Void).self)(invocation,NSSelectorFromString("setArgument:atIndex:"), OpaquePointer($0),2) }
        invocation.perform(NSSelectorFromString("invokeWithTarget:"), with: self)
        
    }
    
    
    
}

extension UIImage {
    class  func getRoundImageWithColor(_ color:UIColor, _ size:CGSize) -> UIImage{
        
        UIGraphicsBeginImageContext(CGRect(x: 0, y: 0, width: size.width, height: size.height).size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let imageContext = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageContext ?? UIImage.init()
    }
    
    
    
}

extension AVVedioPlayView{
    func viewViewController() -> AnyObject {
        //事件传递
        // do-- while 和 while 区别 1  循环次数do-while至少执行一次循环体 ,优先操作不同 do-while先判断循环体 在判断条件  2 do-while 不能用break终止 3 do-while在swif5.0中无法使用 可考虑用repeat -- while
        var responder = self.next
        repeat{
            if  responder?.isKind(of: UIViewController.self) ?? false {
                return responder ?? UIViewController.init()
            }
            responder = responder?.next
        }while (responder != nil)
        
        return NSObject.init()
    
    }
    
    
}
 


public enum DirectionDevice:NSInteger{
   case DirectionNone
   case DirectionScrollHrizontal   //水平方向滑动
   case DirectionScrollVertical   //垂直方向滑动
}

class AVVedioPlayView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var topView:UIView?
    var toolView:UIView?
    var playView:AVPlayer?
    var progressSlider:UISlider?
    var currentTimeLable:UILabel?
    var totalTimeLable:UILabel?
    var playBtn:UIButton?
    var fullBtn:UIButton?
    var playTimeObserver:Any?
    
    /// 视频总时长
    var totoalDurtime:Float?
    var direction:DirectionDevice?
    var startPoint:CGPoint?
    var startVB:CGFloat?
    var startVideoRate:CGFloat?
    var volumeView:MPVolumeView?
    
    /// 音量控制
    var volumeViewSlider:UISlider?
    
    /// 亮度控制
    var brightnessSlider:UISlider?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        volumeView = MPVolumeView.init(frame: CGRect(x: frame.size.width - 30, y: (frame.size.height - 100)/2.0, width: 20, height: 100))
        // transform 改变  CGAffineTransformMakeRotation 旋转 "Please use 'Double.pi' or '.pi' to get the value of correct type and avoid casting
        volumeView?.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi * -0.5))
        ///
        volumeView?.showsVolumeSlider = true
        volumeView?.showsRouteButton = false
        for  id in volumeView?.subviews ?? [] {
            let view:UIView = id
            // class 方法用- (Class)class OBJC_SWIFT_UNAVAILABLE("use 'type(of: anObject)' instead");
            if type(of: view).description() == "MPVolumeSlider"{
                volumeViewSlider =  view as? UISlider
                volumeViewSlider?.setThumbImage(UIImage.getRoundImageWithColor(.white, CGSize(width: 10, height: 10)), for: .normal)
                break
            }
        }
        volumeView?.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleLeftMargin.rawValue | UIView.AutoresizingMask.flexibleTopMargin.rawValue | UIView.AutoresizingMask.flexibleBottomMargin.rawValue)
            //| .flexibleTopMargin | .buttom
        volumeView?.isHidden = true
        self.addSubview(volumeView ?? UIView.init())
        
        // 控制亮度
        brightnessSlider = UISlider.init(frame: CGRect(x: 20, y: (frame.size.height - 100)/2, width: 20, height: 100))
        brightnessSlider?.transform =  CGAffineTransform.init(rotationAngle: CGFloat(Double.pi * -0.5))
        brightnessSlider?.setThumbImage(UIImage.getRoundImageWithColor(.white, CGSize(width: 10, height: 10)), for: .normal)
        brightnessSlider?.minimumValue = 0.0
        brightnessSlider?.maximumValue = 1.0
        brightnessSlider?.isHidden = true
        brightnessSlider?.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleRightMargin.rawValue | UIView.AutoresizingMask.flexibleTopMargin.rawValue | UIView.AutoresizingMask.flexibleBottomMargin.rawValue)
        self.addSubview(brightnessSlider ?? UIView.init())
        brightnessSlider?.addTarget(self, action: #selector(brightnessChanged), for: .valueChanged)
        
        
        topView = UIView.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
        topView?.backgroundColor = RGBCOLOR(50, 50, 50,0.5)
        topView?.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleBottomMargin.rawValue | UIView.AutoresizingMask.flexibleWidth.rawValue)
        self.addSubview(topView ?? UIView.init())
        // 返回
        let backBtn = UIButton.init(frame: CGRect(x: 10, y: 15, width: 50, height: 16))
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.setImage(UIImage.init(named: "back_white_small"), for: .normal)
        topView?.addSubview(backBtn)
        
       let tureBackBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
       topView?.addSubview(tureBackBtn)
       tureBackBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
       //全屏按钮
        fullBtn = UIButton.init(frame: CGRect(x: (topView?.bounds.size.width ?? 0) - 50, y: 10, width: 40, height: 25))
        fullBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        fullBtn?.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleLeftMargin.rawValue)
        fullBtn?.layer.masksToBounds = true
        fullBtn?.layer.cornerRadius = 5
        fullBtn?.layer.borderWidth = 0.8
        fullBtn?.layer.borderColor = RGBCOLOR(230, 230, 230, 1).cgColor
        fullBtn?.setTitle("全屏", for: .normal)
        fullBtn?.setTitle("还原", for: .selected)
        fullBtn?.setTitleColor(.white, for: .normal)
        fullBtn?.setTitleColor(.white, for: .selected)
        topView?.addSubview(fullBtn ?? UIView.init())
        
        let tureFullBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        topView?.addSubview(tureFullBtn)
        tureFullBtn.addTarget(self, action: #selector(fullBtnClick), for: .touchUpInside)
        
        
        // 底部视图
        toolView = UIView.init(frame: CGRect(x: 0, y: frame.size.height - 40, width: frame.size.width, height: 40))
        toolView?.backgroundColor = RGBCOLOR(50, 50, 50, 0.5)
        self.addSubview(toolView ?? UIView.init())
        
        playBtn = UIButton.init(frame: CGRect(x: 5, y: 10, width: 20, height: 20))
        playBtn?.isSelected = true
        playBtn?.setImage(UIImage.init(named: "player_play"), for: .normal)
        playBtn?.setImage(UIImage.init(named: "player_pause"), for: .selected)
        toolView?.addSubview(playBtn ?? UIView.init())
        playBtn?.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        // CGRectGetMaxX == cgrect.maxx
        currentTimeLable = UILabel.init(frame: CGRect(x: (playBtn?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)).maxX, y: 10, width: 40, height: 20))
        currentTimeLable?.text = "00:00"
        currentTimeLable?.textColor = UIColor.white;
        currentTimeLable?.font = UIFont.systemFont(ofSize: 8)
        currentTimeLable?.textAlignment = .center
        toolView?.addSubview(currentTimeLable ?? UIView.init())
        
        // 播放进度条
        progressSlider  = UISlider.init(frame: CGRect(x: currentTimeLable?.frame.maxX ?? 0, y: 12.5, width: frame.size.width - (currentTimeLable?.frame.maxX ?? 0), height: 15))
        progressSlider?.maximumValue = 1.0
        progressSlider?.minimumValue = 0.0
        progressSlider?.addTarget(self, action: #selector(touchDown), for: .touchDown)
        progressSlider?.addTarget(self, action: #selector(touchChange), for: .valueChanged)
        progressSlider?.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        progressSlider?.addTarget(self, action: #selector(touchUp), for: .touchUpOutside)
        progressSlider?.addTarget(self, action: #selector(touchUp), for: .touchCancel)
        progressSlider?.setThumbImage(UIImage.getRoundImageWithColor(UIColor.white, CGSize(width: 15, height: 15)), for: .normal)
        progressSlider?.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        toolView?.addSubview(progressSlider ?? UIView.init())
        
       
       totalTimeLable = UILabel.init(frame: CGRect(x: currentTimeLable?.frame.maxX ?? 0, y: 10, width: 40, height: 20))
       totalTimeLable?.text = "00:00"
       totalTimeLable?.textColor = UIColor.white;
       totalTimeLable?.font = UIFont.systemFont(ofSize: 8)
       totalTimeLable?.textAlignment = .center
       totalTimeLable?.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
       toolView?.addSubview(totalTimeLable ?? UIView.init())
        
        // 退到后台
       NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        // 播放结束
       NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        // 播放中断
       NotificationCenter.default.addObserver(self, selector: #selector(movieInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        
    }
    
    func playWith(_ url:URL) {
        
        let assert = AVURLAsset.init(url: url)
        // 通过关键字会将资源异步加载在程序的一个临时内存缓冲区中
        assert.loadValuesAsynchronously(forKeys: ["tracks"]) {
            let status = assert.statusOfValue(forKey: "tracks", error: nil)
            if status == .loaded{
                let item = MyAVPlayerItem.init(asset: assert)
                item.observer = self
                item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                item.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
                if (self.playView != nil) {
                    self.playView?.removeTimeObserver(self.playTimeObserver ?? NSObject())
                    // 替换item
                    self.playView?.replaceCurrentItem(with: item)
                }else{
                    self.playView = AVPlayer.init(playerItem: item)
                }
                
                weak var weakPlayer:AVPlayer? = self.playView
                weak var weakSlider:UISlider? = self.progressSlider
                weak var weakCurrentTime:UILabel? =  self.currentTimeLable
                weak var weakSelf = self
                // 检查播放进度
                self.playTimeObserver = self.playView?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: Int64(1.0), timescale: Int32(1.0)), queue: DispatchQueue.main, using: { (time:CMTime) in
                    let current = CMTimeGetSeconds(weakPlayer?.currentItem?.currentTime() ?? CMTime.init())
                    let pro = current * 1.0/Float64(weakSelf?.totoalDurtime ?? 1)
                    if pro >= 0 && pro <= 1{
                        weakSlider?.value = Float(pro)
                        weakCurrentTime?.text = self.getTime(NSInteger(current))
                    }
                })
                
            }
            
        }
        

    }
    
    
    func setPlayer(_ myPlayView:AVPlayer)  {
        
        let playerLayer:AVPlayerLayer = self.layer as! AVPlayerLayer
        playerLayer.player = myPlayView
        
    }
    
    class func layerClass() -> AnyClass{
        return AVPlayerLayer.self
    }
    
    @objc func brightnessChanged(_ slider:UISlider)  {
        UIScreen.main.brightness = CGFloat(slider.value)
    }
    
    @objc func goBack(){
        if fullBtn?.isSelected ?? false {
            fullBtnClick()
        }else{
            if self.viewViewController().isKind(of: UIViewController.self) {
                let currentVC:UIViewController = self.viewViewController() as! UIViewController
                if currentVC.navigationController?.topViewController == currentVC{
                   self.viewViewController().navigationController?.popViewController(animated: true)
               }else{
                   self.viewViewController().dismiss(animated: true, completion: nil)
               }
            }
    
        }
        
    }
    
    @objc func fullBtnClick(){
        
        var orientation = UIInterfaceOrientation.portrait;
    
        if fullBtn?.isSelected == false {
            orientation = UIInterfaceOrientation.landscapeRight
        }
        
        if self.viewViewController().isKind(of: UIViewController.self) {
           let currentVC:UIViewController = self.viewViewController() as! UIViewController
            currentVC.vc_interfaceOrientation(orientation)
        }
        
    }
    
    @objc func playBtnClick(_ playBtn:UIButton){
        if playBtn.isSelected {
            pause()
        }else{
            play()
        }
    }
    
    
    @objc func touchDown(_ touchDownSlier:UISlider){
        pause()
        
    }
    
    @objc func touchChange(_ touchChangeSlier:UISlider){
        
        if (self.playView != nil) {
            let dur = playView?.currentItem?.duration
            let current = progressSlider?.value
            currentTimeLable?.text = getTime(NSInteger((current ?? 0) * (totoalDurtime ?? 0)))
            playView?.seek(to: CMTimeMultiplyByFloat64(dur ?? CMTime.init(), multiplier: Float64(current ?? 0)))
        }
        
    }
    
    
    @objc func touchUp(_ touchUpSlier:UISlider){
        
        play()
    }
    
    
    @objc func tapClick(_ gestureRecognizer:(UIGestureRecognizer)){
        
        UIView.animate(withDuration: 0.5) {
            self.topView?.isHidden = !(self.topView?.isHidden ?? false)
            self.toolView?.isHidden = !(self.toolView?.isHidden ?? false)
        
        }
       
    }
    
    @objc func applicationWillResignActive(_ notification:Notification){
        
        
    }
    
    
    @objc func moviePlayDidEnd(_ notification:Notification){
        
        
    }
    
    @objc func movieInterruption(_ notification:Notification){
           
           
    }
    
    
    /// 播放
    
    func play(){
        if playView != nil {
            playView?.play()
            playBtn?.isSelected = true
        }
      
    }
    
    
    /// 暂停
    
    func pause(){
        if playView != nil{
            playView?.pause()
            playBtn?.isSelected = false
        }
    }
    
    func getTime(_ second:NSInteger) -> String {
        
        var time:String = "";
        if second < 60{
            time = "00:\(second)"
        }else{
            if second < 3600{
                time = "\(second/60):\(second%60)"
            }else{
                let subTime = (second - second/3600 * 3600)/60
                time = "\(second/3600):\(subTime):\(second%60)"
            }
            
        }
    
        return time
        
    }
    
    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
    }


}
