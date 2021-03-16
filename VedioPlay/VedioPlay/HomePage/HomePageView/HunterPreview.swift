//
//  HunterPreview.swift
//  VedioPlay
//
//  Created by wenze on 2020/11/23.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol HunterPreviewDelegate {
    /// 聚焦
    func tappedToFocusAtPoint(_ point:CGPoint)
    /// 聚光
    func tappedToExposeAtPoint(_ point:CGPoint)
    /// 重置
    func tappedToResetFocusAndExposure()
}

class HunterPreview: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var singleTapRecognizer:UITapGestureRecognizer?
    var doubleTapRecognizer:UITapGestureRecognizer?
    var doubleDoubleTapRecognizer:UITapGestureRecognizer?
    var focusBox:UIView?
    var exposureBox:UIView?
    weak var delegate:HunterPreviewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        creatView()
    }
    
    
    override class var layerClass: AnyClass{
        // 重写layerClass 可以让创建的视图实例在图层下
        return AVCaptureVideoPreviewLayer.self
    }
    var session:AVCaptureSession?{
       
        set{
            let set_previews:AVCaptureVideoPreviewLayer = self.layer as! AVCaptureVideoPreviewLayer
            set_previews.session = newValue
        }
        get{
          // 返回捕捉会话 extends calayer
            let get_preview:AVCaptureVideoPreviewLayer = self.layer as! AVCaptureVideoPreviewLayer
            return get_preview.session;
        }
    }
    
    func creatView() {
        
        let previews:AVCaptureVideoPreviewLayer =  self.layer as! AVCaptureVideoPreviewLayer
        
        previews.videoGravity = .resizeAspectFill
        
        singleTapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleSingleTap))
        
        doubleTapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap))
        /// 双击操作
        doubleTapRecognizer?.numberOfTapsRequired = 2;
        
        doubleDoubleTapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleDoubleTap))
        doubleDoubleTapRecognizer?.numberOfTapsRequired = 2
        /// 手指个数
        doubleDoubleTapRecognizer?.numberOfTouchesRequired = 2
        
        if singleTapRecognizer != nil {
        addGestureRecognizer(singleTapRecognizer!)
        }
        
        if doubleTapRecognizer != nil {
            addGestureRecognizer(doubleTapRecognizer!)
        }
        
        if doubleDoubleTapRecognizer != nil {
            addGestureRecognizer(doubleDoubleTapRecognizer!)
            // 指定一个手势在另外一个手势失败的情况下才执行
            singleTapRecognizer?.require(toFail: doubleTapRecognizer!)
        }
        
        focusBox = viewWithColor(RGBCOLOR(0.102, 0.636, 1.00, 1))
        exposureBox = viewWithColor(RGBCOLOR(1.00, 0.4210,0.054, 1))
        addSubview(focusBox ?? UIView.init())
        addSubview(exposureBox ?? UIView.init())
        
        
    }
    
    
    
    @objc func handleSingleTap(_ gesture:UIGestureRecognizer){
        
        let  point = gesture.location(in: self)
        
        runBoxAnimationOnView(focusBox ?? UIView.init(), point)
        
        self.delegate?.tappedToFocusAtPoint(captureDevicePointForPoint(point))
        
        
        
    }
    
    @objc func handleDoubleTap(_ gesture:UIGestureRecognizer){
        
        let point = gesture.location(in: self)
        
        runBoxAnimationOnView(exposureBox ?? UIView.init(), point)
        
        self.delegate?.tappedToExposeAtPoint(captureDevicePointForPoint(point))
        
    }
    
    @objc func handleDoubleDoubleTap(_ gestrue:UIGestureRecognizer ){
        
    }
    
    
    func runBoxAnimationOnView(_ view:UIView,_ point:CGPoint)  {
        
        view.center = point
        view.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut) {
        
            view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        } completion: { (complete:Bool) in
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                view.isHidden = true
                view.transform =  CGAffineTransform.identity
            }
            
            
        }

        
    }
    
    
    
    
    func viewWithColor(_ color:UIColor) -> UIView {
        
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        view.backgroundColor = .clear;
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 5
        view.isHidden = true
        return view
        
    }
    
    /// 将屏幕上坐标抓换成摄像头上的坐标
    private func captureDevicePointForPoint(_ point:CGPoint) -> CGPoint{
        
        let preview:AVCaptureVideoPreviewLayer =  self.layer as! AVCaptureVideoPreviewLayer
        //return  preview.layerPointConverted(fromCaptureDevicePoint: point)
        return preview.captureDevicePointConverted(fromLayerPoint: point)
    }
    
    
}
