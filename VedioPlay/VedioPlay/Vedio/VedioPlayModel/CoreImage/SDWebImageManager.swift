//
//  SDWebImageManager.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/24.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

/**
 SDWebImageManager:是图片下载和缓存管理类
 */

/// 可以考虑使用结构器 枚举无法进行位运算
//public struct SDWebImageOptions{
//    /**
//     默认情况下,当一个URL下载失败的时候,这个URL列入黑名单列表,下载再有这个url,就会停止请求
//    */
//    var SDWebImageRetryFailed = 1 << 0
//
//    /**
//       在默认情况下,当UI交互时候开始加载图片,这个标记可以组织这个中加载,这个值可以阻止这种情况加载,比如会导致UIScrollView下载延迟
//
//        */
//       var SDWebImageLowPriority = 1 << 1
//
//       /**
//          静止在磁盘缓存
//        */
//
//       var SDWebImageCacheMemoryOnly  =  1 << 2
//
//       /**
//         图片在加载中展示....... 默认情况是图片加载完成在请求
//        */
//
//       var SDWebImageProgressiveDownload = 1 << 3
//
//       /**
//           忽略缓存,通过HTTP缓存策略,还要加载图片
//           专门用来处理rul地址不变,,但是url图片改变的情况
//           这个情况,缓存由NSURLCache处理
//           如果一个缓存图片更新了，则completion这个回调会被调用两次，一次返回缓存图片，一次返回最终图片。
//           只有在不能确保URL和他对应的内容不能完全对应的时候才使用这个标记
//        */
//
//       var SDWebImageRefreshCached  = 1 << 4
//
//       /**
//           当app推出后台,则继续下载图片,下载的时间由系统分配,如果超时,则下载失败
//        */
//       var SDWebImageContinueInBackground = 1 << 5
//
//       /**
//           存储缓存在"NSHTTPCookie"的cookie
//        */
//       var SDWebImageHandleCookies = 1 << 6
//
//       /**
//          允许非认证的SSL证书加载
//        */
//
//       var SDWebImageAllowInvalidSSLCertificates = 1 << 7
//
//       /**
//           优先加载图片,默认是按照队列顺序加载图片
//        */
//       var  SDWebImageHighPriority = 1 << 8
//
//       /**
//           不允许展示占位符,指导图片加载完成
//        */
//
//       var SDWebImageDelayPlaceholder = 1 << 9
//
//       /**
//        默认情况下，图片再下载完成以后都会被自动加载到UIImageView对象上面。但是有时我们希望UIImageView加载我们手动处理以后的图片
//        这个标记允许我们在completion这个Block中手动设置处理好以后的图片
//        */
//       var SDWebImageTransformAnimatedImage = 1 << 10
//
//       /**
//         默认情况下，图片会按照他的原始大小来解码显示。根据设备的内存限制，这个属性会调整图片的尺寸到合适的大小再解压缩
//         如果`SDWebImageProgressiveDownload`标记被设置了，则这个flag不起作用
//        */
//
//       var SDWebImageAvoidAutoSetImage = 1 << 11
//
//}

public enum SDWebImageOptions:UInt{
    //Raw value for enum case must be a literal
    /**
      默认情况下,当一个URL下载失败的时候,这个URL列入黑名单列表,下载再有这个url,就会停止请求
     */
    case SDWebImageRetryFailed =  1

    /**
    在默认情况下,当UI交互时候开始加载图片,这个标记可以组织这个中加载,这个值可以阻止这种情况加载,比如会导致UIScrollView下载延迟

     */
    case SDWebImageLowPriority = 2

    /**
       静止在磁盘缓存
     */

    case SDWebImageCacheMemoryOnly  = 4

    /**
      图片在加载中展示....... 默认情况是图片加载完成在请求
     */

    case SDWebImageProgressiveDownload = 8

    /**
        忽略缓存,通过HTTP缓存策略,还要加载图片
        专门用来处理rul地址不变,,但是url图片改变的情况
        这个情况,缓存由NSURLCache处理
        如果一个缓存图片更新了，则completion这个回调会被调用两次，一次返回缓存图片，一次返回最终图片。
        只有在不能确保URL和他对应的内容不能完全对应的时候才使用这个标记
     */

