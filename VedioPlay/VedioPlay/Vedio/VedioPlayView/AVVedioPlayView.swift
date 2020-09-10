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

protocol BaseViewControllerProtocol {
    func base_SupportedInterfaceOrientations() -> UIInterfaceOrientationMask
}


extension UIViewController:BaseViewControllerProtocol {
    
    
    // 计算属性
//    var km :Double{
//        return 100.0
//    }
    // 构造器
    func vc_interfaceOrientation(_ orientation:UIInterfaceOrientation, _ isForceLandscape:Bool, _ isForcePortrait:Bool) {
        // oc SEL === swfit Selector
//        let  selector = NSSelectorFromString("orientation")
//        // 'NSInvocation' is unavailable in S@objc @objc @objc @objc wift: NSInvocation and related APIs not available
//        //  代替方案 https://stackoverflow.com/questions/24158427/alternative-to-performselector-in-swift/43714950#43714950
//       //perform(selector, with: <#T##Any?#>, afterDelay: <#T##TimeInterval#>, inModes: <#T##[RunLoop.Mode]#>)
//
//        let invocation:NSObject = unsafeBitCast(method_getImplementation(class_getClassMethod(NSClassFromString("NSInvocation"), NSSelectorFromString("invocationWithMethodSignature:"))!),to:(@convention(c)(AnyClass?,Selector,Any?)->Any).self)(NSClassFromString("NSInvocation"),NSSelectorFromString("invocationWithMethodSignature:"),unsafeBitCast(method(for: NSSelectorFromString("methodSignatureForSelector:"))!,to:(@convention(c)(Any?,Selector,Selector)->Any).self)(self,NSSelectorFromString("methodSignatureForSelector:"),selector)) as! NSObject
//
//        unsafeBitCast(class_getMethodImplementation(NSClassFromString("NSInvocation"), NSSelectorFromString("setSelector:")),to:(@convention(c)(Any,Selector,Selector)->Void).self)(invocation,NSSelectorFromString("setSelector:"),selector)
//         var localName = orientation
//
//        withUnsafePointer(to: &localName) { unsafeBitCast(class_getMethodImplementation(NSClassFromString("NSInvocation"), NSSelectorFromString("setArgument:atIndex:")),to:(@convention(c)(Any,Selector,OpaquePointer,NSInteger)->Void).self)(invocation,NSSelectorFromString("setArgument:atIndex:"), OpaquePointer($0),2) }
//        invocation.perform(NSSelectorFromString("invokeWithTarget:"), with: self)
        
      let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
      appdelegate.isForceLandscape = isForceLandscape
      appdelegate.isForcePortrait = isForcePortrait
      _ = appdelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor: view.window)
     // let oriention = UIInterfaceOrientation.landscapeRight // 设置屏幕为横屏
      UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
      UIViewController.attemptRotationToDeviceOrientation()
        
        
        
    }
    
   @objc func base_SupportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.landscapeLeft.rawValue | UIInterfaceOrientationMask.landscapeRight.rawValue | UIInterfaceOrientationMask.portrait.rawValue)
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

class AVVedioPlayView: UIView,VedioPalyTastkDownDelegate {
   
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //autoresizingMask
    // 可变化的 fiexible/fiexible margin
    // 1 flexibleLeftMargin 自动调整与父视图左边距,保持和右边距不变
    // 2 flexibleRightMargin 自动调整与父视图右边距 保持与左视图保持不变
    // 3 flexibleWidthMargin 自动调整宽度,保持左右不变
    // 4 flexibleTopMargrin  自动调整view和父视图的上边距 和底部边距保持不变
    // 5 flexibleBottomMargin 自动调整view和父视图的底部边距 和上边距保持不管
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
    var startVB:Float?
    var startVideoRate:Float?
    var volumeView:MPVolumeView?
    
    /// 音量控制
    var volumeViewSlider:UISlider?
    
    /// 亮度控制
    var brightnessSlider:UISlider?
    
    var progressTap:UITapGestureRecognizer?
    
