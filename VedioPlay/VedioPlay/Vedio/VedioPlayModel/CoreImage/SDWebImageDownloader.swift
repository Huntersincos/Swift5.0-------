//
//  SDWebImageDownloader.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/7.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

/// <#Description#>
public enum SDWebImageDownloaderOptions:Int{
    case SDWebImageDownloaderLowPriority = 1
    case SDWebImageDownloaderProgressiveDownload = 2
    /// SDWebimaage 默认情况下,是阻止 NSURLCache缓存,这个值可以使得NSURLCache和默认缓存策略一起使用
    case SDWebImageDownloaderUseNSURLCache = 4
    /// 如果图片是从NSURLCache读取话,则使用nil image/imageData调用完成块,与SDWebImageDownloaderUseNSURLCache相结合使用
    case SDWebImageDownloaderIgnoreCachedResponse = 8
    /// 在iOS4以上,如果在app中Background 运行下载图片,是由系统决定的, 在后台的额外时间让请求完成。如果后台任务过期，操作将被取消。
    case SDWebImageDownloaderContinueInBackground = 16
    /// 设置cookie
    case SDWebImageDownloaderHandleCookies = 32
    /// 能否允许不信任证书
    case SDWebImageDownloaderAllowInvalidSSLCertificates = 64
    /// 把图片放入优先队列
    case  SDWebImageDownloaderHighPriority = 128
}

public enum SDWebImageDownloaderExecutionOrder:Int{
    /// 默认值,图片加载操作先进先出
    case SDWebImageDownloaderFIFOExecutionOrder
    /// 图片加载先进后出 ,栈的形式
    case SDWebImageDownloaderLIFOExecutionOrder
    
}

typealias SDWebImageDownloaderProgressBlock = (_ receivedSize:Int, _ expectedSize:Int) -> Void?
typealias SDWebImageDownloaderCompletedBlock = (_ image:UIImage?, _ data:Data?, _ error:Error?, _ finished:Bool) -> Void?
typealias SDWebImageDownloaderHeadersFilterBlock = (_ url:URL?,_ headers:[String:String]?) -> [String:String]?
extension SDWebImageDownloader{
    public  class func initializeOnceMethod() {
       //  SDNetworkActivityIndicator 可以不引入 使用runtime调用
//        if (NSClassFromString("SDNetworkActivityIndicator") != nil) {
//           /**#pragma clang diagnostic push
//            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            #pragma clang diagnostic pop
//             消除警告 swift代替方案
//            */
//            let activityTarget = NSClassFromString("SDNetworkActivityIndicator")
//            let sdnetworkSelector = NSSelectorFromString("sharedActivityIndicator")
//            //activityIndicator?.performSelector
//            activityTarget?.perform(sdnetworkSelector)
//        }
        
           
    }
    
}

protocol SDWebImageOperation {
    func cancel()
}



class SDWebImageDownloader: NSObject,URLSessionTaskDelegate,URLSessionDataDelegate {
    public static var kProgressCallbackKey = "progress"
    public static var kCompletedCallbackKey = "completed"
   // public  var SDWebImageDownloadStartNotification = "SDWebImageDownloadStartNotification";
    //public  var SDWebImageDownloadStopNotification  = "SDWebImageDownloadStopNotification"
    /// 对下载和缓存的图像进行解压缩可以提高性能，但会消耗大量内存,默认为true 如果设置成false 因内存消耗过度引起闪退
    var  shouldDecompressImages:Bool?
    //var _maxConcurrentDownloads:Int?
    /// 当前仍需下载量
   // private(set) var _currentDownloadCount:Int?
    /// 下载超时时间,默认为15s
    var downloadTimeout:TimeInterval?
    var executionOrder:SDWebImageDownloaderExecutionOrder?
    /// 获取URL设置的证书的请求操作
    var urlCredential:URLCredential?
    var username:String?
    var password:String?
    ///设置过滤器以选取下载图像HTTP请求的头
    var headersFilter:SDWebImageDownloaderHeadersFilterBlock?
    