    case SDWebImageRefreshCached  = 16

    /**
        当app推出后台,则继续下载图片,下载的时间由系统分配,如果超时,则下载失败
     */
    case SDWebImageContinueInBackground = 32

    /**
        存储缓存在"NSHTTPCookie"的cookie
     */
    case SDWebImageHandleCookies = 64

    /**
       允许非认证的SSL证书加载
     */

    case SDWebImageAllowInvalidSSLCertificates = 128

    /**
        优先加载图片,默认是按照队列顺序加载图片
     */
    case  SDWebImageHighPriority = 256

    /**
        不允许展示占位符,指导图片加载完成
     */

    case SDWebImageDelayPlaceholder = 512

    /**
     默认情况下，图片再下载完成以后都会被自动加载到UIImageView对象上面。但是有时我们希望UIImageView加载我们手动处理以后的图片
     这个标记允许我们在completion这个Block中手动设置处理好以后的图片
     */
    case SDWebImageTransformAnimatedImage = 1024

    /**
      默认情况下，图片会按照他的原始大小来解码显示。根据设备的内存限制，这个属性会调整图片的尺寸到合适的大小再解压缩
      如果`SDWebImageProgressiveDownload`标记被设置了，则这个flag不起作用
     */

    case SDWebImageAvoidAutoSetImage = 2048

}

typealias SDWebImageCompletionBlock = (_ image:UIImage?,_ error:Error?,_ cacheType:SDImageCacheType,_ imageURL:URL?) ->Void?
typealias SDWebImageCompletionWithFinishedBlock = (_ image:UIImage?,_ error:Error?,_ cacheType:SDImageCacheType,_ imageURL:URL?,_ finished:Bool) ->Void?
typealias SDWebImageCacheKeyFilterBlock = (_ url:URL?) ->String?

//protocol SDWebImageCombinedOperation:SDWebImageOperation{
//    var cancelBlock:SDWebImageNoParamsBlock?
//    var cacheOperation:Operation?
//}

@objc protocol SDWebImageManagerDelegate{
    
    /**
      * 当没有缓存时找不到图片时控制下载图片
        parma imageURL:当前图片链接
        return  false:  防止图片下载时时丢失缓存     true 如果没有生效
     */
    @objc optional func imageManager(_ imageManager:SDWebImageManager, shouldDownloadImageForURL imageURL:URL) -> Bool
    /**
        允许在下载后立即转换图像，并在下载之前将其缓存到磁盘和内存中
         此方法是全局队列调用,以便不阻塞主线程
       
     */
    @objc optional func imageManager(_ imageManager:SDWebImageManager,transformDownloadedImage image:UIImage,withURL imageURL:URL) ->UIImage
    
}

class SDWebImageManager: NSObject {
    weak var delegate:SDWebImageManagerDelegate?
    private(set) var imageCache: SDImageCache?
    private(set) var imageDownloader:SDWebImageDownloader?
    var failedURLs:NSMutableSet?
    //var failedURLs = Set<URL>()
        //[Any]()
    //var runningOperations = [SDWebImageCombinedOperation]()
    
    var runningOperations:NSMutableArray?
    
    /// 图片过滤是个闭包,每次SDWebImageManage需要将url转化成缓存的key值,可动态删除图片
    ///  比如::::
    var cacheKeyFilter:SDWebImageCacheKeyFilterBlock?
    fileprivate static let instance = SDWebImageManager()
    
    static public var sharedManager:SDWebImageManager {
        get{
            return instance
        }
    }
    
    override init() {
        super.init()
        let cache = SDImageCache.sharedImageCache
        let  downloader = SDWebImageDownloader.sharedDownloader
        imageCache = cache
        imageDownloader = downloader
        runningOperations = NSMutableArray.init()
        failedURLs = NSMutableSet.init()
    }
     
    
//    convenience  init(WithCache cache:SDImageCache?,downloader:SDWebImageDownloader?) {
//        self.init()
//        imageCache = cache
//        imageDownloader = downloader
//        runningOperations = NSMutableArray.init()
//        failedURLs = NSMutableSet.init()
//    }
    
    
    
