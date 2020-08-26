//
//  SDImageCache.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/25.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit


/// 图片缓存:内存缓存和磁盘缓存
public enum SDImageCacheType:Int{

 /**
  不缓存
  */
  case  SDImageCacheTypeNone
  /**
  磁盘缓存
  */
  case SDImageCacheTypeDisk
  /**
   内存缓存
   */
  case SDImageCacheTypeMemory
    
}

typealias SDWebImageQueryCompletedBlock = (_ image:UIImage,_ cacheType:SDImageCacheType) ->Void
typealias SDWebImageCheckCacheCompletionBlock = (_ isInCache:Bool) -> Void
typealias SDWebImageCalculateSizeBlock = (_ fileCount:Int, _ totalSize:Int) ->Void
// oc ====> @interface ==== @implementation Swift 实现
extension NSCache{
    
    /// NSCache 1 线程安全 2 当内存缓存不足时,NSCache会自动释放 3 设置缓存缓存对象占用的内存大小,当超过会自动释放
   @objc func recevieCacheWarning(){
     NotificationCenter.default.addObserver(self, selector: #selector(removeAllObjects), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
   }
    // 无法调用
    @objc func relase(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

}

// 1周
private let kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7;
// png bytes
private let kPNGSignatureBytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]

private var kPNGSignatureData:Data?

func ImageDataHasPNGPreffix(_ data:Data) -> Bool {
    guard let pngSignatureLength = kPNGSignatureData?.count else { return false }
    if data.count >= pngSignatureLength {
        let subData = data.subdata(in: 0..<pngSignatureLength)
        if subData == kPNGSignatureData{
            return true
        }
    }
    
    return false
}
//OC中 FOUNDATION_STATIC_INLINE 属于属于runtime范畴，你的.m文件需要频繁调用一个函数,可以用static inline来声明

// line作用 相对于普通函数 没有编译器额外开销 在编译器最终生成没有定义 编译器处理,直接将编译后的函数体插入调用的地方. 限制 1 不能有循环语句  2  不能用过多的判断 3 函数体不能有过于庞大 3 不能对函数取址操作 4 函数声明必须在调用语句之前

/// 计算图片所占内存
/// - Parameter image: 当前图片
 @inline(__always) func SDCacheCostForImage(_ image:UIImage) -> Int{
    return Int(image.size.height * image.size.width * image.scale * image.scale)
}

class SDImageCache: NSObject {
    
    /**
       解压缩图片和下载图片可以提高性能,当时消耗内存大,该属性默认为true
        设置false则可以解决内存过度消耗导致的崩溃
     */
    var shouldDecompressImages:Bool?
    
    /**
       默认yes 静止 iCloud备份
    */
    var shouldDisableiCloud:Bool?
    
    /**
        默认yes  使用内存备份
    */
    var shouldCacheImagesInMemory:Bool?
    
    /**
      内存中保存的总像素数
    */
    var maxMemoryCost:Int?
    
    /**
     内存中缓存对象总数
    */
    var maxMemoryCountLimit:Int?
    
    /**
         缓存大小,单位字节
    */
    var maxCacheAge:Int?
    
    /**
      将图像保存在缓存中的最大时间长度
    */
    var maxCacheSize:Int?
    var memCache:NSCache<AnyObject, AnyObject>?
    var diskCachePath:String?
    var customPaths:NSMutableArray?
    //oc dispatch_queue_t === swift DispatchQueue 队列
    /// 这里不考虑os7以下的MRC
    var ioQueue:DispatchQueue?
    var fileManager:FileManager?
    fileprivate static let  instance = SDImageCache()
    public static var sharedImageCache:SDImageCache{
        get{
            return instance
        }
    }
    
    override convenience init() {
      //  super.init()
        self.init(withNamespace: "default")
    }
    
    
    /// 创建新的空间名称
    /// - Parameter ns: 名称
    convenience init(withNamespace ns:String) {
        //self' used before 'self.init' call or assignment to 'self'
        self.init()
        self.init(withNamespace:ns ,diskCacheDirectory:makeDiskCachePath(fullNamespace: ns))
    }
    
    /// 创建新的缓存空间名称和目录
    /// - Parameters:
    ///   - ns: 名称
    ///   - directory: 目录
    convenience init(withNamespace ns:String,diskCacheDirectory  directory: String?){
        self.init()
        
        let fullNamespace = "com.hackemist.SDWebImageCache.\(ns)"
        kPNGSignatureData = Data.init(bytes: kPNGSignatureBytes, count: 8)
        /**
          线程       队列(任务 异步和同步)
                    串行队列               并发队列               主队列           全局队列:提供了4个全局并发队列  不能创建 只能获取
         异步线程       开启一个子线程    开启多个子线程      对主队列不影响
         同步线程      不开线程                 不开线程             静止这样做,会引起死锁
         
         */
        //默认创建串行队列
        ioQueue = DispatchQueue.init(label: "com.hackemist.SDWebImageCache")
        // 并发队列
       // DispatchQueue.init(label: "com.hackemist.SDWebImageCache", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        maxCacheAge = kDefaultCacheMaxCacheAge
        
        memCache = NSCache.init()
        memCache?.recevieCacheWarning()
        memCache?.name = fullNamespace
        
        if directory != nil{
            diskCachePath = (directory ?? "") + "/\(fullNamespace)"
        }else{
            diskCachePath = makeDiskCachePath(fullNamespace: ns)
        }
        shouldDecompressImages = true
        shouldCacheImagesInMemory = true
        shouldDisableiCloud = true
        ioQueue?.async {
            self.fileManager = FileManager.init()
        }
        
        
    }
    
    func makeDiskCachePath(fullNamespace:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return paths[0] + "/\(fullNamespace)"
    }
    
}
