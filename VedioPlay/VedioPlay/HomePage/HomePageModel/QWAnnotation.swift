//
//  QWAnnotation.swift
//  VedioPlay
//
//  Created by wenze on 2020/7/31.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import MapKit
//import CoreLocation
// @objc 用来暴露接口给OC的运行时,添加@objc修饰符并不意味着这个方法或者属性会采用 Objective-C 的方式变成动态派发，Swift 依然可能会将其优化为静态调用

// @objcMembers:Swift4 后继承自NSObject的类不再隐式添加@objc关键字，但在某些情况下非常依赖 Objective-C 的运行时（如 XCTest） 所以在 Swift4 中提供了@objcMembers关键字，对类和子类、扩展和子类扩展重新启用@objc推断

// @nonobjc

//dynamic
//@objcMembers
class QWAnnotation: NSObject,MKAnnotation {
     //Non-'@objc' property 'coordinate' does not satisfy requirement of '@objc' protocol 'MKAnnotation'
    var coordinate: CLLocationCoordinate2D =  CLLocationCoordinate2DMake(0, 0)
    
    var title: String?

    var subtitle: String?
    /// 地图监听区域
    var region:CLCircularRegion?
    /// 设置图片距离
    var _radius:CLLocationDistance?
    
    // 遍历构造器
    convenience init(_ newRegion:CLCircularRegion,_ title:String,_ subtitle:String){
        self.init()
        region = newRegion
        coordinate = region?.center ?? CLLocationCoordinate2DMake(0, 0)
        radius = region?.radius
        self.title = title
        self.subtitle = subtitle
    
    }
    
    var radius:CLLocationDistance?{
        
        set{
            self.willChangeValue(forKey: "subtitle")
             _radius = newValue
             self.didChangeValue(forKey:  "subtitle")
        }
        get{
           
            return _radius
        }
    }
    
    deinit {
        region = nil
        title = nil
        subtitle = nil
        
    }
    
   

}