    var isFinishLoad:Bool?
    var resouerLoader:VedioPalyURLConnection?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        // 解决真机没法播放问题 耳机和模拟器可以播放
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        
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
       // backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
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
        fullBtn?.addTarget(self, action: #selector(fullBtnClick), for: .touchUpInside)
        
        let tureFullBtn = UIButton.init(frame: CGRect(x: (topView?.bounds.size.width ?? 0) - 60, y:0,width: 60, height: 44))
        topView?.addSubview(tureFullBtn)
        tureFullBtn.addTarget(self, action: #selector(fullBtnClick), for: .touchUpInside)
        
        
        // 底部视图
        toolView = UIView.init(frame: CGRect(x: 0, y: frame.size.height - 40, width: frame.size.width, height: 40))
        toolView?.backgroundColor = RGBCOLOR(50, 50, 50, 0.5)
        toolView?.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleTopMargin.rawValue)
        self.addSubview(toolView ?? UIView.init())
        
        playBtn = UIButton.init(frame: CGRect(x: 5, y: 10, width: 20, height: 20))
        playBtn?.isSelected = true
        playBtn?.setImage(UIImage.init(named: "player_play"), for: .normal)
        playBtn?.setImage(UIImage.init(named: "player_pause"), for: .selected)
        
        toolView?.addSubview(playBtn ?? UIView.init())
        playBtn?.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        
        
        let bigPlayBtn = UIButton.init(frame: CGRect(x: 0, y:0,width: 120, height: 40))
        toolView?.addSubview(bigPlayBtn)
        bigPlayBtn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        
        // CGRectGetMaxX == cgrect.maxx
        currentTimeLable = UILabel.init(frame: CGRect(x: (playBtn?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)).maxX, y: 10, width: 40, height: 20))
        currentTimeLable?.text = "00:00"
        currentTimeLable?.textColor = UIColor.white;
        currentTimeLable?.font = UIFont.systemFont(ofSize: 8)
        currentTimeLable?.textAlignment = .center
        toolView?.addSubview(currentTimeLable ?? UIView.init())
        
       
        // 播放进度条
        progressSlider  = UISlider.init(frame: CGRect(x: currentTimeLable?.frame.maxX ?? 0, y: 12.5, width: frame.size.width - (currentTimeLable?.frame.maxX ?? 0) - 40, height: 15))
        progressSlider?.maximumValue = 1.0
        progressSlider?.minimumValue = 0.0
        // 1 实现拖动---停止拖动 --在播放
        progressSlider?.addTarget(self, action: #selector(touchDown), for: .touchDown)
        progressSlider?.addTarget(self, action: #selector(touchChange), for: .valueChanged)
        progressSlider?.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        progressSlider?.addTarget(self, action: #selector(touchUp), for: .touchUpOutside)
        progressSlider?.addTarget(self, action: #selector(touchUp), for: .touchCancel)
        // 点击进度播放 默认不支持点击事件
        progressTap = UITapGestureRecognizer.init(target: self, action: #selector(clickProgressPlay))
        progressSlider?.addGestureRecognizer(progressTap ?? UITapGestureRecognizer.init())
        
        progressSlider?.setThumbImage(UIImage.getRoundImageWithColor(UIColor.white, CGSize(width: 15, height: 15)), for: .normal)
        progressSlider?.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        toolView?.addSubview(progressSlider ?? UIView.init())
        
      
        
       
       totalTimeLable = UILabel.init(frame: CGRect(x: progressSlider?.frame.maxX ?? 0, y: 10, width: 40, height: 20))
       totalTimeLable?.text = "00:00"
       totalTimeLable?.textColor = UIColor.white;
       totalTimeLable?.font = UIFont.systemFont(ofSize: 8)
       totalTimeLable?.textAlignment = .center
       totalTimeLable?.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleLeftMargin.rawValue)
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
    
    
    /// 播放url视频 边播边缓存
    /// - Parameter url: <#url description#>
    func playWithUrl(_ url:URL?){
        resouerLoader = VedioPalyURLConnection.init()
        resouerLoader?.downDelegate = self
        if url != nil{
            let playUrl  = resouerLoader?.getSchemeVideoURL(url!) ?? url!
            let videoURLAsset = AVURLAsset.init(url: playUrl, options: nil)
            // 不执行 setDelegate resouerLoader写成存储属性即可
            videoURLAsset.resourceLoader.setDelegate(resouerLoader, queue: DispatchQueue.main)
            let item = MyAVPlayerItem.init(asset: videoURLAsset)
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
            
            //self.setPlayer(self.playView ?? AVPlayer.init())
        }
       
        
    }
    
    
    
    func setPlayer(_ myPlayView:AVPlayer)  {
        //Could not cast value of type 'CALayer' (0x1046e4d60) to 'AVPlayerLayer' (0x1021c8d68). 强制一般不需要 需要重写 verride class var layerClass: AnyClass
        let playerLayer:AVPlayerLayer = self.layer as! AVPlayerLayer
        playerLayer.player = myPlayView
//        let avPlayer =  AVPlayerLayer.init(player: myPlayView)
//        avPlayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
//        self.layer.addSublayer(avPlayer)
        
    }
    
    
    override class var layerClass: AnyClass{
        
        return AVPlayerLayer.self
    }
    
//    class func layerClass() -> AnyClass{
//        return AVPlayerLayer.self
//    }
    
    @objc func brightnessChanged(_ slider:UISlider)  {
        UIScreen.main.brightness = CGFloat(slider.value)
    }
    
    @objc func goBack(){
        if fullBtn?.isSelected ?? false {
            //fullBtnClick()
         
            if self.viewViewController().isKind(of: UIViewController.self) {
                  let currentVC:UIViewController = self.viewViewController() as! UIViewController
                   currentVC.vc_interfaceOrientation(UIInterfaceOrientation.portrait,false,true)
             }
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
        var isForceLandscape = false
        var isForcePortrait = true
        if fullBtn?.isSelected == false {
            orientation = UIInterfaceOrientation.landscapeRight
            isForceLandscape = true
            isForcePortrait = false
        }
        
        if self.viewViewController().isKind(of: UIViewController.self) {
           let currentVC:UIViewController = self.viewViewController() as! UIViewController
            currentVC.vc_interfaceOrientation(orientation,isForceLandscape,isForcePortrait)
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
        progressTap?.isEnabled = false
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
        progressTap?.isEnabled = true
        play()
    }
    
    
    @objc func tapClick(_ gestureRecognizer:(UIGestureRecognizer)){
        
        UIView.animate(withDuration: 0.5) {
            self.topView?.isHidden = !(self.topView?.isHidden ?? false)
            self.toolView?.isHidden = !(self.toolView?.isHidden ?? false)
        
        }
       
    }
    
    @objc func clickProgressPlay(_ gestureRecognizer:(UIGestureRecognizer)){
        
        let touchPonint = gestureRecognizer.location(in: progressSlider)
        //The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions 编译器无法推断类型 会报错
        //let value = (progressSlider?.maximumValue - progressSlider?.minimumValue) * (touchPonint.x / progressSlider?.frame.size.height)
        
        let subMum = Float(progressSlider?.maximumValue ?? 0) - (progressSlider?.minimumValue ?? 0)
        let totalX:Float = Float(touchPonint.x / (progressSlider?.frame.size.width ?? 1));
        let value = subMum * totalX
        
        progressSlider?.setValue(value, animated: true)
        
        if (self.playView != nil) {
           let dur = playView?.currentItem?.duration
           let current = progressSlider?.value
           currentTimeLable?.text = getTime(NSInteger((current ?? 0) * (totoalDurtime ?? 0)))
           playView?.seek(to: CMTimeMultiplyByFloat64(dur ?? CMTime.init(), multiplier: Float64(current ?? 0)))
        }
        
    }
    
    
    
    @objc func applicationWillResignActive(_ notification:Notification){
        
        pause()
    }
    
    
    @objc func moviePlayDidEnd(_ notification:Notification){
        
        
    }
    
    @objc func movieInterruption(_ notification:Notification){
           
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interuptionType = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if interuptionType == .began {
            pause()
        }
        guard let reaso =  userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
        //AVAudioSessionInterruptionOptionShouldResume
        let  interruptionOption = AVAudioSession.InterruptionOptions(rawValue: reaso)
        if interruptionOption == .shouldResume {
            play()
        }
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = UIScreen.main.bounds
        fullBtn?.isSelected = UIScreen.main.bounds.width/UIScreen.main.bounds.height > 1
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch:UITouch = (touches as NSSet ).anyObject() as! UITouch
        let point = touch.location(in: self)
        self.direction =  .DirectionNone
        self.startPoint = point
        if self.startPoint?.x ?? 0 <= self.bounds.size.width/2.0 {
            self.startVB = Float(UIScreen.main.brightness)
        }else{
            self.startVB = self.volumeViewSlider?.value ?? 0.0
            
        }
        let ctime = self.playView?.currentTime()
        //Binary operator '/' cannot be applied to operands of type 'CMTimeValue?' (aka 'Optional<Int64>') and 'CMTimeScale?' (aka 'Optional<Int32>')
        // timescale 表示1秒被分成多少份 建议使用 timscale为600
        
       // CMTimeMakeWithSeconds(1,3)
        let value:Int64 = Int64(ctime?.value ?? 0)
        let timescale:Int64 =  Int64(ctime?.timescale ?? 1)
        //let totlaTime = Int32(totoalDurtime ?? 1) 这个转化可能有问题
        self.startVideoRate = Float(value / timescale) / (totoalDurtime ?? 1.0)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch:UITouch = (touches as NSSet ).anyObject() as! UITouch
        let point = touch.location(in: self)
        let panPoint =  CGPoint.init(x: point.x - (self.startPoint?.x ?? 0.0), y: point.y - (self.startPoint?.y ?? 0.0))
        if self.direction == .DirectionNone {
            if abs(panPoint.x) >= 30 {
                pause()
                self.direction = .DirectionScrollHrizontal
            }else if abs(panPoint.y) >= 30{
                self.direction = .DirectionScrollVertical
            }
            
        }else{
            return
        }
        
        if self.direction == .DirectionScrollHrizontal  {
            let scale = Int(self.totoalDurtime ?? 0) > 180 ? 180/(self.totoalDurtime ?? 1.0) : 1.0
            var rate = (self.startVideoRate ?? 0.0) + Float(panPoint.x/self.bounds.size.width) * scale
            if rate > 1 {
                rate = 1
            }else if rate < 0{
                rate = 0
            }
            self.progressSlider?.value = rate
            guard let dur_Time = self.playView?.currentItem?.duration else { return  }
            self.currentTimeLable?.text = getTime(NSInteger(rate * (self.totoalDurtime ?? 0.0)))
            self.playView?.seek(to: CMTimeMultiplyByFloat64(dur_Time,multiplier: Float64(rate)))
            
        }else if self.direction == .DirectionScrollVertical{
            var value = (self.startVB ?? 0) - Float(panPoint.y/self.bounds.size.height)
            if value > 1 {
                value = 1
            }else if value < 0{
                value = 0
            }
            if self.startPoint?.x ?? 0 <= self.frame.size.width/2.0 {
                self.brightnessSlider?.isHidden = false
                self.brightnessSlider?.value = value
                UIScreen.main.brightness = CGFloat(value)
            }else{
                self.volumeView?.isHidden = false
                self.volumeViewSlider?.value = value
            }
            
            
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if self.direction == .DirectionScrollHrizontal {
            play()
        }else if self.direction == .DirectionScrollVertical{
            self.volumeView?.isHidden = true
            self.brightnessSlider?.isHidden = true
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
      if self.direction == .DirectionScrollHrizontal {
           play()
       }else if self.direction == .DirectionScrollVertical{
           self.volumeView?.isHidden = true
           self.brightnessSlider?.isHidden = true
       }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       let item = object as! AVPlayerItem
       if keyPath == "status"{
          if item.status == .readyToPlay{
            let  currentTime = CMTimeGetSeconds(item.currentTime())
            self.totoalDurtime = Float(CMTimeGetSeconds(item.duration))
            let pro = Float(currentTime)/(self.totoalDurtime ?? 1.0)
            if pro <= 1.0 && pro >= 0.0 {
                self.progressSlider?.value = pro
                self.currentTimeLable?.text = getTime(NSInteger(currentTime))
                self.totalTimeLable?.text = getTime(NSInteger(self.totoalDurtime ?? 0.0))
                
            }
            self.setPlayer(self.playView ?? AVPlayer.init())
            self.playView?.play()
            
          }else if item.status == .failed{
             print("AVPlayerStatusFailed")
            
          }else{
             print("AVPlayerStatusUnknown")
           }
           
       }else if keyPath == "loadedTimeRanges"{
         let loadedTimeRanges = self.playView?.currentItem?.loadedTimeRanges
         let range = loadedTimeRanges?[0].timeRangeValue
         let start = CMTimeGetSeconds(range?.start ?? CMTime.init())
         let duration = CMTimeGetSeconds(range?.duration ?? CMTime.init())
         let timeInterval = start + duration
         let pro = Float(timeInterval)/(self.totoalDurtime ?? 1.0)
         if (pro >= 0.0 && pro <= 1.0) {
            print("缓冲进度\(pro)")
         }
        
        
       }
        
  }
    
    func didFinishLoadingWithTask(_ task: VedioRequsetTask) {
        isFinishLoad = task.isFinishLoad
         play()
        
    }
       
   func didFailLoadingWithTask(_ task: VedioRequsetTask, errorCode: Int) {
       
   }
    
    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playView?.removeTimeObserver(playTimeObserver ?? "")
        playView?.currentItem?.removeObserver(self, forKeyPath: "status")
        playView?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        NotificationCenter.default.removeObserver(self)
    }


}
