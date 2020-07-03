//
//  AJPhotoListCellTapView.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class AJPhotoListCellTapView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var  _selected:Bool?
    var  _disabled:Bool?
    var  checkedIcon:UIImage?
    var  selectedColor:UIColor?
    var  disabledColor:UIColor?
    var  selectIcon:UIImageView?
    /**
         在swift4.0废弃了 initialize  load也抛用
     */
//    override class func initialize() {
//
//    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        checkedIcon = UIImage(named: "ic_pic_choose")
        selectedColor = UIColor(white: 1, alpha: 0.3)
        disabledColor = UIColor(white: 1, alpha: 0.8)
        backgroundColor = UIColor.clear
        clipsToBounds = true
        selectIcon = UIImageView.init(frame: CGRect(x: frame.size.width - checkedIcon!.size.width - 5, y: frame.size.height-checkedIcon!.size.height - 5, width: checkedIcon!.size.width, height: checkedIcon!.size.height))
        self.addSubview(selectIcon!)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
       // super.init(coder:coder)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //next 传递事件,在交互上可以代替block和delegate 在自定义cell上最为突出
        // UIResponder响应者链:事件传递:UIApplication  ---UIWindow ---- view (在传给view之前 UIWindow会传给GestureRecognizer 如果手势识别了该事件 则不传给uiview Target(ViewController)进行处理。) -->supviews
        
        self.next?.touchesEnded(touches, with: event)
        // 强制转化 可能有风险
        self .touchAnimation(touches as NSSet)
    }
    
    func touchAnimation(_ touches:NSSet)  {
        let touch:UITouch? = touches.anyObject() as? UITouch
        let clickPoint:CGPoint? =  touch?.location(in: self)
        let clickLayer  = CALayer.init()
        clickLayer.backgroundColor = UIColor.white.cgColor
        clickLayer.masksToBounds = true
        clickLayer.cornerRadius = 3
        clickLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 6)
        clickLayer.position = clickPoint!
        clickLayer.opacity = 0.3
        clickLayer.name = "clickLayer"
        self.layer .addSublayer(clickLayer)
        //「基础动画」「阴影」「旋转」「scale」 CABasicAnimation
        let zoom:CABasicAnimation? = CABasicAnimation.init(keyPath: "transform.scale")
        //指定动画的结束值
        zoom?.toValue = 38.0
        //指定动画开始值
        //zoom?.fromValue = 0;
        zoom?.duration = 0.5
        
        let fadeout:CABasicAnimation? = CABasicAnimation.init(keyPath: "opacity")
        fadeout?.toValue = 0.0
        fadeout?.duration = 0.4
        // 动画组
        let group:CAAnimationGroup? = CAAnimationGroup.init()
        group?.duration = 0.4
        group?.animations = [zoom!,fadeout!]
        //forwards:动画结束后，图层保持toValue状态 backwards:动画前，图层一直保持fromValue状态 both两者都需要 removed 对图层没有什么影响，动画结束后图层恢复原来的状态 默认值为removed
        group?.fillMode = .forwards
        //当动画完成后自动变回原样
        group?.isRemovedOnCompletion = false;
        clickLayer.add(group!, forKey: "animationKey")
        
    }
    
    func animationDidStop( _ anim:CABasicAnimation, flag:Bool) {
        
        if flag{
            for layer:CALayer?  in self.layer.sublayers! {
                if layer?.name != nil {
                    if layer?.name == "clickLayer" && layer?.animation(forKey: "animationKey") == anim {
                        layer?.removeFromSuperlayer()
                    }
                }
            }
            
        }
        
        
    }
   // disabled set方法
    var disabled:Bool?{
        set{
            _disabled = newValue
            if _disabled == nil {
                self.backgroundColor = disabledColor
            }else{
                self.backgroundColor = .clear
            }
        }
        get{
            return _disabled
        }
        
    }
    var selected:Bool?{
        set{
            if _disabled == nil {
                self.backgroundColor = disabledColor
                self.selectIcon?.image = nil
            }else{
                _selected = newValue
                if _selected! {
                    self.backgroundColor = selectedColor
                    self.selectIcon?.image = checkedIcon
                }else{
                    self.backgroundColor = .clear
                    self.selectIcon?.image = nil
                }
            }
            
        }get{
            return _selected
        }
        
    }
    
    
}