    var downloadQueue:OperationQueue?
    var lastAddedOperation:Operation?
    var operationClass:AnyClass?
    //var URLCallback = [String]()
   // [String: Optional<Any>]()
    var URLCallbacks =  [URL:[Optional<Any>]]()
    var HTTPHeader = [String:String]()
    
        //[String:String]()
    /// 这个队列用于所有的网络下载响应
    var barrierQueue:DispatchQueue?
    var session:URLSession?
    //Method 'initialize()' defines Objective-C class method 'initialize', which is not permitted by Swift
   
   fileprivate static var instacne  =  SDWebImageDownloader()
   public static var sharedDownloader:SDWebImageDownloader {
      get{
        return instacne
      }
   }
   
//    override class func initialize() {
//        super.initialize()
//    } Method 'initialize()' defines Objective-C class method 'initialize', which is not permitted by Swift 有代替方案 用extension
    
    override init() {
        super.init()
        self.operationClass = SDWebImageDownloaderOperation.self
        self.shouldDecompressImages = true
        self.executionOrder = .SDWebImageDownloaderFIFOExecutionOrder
        self.downloadQueue = OperationQueue.init()
        self.downloadQueue?.name = "com.hackemist.SDWebImageDownloader"
        //self.URLCallbacks = NSMutableDictionary.init()
        //self.HTTPHeader = NSMutableDictionary.init()
//        #ifdef SD_WEBP
//                _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy];
//        #else
        self.HTTPHeader = ["Accept":"image/*;q=0.8"]
        self.barrierQueue = DispatchQueue.init(label: "com.hackemist.SDWebImageDownloaderBarrierQueue", qos: DispatchQoS.default, attributes: .concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        self.downloadTimeout = 15
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = self.downloadTimeout ?? 15
        self.session = URLSession.init(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        
    }
    
    
    /// 获取http请求下载pick image header
    /// - Parameters:
    ///   - value: 值 nill 则为删除 value
    ///   - field: head 文件名
    func setValue(_ value:String?,forHTTPHeaderField field:String){
        if value != nil {
            HTTPHeader[field] = value
        }else{
            HTTPHeader.removeValue(forKey: field)
            //HTTPHeader.index(forKey: field)
            //removeObject(forKey: field)
        }
    }
    
    
    /// 返回特殊 http请求 value
    /// - Parameter field: 返回的value与head值有关 如果没有相关的的value值 则为nil
    func  valueForHTTPHeaderField(_ field:String) ->String?{
        
        return  HTTPHeader[field]
    }
    
    var maxConcurrentDownloads:Int{
        set{
            /// 最大并发数
            downloadQueue?.maxConcurrentOperationCount = newValue
        }
        get{
            return downloadQueue?.maxConcurrentOperationCount ?? 0
        }
    }
    
   private(set) var currentDownloadCount:Int{
        set{
            //_currentDownloadCount  =  newValue
        }
        get{
            // 队列并发数
            return downloadQueue?.operationCount ?? 0
        }
    }
    
    
    /// 赋值默认父类 SDWebImageDownloaderOperation    创建SDWebImage的一个请求使用 Operation 操作下载图片
    /// - Parameter operationClass: SDWebImageDownloaderOperation
    func setOperationClass(_ operationClass:AnyClass?){
        //???????
        if operationClass != nil {
             self.operationClass = operationClass
        }else{
            self.operationClass = SDWebImageDownloaderOperation.self
        }
       
    }
    
    ///通过URL 创建一个异步SDWebImageDownloader实例 ,返回delegate:当下载成功或者失败回值.cancelable
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - options: options description 使用下载调用快
    ///   - progressBlock: 当下载时调用block progress
    ///   - completedBlock: completedBlock description 当下载完成时,如果下载成功,传值图片参数,最后一个参数参true
    func downloadImageWithURL(_ url:URL , progress options: SDWebImageDownloaderOptions, progress progressBlock:@escaping SDWebImageDownloaderProgressBlock, completed completedBlock:@escaping SDWebImageDownloaderCompletedBlock) ->  Optional<SDWebImageOperation>{
        var operation:SDWebImageDownloaderOperation?
        weak var weakSelf = self
        addProgressCallback(progressBlock, completedBlock, { () -> Void? in
            var  timeoutInterval = weakSelf?.downloadTimeout
            if timeoutInterval == 0.0{
                timeoutInterval = 15.0
            }
            // 为了防止潜在的重复缓存（NSURLCache+SDImageCache），禁用了图像请求的缓存，除非另有说明
            var cachePolicy =  NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
            if options.rawValue & SDWebImageDownloaderOptions.SDWebImageDownloaderUseNSURLCache.rawValue != 0{
                cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
                
            }
           // NSMutableURLRequest.init(url: <#T##URL#>, cachePolicy: <#T##NSURLRequest.CachePolicy#>, timeoutInterval: <#T##TimeInterval#>)
            let request = NSMutableURLRequest.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval ?? 15)
            request.httpShouldHandleCookies = options.rawValue & SDWebImageDownloaderOptions.SDWebImageDownloaderHandleCookies.rawValue != 0
            //通常默认情况下请求和响应是顺序的, 也就是说请求–>得到响应后,再请求.
            //如果将HTTPShouldUsePipelining设置为YES, 则允许不必等到response, 就可以再次请求. 这个会很大的提高网络请求的效率,但是也可能会出问题.
           // 因为客户端无法正确的匹配请求与响应, 所以这依赖于服务器必须保证,响应的顺序与客户端请求的顺序一致.如果服务器不能保证这一点, 那可能导致响应和请求混乱.
            request.httpShouldUsePipelining =  true
            if weakSelf?.headersFilter != nil{
                request.allHTTPHeaderFields = weakSelf?.headersFilter!(url,weakSelf?.HTTPHeader)
            }else{
                request.allHTTPHeaderFields = weakSelf?.HTTPHeader
            }
             //options = 
            
           return nil
            
        }, url)
        
        return operation
        
    }
    
    func addProgressCallback(_ progressBlock:@escaping SDWebImageDownloaderProgressBlock, _ completedBlock:@escaping SDWebImageDownloaderCompletedBlock,_ createCallback: @escaping SDWebImageNoParamsBlock, _ url:URL?){
        if url == nil {
            completedBlock(nil,nil,nil,false)
            return
        }
       // dispatch_barrier_sync 和 dispatch_barrier_async    珊栏函数 使用系统全局并发队列 珊栏函数失去意义 使用自定义队列才有意义
        //dispatch_barrier_sync
        self.barrierQueue?.sync(flags: .barrier, execute: {
            var first =  false
            if self.URLCallbacks[url ?? URL.init(fileURLWithPath: "")] == nil{
                //self.URLCallbacks[url ?? URL.init(fileURLWithPath: "")] = NSMutableArray.init() as? [String]
                first =  true
            }
            
            var  callbacksForURL =  self.URLCallbacks[url ?? URL.init(fileURLWithPath: "")]
            var  callbacks = [String: Optional<Any>]()
//            if progressBlock != nil{
//
//            }
            callbacks[SDWebImageDownloader.kProgressCallbackKey] = progressBlock
            callbacks[SDWebImageDownloader.kCompletedCallbackKey] = completedBlock
            callbacksForURL?.append(callbacks)
            self.URLCallbacks[url ?? URL.init(fileURLWithPath: "")] =  callbacksForURL
            if first {
                createCallback()
            }
            
            
        })
        
    }
    
    deinit {
        self.session?.invalidateAndCancel()
        self.session = nil
        self.downloadQueue?.cancelAllOperations()
        self.barrierQueue = nil
    }
    

    
    
}
