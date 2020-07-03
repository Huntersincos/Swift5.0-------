//
//  JPhotoManger.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/15.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AssetsLibrary

class JPhotoManger: NSObject {
   // 构造单利
    fileprivate static let instacne  = JPhotoManger()
    var selectionFilter:NSPredicate!
    var indexPathsForSelectedItems:NSMutableArray!
    var maximumNumberOfSelection:NSInteger!
    var minimumNumberOfSelection:NSInteger!
    //lazy init 在swift存储属性必须初始化，确认类型，或者用可选类型，总之要确认类型，毕竟swift是类型安全语言，所以swift提出了lazy属性
   // var assets:NSMutableArray!
    
    lazy var assets:NSMutableArray = {
        return NSMutableArray.init()
    }()
    
    /**
       ALAsset 表示一个照片／视频资源实体
       ALAssetRepresentation 表示一个资源的详细信息
       ALAssetsFilter 设置拉取条件（图片？视频？全部？）
       ALAssetsGroup 表示一个相册（照片组）
       ALAssetsLibrary 对相册的实际操作接 在ios9中已经废弃掉了 我们要确保ALAssetsLibrary实例是strong类型的属性或者是单例的。
     */
   // var assetsLibrary:ALAssetsLibrary!
    lazy var assetsLibrary:ALAssetsLibrary = {
        return ALAssetsLibrary.init()
        
    }()
     
    public static var shared:JPhotoManger{
        get{
            return instacne
        }
    }
    
    func clearAll() {
        maximumNumberOfSelection = 9
        minimumNumberOfSelection = 0
        indexPathsForSelectedItems = NSMutableArray.init()
        selectionFilter = NSPredicate(value: true)
    }
    
      //animate(withDuration duration: TimeInterval, animations: @escaping () -> Void)
  //在Swift3中，闭包默认是非逃逸的。在Swift3之前，事情是完全相反的：那时候逃逸闭包是默认的，对于非逃逸闭包，你需要标记@noescaping。Swift3的行为更好。因为它默认是安全的：如果一个函数参数可能导致引用循环，那么它需要被显示地标记出来。@escaping标记可以作为一个警告，来提醒使用这个函数的开发者注意引用关系。非逃逸闭包可用被编译器高度优化，快速的执行路径将被作为基准而使用.
     // @escaping标明这个闭包是会“逃逸”,通俗点说就是这个闭包在函数执行完成之后才被调用
    
    func laodAssetsWithCompleteBlock(succeed:@escaping(Bool) -> Void)  {
        
        let tempList = NSMutableArray.init()
        let listGroupBlock:ALAssetsLibraryGroupsEnumerationResultsBlock? = {
             (group: ALAssetsGroup! ,stop:UnsafeMutablePointer<ObjCBool>!) in
            let assetsFilter:ALAssetsFilter? = ALAssetsFilter.allAssets()
//            if group == nil {
//                return
//            }
            // 不能为空group
            if group != nil {
                 group.setAssetsFilter(assetsFilter)
                  if group.numberOfAssets() > 0 {
                //                group.enumerateAssets { (ALAsset?, <#Int#>, UnsafeMutablePointer<ObjCBool>?) in
                //                    <#code#>
                //                }
                //                group.enumerateAssets { (<#ALAsset?#>, <#Int#>, <#UnsafeMutablePointer<ObjCBool>?#>) in
                //
                //                }
                                //UnsafeMutablePointer Cannot invoke 'enumerateAssets' with an argument list of type解决是加感叹号/?
                group.enumerateAssets{ (result:ALAsset?, index:NSInteger?, stop:UnsafeMutablePointer<ObjCBool>?) in
                    if (result != nil) {
                        tempList.add(result!)
                    }
                }
                
                let reversedArray = tempList.reverseObjectEnumerator().allObjects
                
                self.assets.removeAllObjects()
                self.assets = NSMutableArray.init(array: reversedArray)
                succeed(true)
                    
                }
            }
        
       }
     
        let groupTypes = ALAssetsGroupAll
        assetsLibrary.enumerateGroupsWithTypes(groupTypes, usingBlock: listGroupBlock) { (error:Error?) in
            succeed(false)
            
        }
       
    
}
    
    
    
}