    /// URL--- Cache key
    /// - Parameter url: <#url description#>
    func cacheKeyForURL(_ url:URL?) -> String{
        if url == nil {
             return ""
        }
        if self.cacheKeyFilter != nil {
            return self.cacheKeyFilter!(url) ?? ""
        }else{
            return url?.absoluteString ?? ""
        }
       
    }
    
    
    /// 检查url是否存在缓存图片
    /// - Parameter url: <#url description#>
    func cachedImageExistsForURL(_ url:URL?) -> Bool{
        let key = self.cacheKeyForURL(url)
        if ((self.imageCache?.imageFromMemoryCacheForKey(key)) != nil) {
            return true
        }
        
        return self.imageCache?.diskImageExistsWithKey(key) ?? false
    }
    
    
    /// 检查磁盘中是否有图片
    /// - Parameter url: <#url description#>
    func diskImageExistsForURL(_ url:URL?) -> Bool{
         let key = self.cacheKeyForURL(url)
        return self.imageCache?.diskImageExistsWithKey(key) ?? false
    }
    
    
    /// 异步检查图片是否已经缓存
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - completionBlock: <#completionBlock description#>
    func cachedImageExistsForURL(_ url:URL? ,completion completionBlock:@escaping SDWebImageCheckCacheCompletionBlock) {
        let key = self.cacheKeyForURL(url)
        let isInMemoryCache =  self.imageCache?.imageFromMemoryCacheForKey(key) != nil
        if isInMemoryCache {
            DispatchQueue.main.async {
               // if(completionBlock != nil){
                    completionBlock(true)
               // }
            }
            return
        }
        
        self.imageCache?.diskImageExistsWithKey(key, completion: { (isInDiskCache:Bool) in
            completionBlock(isInDiskCache)
        })
        
    }
    
    
    /// 检出检出磁盘是否已经缓存了图片
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - completionBlock: <#completionBlock description#>
    func diskImageExistsForURL(_ url:URL?,completion completionBlock:@escaping SDWebImageCheckCacheCompletionBlock){
          let key = self.cacheKeyForURL(url)
          self.imageCache?.diskImageExistsWithKey(key, completion: { (isInDiskCache:Bool) in
            completionBlock(isInDiskCache)
        })
    }
    
    
    /// 如果缓存中不存在，则下载给定URL处的图像，否则返回缓存的版本
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - options: <#options description#>
    ///   - progressBlock: <#progressBlock description#>
    ///   - completedBlock: <#completedBlock description#>
    func downloadImageWithURL(_ url:URL,_ options:SDWebImageOptions, _ progressBlock:@escaping SDWebImageDownloaderProgressBlock,_ completedBlock:@escaping SDWebImageCompletionWithFinishedBlock) -> Optional<SDWebImageOperation>{
        
         //var operation:SDWebImageDownloaderOperation?
        // weak var weakSelf = self
        ///在没有completedBlock的情况下调用此方法是没有意义的
        /// 如果要预取图像，请改用-[SDWebImagePrefetcher prefetchURLs]
         assert(completedBlock != nil, "如果要预取图像，请改用-[SDWebImagePrefetcher prefetchURLs]")
        
        /// swift 对类型转换要求严格 不考虑  if ([url isKindOfClass:NSString.class]) {url = [NSURL URLWithString:(NSString *)url];}  if (![url isKindOfClass:NSURL.class]) {url = nil;}
        let operation = SDWebImageCombinedOperation.init()
        weak var weakOperation = operation
        var isFailedUrl = false
        SDWebImageDownloaderOperation.synchronized(anyID: self.failedURLs ?? NSMutableSet.init()) {
            isFailedUrl  = self.failedURLs?.contains(url) ?? false
        }
        
        if url.absoluteString.count == 0 ||  ((options.rawValue & SDWebImageOptions.SDWebImageRetryFailed.rawValue != 0) && isFailedUrl){
            if Thread.isMainThread{
                completedBlock(nil,NSError.init(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil),SDImageCacheType.SDImageCacheTypeNone,url,true)
            }else{
                DispatchQueue.main.async {
                     completedBlock(nil,NSError.init(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil),SDImageCacheType.SDImageCacheTypeNone,url,true)
                }
            }
        }
        
        SDWebImageDownloaderOperation.synchronized(anyID: self.runningOperations ?? NSMutableArray.init()) {
            self.runningOperations?.add(operation)
        }
        
        let key = self.cacheKeyForURL(url)
        
        operation.cacheOperation = self.imageCache?.queryDiskCacheForKey(key: key, doneBlock: { (image:UIImage?, cacheType:SDImageCacheType) in
            
            
            if operation.isCancelled ?? false{
                SDWebImageDownloaderOperation.synchronized(anyID: self.runningOperations ?? NSMutableArray.init()) {
                    self.runningOperations?.remove(operation)
                }
                return
            }
            /*???????????????? */
//            if ((!image || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url]) ==== swift逻辑不等价) {
//
            if (image == nil || options.rawValue &  SDWebImageOptions.SDWebImageRefreshCached.rawValue != 0) && (self.delegate?.imageManager?(self, shouldDownloadImageForURL: url) ?? true){
                if image != nil && options.rawValue & SDWebImageOptions.SDWebImageRefreshCached.rawValue != 0{
                    /// 如果已经图片缓存但设置成SDWebImageRefreshCached,则通知图片缓存
                    /// 并尝试重新下载它，以便让NSURLCache有机会从服务器刷新它
                    if Thread.isMainThread {
                        completedBlock(image,nil,cacheType,url,true)
                    }else{
                        DispatchQueue.main.async {
                             completedBlock(image,nil,cacheType,url,true)
                        }
                    }
                }
                
                /// download if no image or requested to refresh anyway, and download allowed by delegate
                
                var downloaderOptions:SDWebImageDownloaderOptions = SDWebImageDownloaderOptions.SDWebImageDownloaderNone
                if options.rawValue & SDWebImageOptions.SDWebImageLowPriority.rawValue != 0 {
                    downloaderOptions = SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority.rawValue | downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                }
                
                if options.rawValue & SDWebImageOptions.SDWebImageProgressiveDownload.rawValue != 0 {
                     downloaderOptions = SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderProgressiveDownload.rawValue | downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                }
                
                if options.rawValue & SDWebImageOptions.SDWebImageRefreshCached.rawValue != 0 {
                      downloaderOptions = SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderUseNSURLCache.rawValue | downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                 }
                
                // 忽略SDWebImageContinueInBackground 不支持这种情况
                if options.rawValue & SDWebImageOptions.SDWebImageContinueInBackground.rawValue != 0 {
                         downloaderOptions = SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderContinueInBackground.rawValue | downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                }
                
                if options.rawValue & SDWebImageOptions.SDWebImageHandleCookies.rawValue != 0 {
                     downloaderOptions = SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderHandleCookies.rawValue | downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                }
                
                if options.rawValue & SDWebImageOptions.SDWebImageAllowInvalidSSLCertificates.rawValue != 0 {
                        downloaderOptions = SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderAllowInvalidSSLCertificates.rawValue | downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                }
                
                if options.rawValue & SDWebImageOptions.SDWebImageHighPriority.rawValue != 0 {
                        downloaderOptions = SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderHighPriority.rawValue | downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                }
                
                if image != nil && options.rawValue & SDWebImageOptions.SDWebImageRefreshCached.rawValue != 0 {
                    /// 如果图片已经缓存 但正在强制刷新  则强制禁用渐进式
                    downloaderOptions =  SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderProgressiveDownload.rawValue & downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                    /// 如果图像已缓存，则忽略从NSURLCache读取的图片，但强制刷新
                    
                     downloaderOptions = SDWebImageDownloaderOptions(rawValue: SDWebImageDownloaderOptions.SDWebImageDownloaderIgnoreCachedResponse.rawValue | downloaderOptions.rawValue) ?? SDWebImageDownloaderOptions.SDWebImageDownloaderLowPriority
                    
                }
                
                let  subOperation:Optional<SDWebImageOperation> = self.imageDownloader?.downloadImageWithURL(url, progress: downloaderOptions, progress: progressBlock, completed: { (downloadedImage:UIImage?, data:Data?, error:Error?, finished:Bool) -> Void? in
                    if weakOperation == nil || weakOperation?.isCancelled ?? false{
                        /// 如果这个操作被删除,则不不做任何操作
                        /// 如果调用completedBlock,  则另外一个completedBlock之间存在竞争关系, 所以如果这个被第二次被调用,则重数据
                    }else if(error != nil){
                        if Thread.isMainThread {
                            if weakOperation != nil && weakOperation?.isCancelled == false {
                                completedBlock(nil,error,SDImageCacheType.SDImageCacheTypeNone,url,finished)
                            }
                        }else{
                            DispatchQueue.main.async {
                                if weakOperation != nil && weakOperation?.isCancelled == false {
                                    completedBlock(nil,error,SDImageCacheType.SDImageCacheTypeNone,url,finished)
                                }
                            }
                        }
                        
                        let errorCode =  error! as NSError
                        if errorCode.code != NSURLErrorNotConnectedToInternet && errorCode.code != NSURLErrorCancelled && errorCode.code != NSURLErrorTimedOut && errorCode.code != NSURLErrorInternationalRoamingOff && errorCode.code != NSURLErrorDataNotAllowed && errorCode.code != NSURLErrorCannotFindHost && errorCode.code != NSURLErrorCannotConnectToHost{
                            SDWebImageDownloaderOperation.synchronized(anyID: self.failedURLs ?? NSMutableSet.init()) {
                                self.failedURLs?.add(url)
                            }
                        }
                        
                    }else{
                        if options.rawValue & SDWebImageOptions.SDWebImageRetryFailed.rawValue != 0 {
                            SDWebImageDownloaderOperation.synchronized(anyID: self.failedURLs ?? NSMutableSet.init()) {
                                self.failedURLs?.remove(url)
                            }
                        }
                        
                        let cacheOnDisk = options.rawValue & SDWebImageOptions.SDWebImageCacheMemoryOnly.rawValue == 0
                        if options.rawValue & SDWebImageOptions.SDWebImageRefreshCached.rawValue != 0 && image != nil && (downloadedImage == nil) {
                            /// 刷新命中NSURLCache缓存，不调用完成块
                            
                            /// downloadedImage && (!downloadedImage.images || (options & SDWebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)??????
                        }else if (downloadedImage != nil  && ( SDWebImageManager.jusgeAnyEmpty(downloadedImage?.images) == false || downloadedImage?.images?.count == 0 || (options.rawValue & SDWebImageOptions.SDWebImageTransformAnimatedImage.rawValue != 0)) &&  self.delegate?.imageManager?(self, transformDownloadedImage: downloadedImage ?? UIImage.init(), withURL: url) != nil){
                            DispatchQueue.global(qos: .userInteractive).async {
                                // 要实现 self.delegate?.imageManager?(self, transformDownloadedImage: downloadedImage ?? UIImage.init(), withURL: url)才行 这个方法
                                let transformedImage = self.delegate?.imageManager?(self, transformDownloadedImage: downloadedImage ?? UIImage.init(), withURL: url)
                                if (transformedImage != nil) && finished{
                                    let  imageWasTransformed = transformedImage?.isEqual(downloadedImage)
                                    self.imageCache?.storeImage(transformedImage, recalculateFromImage: imageWasTransformed ?? false, imageData: imageWasTransformed == nil ?nil:data, forKey: key, toDisk: cacheOnDisk)
                                };
                                
                                if Thread.isMainThread {
                                    if weakOperation != nil  && (weakOperation?.isCancelled == false || SDWebImageManager.jusgeAnyEmpty(weakOperation) == false ){
                                        completedBlock(transformedImage,nil,SDImageCacheType.SDImageCacheTypeNone,url,finished)
                                    }
                                }else{
                                    if weakOperation != nil  && (weakOperation?.isCancelled == false || SDWebImageManager.jusgeAnyEmpty(weakOperation) == false ) {
                                     completedBlock(transformedImage,nil,SDImageCacheType.SDImageCacheTypeNone,url,finished)
                                    }
                                }
                                
                                
                            }
                            
                        }else{
                            
                            if downloadedImage != nil  && finished {
                                self.imageCache?.storeImage(downloadedImage, recalculateFromImage: false, imageData: data, forKey: key, toDisk: cacheOnDisk)
                                 if Thread.isMainThread {
                                       if weakOperation != nil  && (weakOperation?.isCancelled == false || SDWebImageManager.jusgeAnyEmpty(weakOperation) == false ){
                                      completedBlock(downloadedImage,nil,SDImageCacheType.SDImageCacheTypeNone,url,finished)
                                       }
                                   }else{
                                       if weakOperation != nil  && (weakOperation?.isCancelled == false || SDWebImageManager .jusgeAnyEmpty(weakOperation?.isCancelled) == false){
                                         completedBlock(downloadedImage,nil,SDImageCacheType.SDImageCacheTypeNone,url,finished)
                                       }
                                   }
                            
                            }
                            
                        }
                        
                    }
                    
                    if finished {
                        SDWebImageDownloaderOperation.synchronized(anyID: self.runningOperations ?? NSMutableArray.init()) {
                            if (weakOperation != nil){
                                self.runningOperations?.add(weakOperation!)
                            }
                        }
                    }
                    
                    
                    return nil
                    
                })
                
                operation.setCancelBlock { () -> Void? in
                    
                    subOperation?.cancel()
                    // strong var strongOperation = weakOperation
                    if weakOperation != nil{
                        self.runningOperations?.add(weakOperation!)
                    }
                    
                    return nil
                }
    
            }else if image != nil{
                // __strong __typeof(weakOperation) strongOperation = weakOperation;
                 
                if Thread.isMainThread {
                    if weakOperation != nil && (weakOperation?.isCancelled == false || weakOperation?.isCancelled == nil ) {
                        completedBlock(image,nil,cacheType,url,true)
                    }
                }else{
                    DispatchQueue.main.sync {
                        if weakOperation != nil && weakOperation?.isCancelled == false {
                            completedBlock(image,nil,cacheType,url,true)
                        }
                    }
                }
                
                SDWebImageDownloaderOperation.synchronized(anyID: self.runningOperations ?? NSMutableArray.init()) {
                    self.runningOperations?.remove(operation)
                }
                
            }else{
                if Thread.isMainThread {
                   if weakOperation != nil && weakOperation?.isCancelled == false {
                       completedBlock(nil,nil,cacheType,url,true)
                   }
               }else{
                   DispatchQueue.main.sync {
                       if weakOperation != nil && weakOperation?.isCancelled == false {
                           completedBlock(nil,nil,cacheType,url,true)
                       }
                   }
               }
                
                SDWebImageDownloaderOperation.synchronized(anyID: self.runningOperations ?? NSMutableArray.init()) {
                    self.runningOperations?.remove(operation)
                }
                
            }
        })
        
        return operation
    
    }
    
    ///将图像保存到给定URL的缓存中
    /// - Parameters:
    ///   - image: <#image description#>
    ///   - url: <#url description#>
    func saveImageToCache(_ image:UIImage?, _ url:URL?){
        if image != nil  && url != nil {
            let key = self.cacheKeyForURL(url)
            self.imageCache?.storeImage(image!, forkey: key, toDisk: true)
        }
    }
    
    
    /// 删除当前的操作
    func cancelAll(){
        SDWebImageDownloaderOperation.synchronized(anyID: self.runningOperations ?? NSMutableArray.init()) {
            self.runningOperations?.removeAllObjects()
        }
        
    }
    
    
    /// 检查多个或者一个操作是否执行
    func  isRunning() -> Bool{
        var isRunning = false
        SDWebImageDownloaderOperation.synchronized(anyID: self.runningOperations ?? NSMutableArray.init()) {
            isRunning = self.runningOperations?.count ?? 0 > 0
        }
        return isRunning

    }
    
    /// 判读是否为空  any defalut false
    /// - Parameter any: <#any description#>
    class func jusgeAnyEmpty(_ any:Any?) -> Bool {
        if any != nil {
            return true
        }
        return false
    }
    
}



