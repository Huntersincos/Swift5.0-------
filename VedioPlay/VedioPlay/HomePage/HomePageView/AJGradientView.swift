//
//  AJGradientView.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/17.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class AJGradientView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    /**
     + (Class)layerClass {
         return [CAGradientLayer class];
     }
       open class var layerClass: AnyClass { get }
     */
      
    override class var layerClass: AnyClass{
        // 生成渐变色的类
        return CAGradientLayer.self
    }
     
    func setupCAGradientLayer(_ colors:[Any], _ locations:[NSNumber] )  {
        let gradient:CAGradientLayer? = self.layer as? CAGradientLayer
        //colors自定义渐变色颜色
        gradient?.colors = colors
        // 节点位置
        gradient?.locations = locations 
        
    }

}
