//
//  SDWebImageDownloaderOperation.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/7.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import ImageIO
public var SDWebImageDownloadStartNotification = "SDWebImageDownloadStartNotification"
public var SDWebImageDownloadStopNotification = "SDWebImageDownloadStopNotification"
public var SDWebImageDownloadReceiveResponseNotification = "SDWebImageDownloadReceiveResponseNotification"
public var SDWebImageDownloadFinishNotification = "SDWebImageDownloadFinishNotification"
class SDWebImageDownloaderOperation: Operation,SDWebImageOperation,URLSessionDataDelegate,URLSessionTaskDelegate {
    
    /// request:操作任务的响应
    private(set) var request:URLRequest?
    
    /// 任务
    private(set) var dataTask:URLSessionTask?
    var shouldDecompressImages:Bool?
    
    /// 过期属性 __deprecated_msg swift shouldUseCredentialStorage
    @available(*, deprecated, message: "Property deprecated. Does nothing. Kept only for backwards compatibility 属性已经废弃,属性已弃用。什么都不做。仅为向后兼容而保留")
    var shouldUseCredentialStorage:Bool?
    
    var credential:URLCredential?
    private(set) var options:SDWebImageDownloaderOptions?
    /// 预测数据 expected大小
    var expectedSize:Int64?
    var response:URLResponse?
    var progressBlock:SDWebImageDownloaderProgressBlock?
    var completedBlock:SDWebImageDownloaderCompletedBlock?
    var cancelBlock:SDWebImageNoParamsBlock?
    var imageData:NSMutableData?
    
    /// 弱引用的原因:它是由管理此Session的人注入的,如果没值了,则程序无法使用 ???
    weak var unownedSession:URLSession?
    
    /// 如果不使用注入Session这个值,设置这个值无效
    var ownedSession:URLSession?
    var thread:Thread?
    var backgroundTaskId:UIBackgroundTaskIdentifier?
    var width:size_t?
    var height:size_t?
    var orientation:UIImage.Orientation?
    var responseFromCached:Bool?
    var sd_Executing:Bool?
    
    override var isExecuting: Bool{
        set{
            self.willChangeValue(forKey: "isExecuting")
            
        }get{
            self.didChangeValue(forKey: "isExecuting")
            return self.sd_Executing ?? false
        }
    }
    
    override var isFinished: Bool{
        set{
            self.willChangeValue(forKey: "isFinished")
        }
        get{
            self.didChangeValue(forKey: "isFinished")
            return self.sd_finished ?? false
        }
    }
    
    var sd_finished:Bool?
    
    /// Description 定义一个SDWebImageDownloaderOperationd 对象
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - session: <#session description#>
    ///   - options: <#options description#>
    ///   - progressBlock: <#progressBlock description#>
    ///   - completedBlock: <#completedBlock description#>
    ///   - cancelBlock: <#cancelBlock description#>
    convenience  init(withRequest request:URLRequest,inSession session:URLSession, _  options:SDWebImageDownloaderOptions,progress progressBlock:@escaping SDWebImageDownloaderProgressBlock, completed completedBlock: @escaping SDWebImageDownloaderCompletedBlock, cancelled cancelBlock:@escaping SDWebImageNoParamsBlock) {
        self.init()
        self.request = request
        self.shouldDecompressImages = true
        self.options = options
        self.progressBlock = progressBlock
        self.completedBlock = completedBlock
        self.cancelBlock =  cancelBlock
        self.sd_Executing = false;
        self.sd_finished = false;
        self.expectedSize = 0;
        self.unownedSession = session
        /// ???
        self.responseFromCached = true
    }
    
    override func start() {
        //@synchronized 互斥锁  ==== swift
        SDWebImageDownloaderOperation.synchronized(anyID: self) {
            if self.isCancelled{
                self.sd_finished = true
                self.isFinished = true
                reset()
                return
            }
           
            let  UIApplicationClass:AnyClass?  =  NSClassFromString("UIApplication")
            let hasApplication = (UIApplicationClass != nil) && UIApplicationClass?.responds(to: #selector(getter: UIApplication.shared)) ?? false
            if hasApplication && shouldContinueWhenAppEntersBackground(){
                // weak var weakSelf = self
                // performSelector:是iOS中一种调用方式,可以向任何对象传递任何消息,不需要申明这些方法,如果改方法不存在 ??????
                //let app =  UIApplicationClass?.p
            }
            
            var  session = self.unownedSession
            if self.unownedSession == nil{
                let  sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = 15
                self.ownedSession = URLSession.init(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                session = self.ownedSession
            }
            if self.request == nil {
                return
            }
            self.dataTask = session?.dataTask(with: self.request!)
            self.sd_Executing = true
            self.isExecuting = true
            self.thread = Thread.current
            
        }
        
        self.dataTask?.resume()
        
        if self.dataTask != nil {
            if (self.progressBlock != nil) {
                //NSURLResponseUnknownLength 无法确定长度
                self.progressBlock!(0,-1)
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SDWebImageDownloadStartNotification), object: self)
            }
        }else{
            if self.completedBlock != nil {
                self.completedBlock!(nil,nil,NSError.init(domain:NSURLErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "Connection can't be initialized"]),true)
            }
            
        }
        
       ///  let  UIApplicationClass:AnyClass?  =  NSClassFromString("UIApplication") ?????
        
    }
    
    override func cancel() {
        SDWebImageDownloaderOperation.synchronized(anyID: self) {
            if self.thread != nil{
                self.perform(#selector(cancelInternalAndStop), on: self.thread!, with: nil, waitUntilDone: false)
                
            }else{
                 cancelInternal()
            }
        }
    }
    
    func cancelInternal(){
        if self.isFinished {
            return
        }
        super.cancel()
        
        if (self.cancelBlock != nil) {
            self.cancelBlock!()
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SDWebImageDownloadStopNotification), object: self)
        }
        
        if self.isExecuting {
            self.sd_Executing = false
            self.isExecuting = false
        }
        
        if self.isFinished == false {
            self.sd_finished = true
            self.isFinished = true
        }
        reset()
    }
    
    func done(){
        self.sd_finished = true
        self.isFinished = true
        reset()
    }
    
    
    @objc func  cancelInternalAndStop(){
        if self.isFinished {
            return
        }else{
            cancelInternal()
        }
        
    }
    
    func reset(){
        self.cancelBlock = nil;
        self.completedBlock = nil;
        self.progressBlock = nil;
        self.dataTask = nil;
        self.imageData = nil;
        self.thread = nil;
        if self.ownedSession != nil {
            self.ownedSession?.invalidateAndCancel()
            self.ownedSession = nil
        
        }
    
    }
    
    override var isConcurrent: Bool{
        return true
    }
    
    /// URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void){
        // 除去304 Not Modified 访问资源出现304访问的情况下其实就是先在本地缓存了访问的资源。 300 --400
        let httpURLResponse:HTTPURLResponse? = response as? HTTPURLResponse
//          if (![response respondsToSelector:@selector(statusCode)] || ([((NSHTTPURLResponse *)response) statusCode] < 400 && [((NSHTTPURLResponse *)response) statusCode] != 304)) ????????   {
        if response.responds(to: #selector(getter: HTTPURLResponse.statusCode)) == false ||  (httpURLResponse?.statusCode ?? 400 < 400 && httpURLResponse?.statusCode != 304) {
            let expected = httpURLResponse?.expectedContentLength ?? 0 > 0 ? httpURLResponse?.expectedContentLength:0
            self.expectedSize = expected
            if  self.progressBlock != nil{
                self.progressBlock!(0,expected)
            }
            self.imageData = NSMutableData.init(capacity: Int(expected ?? 0))
            self.response = response
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SDWebImageDownloadReceiveResponseNotification), object: self)
            }
            
        }else{
            // 当服务端返回304 Not Modified,意味着图片没有发生改变
            // 这种情况,停止加载图片,使用缓存图片
            if httpURLResponse?.statusCode == 304 {
                cancelInternal()
            }else{
                self.dataTask?.cancel()
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SDWebImageDownloadStopNotification), object: self)
            }
            
            if self.completedBlock != nil {
                self.completedBlock!(nil,nil,NSError.init(domain: NSURLErrorDomain, code: httpURLResponse?.statusCode ?? 0, userInfo: nil),true)
            }
            done()
        }
        
//        if completionHandler != nil {
//
//        }
        completionHandler(.allow)
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.imageData?.append(data)
        if self.options != nil {
            if (self.options!.rawValue & SDWebImageDownloaderOptions.SDWebImageDownloaderProgressiveDownload.rawValue) != 0 && self.expectedSize ?? 0 > 0 && self.completedBlock != nil {
                /**
                 array  ------- cfarray
                   */
                
                // data --- cfdata
               // let alloctCFAllocator = CFAllocatorGetDefault().takeUnretainedValue()
                //let Unsafe = UnsafePointer<UInt8>.init(bitPattern: 0)
              //  let cfData = CFDataCreate(alloctCFAllocator, Unsafe, 0)
                
              //  let cfData = CFDataCreateMutable(alloctCFAllocator,0)
                //UnsafeMutableRawPointer.init(bitPattern: 0)
                //CFDataAppendBytes(cfData, Unsafe, 0)
                //CFDataAppendBytes(cfData, Unmanaged.passUnretained(self.imageData ?? NSObject.init()).autorelease().toOpaque(), 0)
                
                let totalSize = self.imageData?.length
                let imageSource =  CGImageSourceCreateWithData(self.imageData ?? Data.init() as CFData, nil)!
            
                if (self.width ?? 0) + (self.height ?? 0) == 0 {
                    let  properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
                    if properties != nil {
                        var orientationValue = -1
                        //let kCGImagePixelHeight = kCGImagePropertyPixelHeight
                        /// ????
                        var val:CFTypeRef? = CFDictionaryGetValue(properties, Unmanaged.passRetained(kCGImagePropertyPixelHeight).autorelease().toOpaque()) as CFTypeRef?
                        
                        if val != nil {
                            //let number:CFNumber? = nil ????
                            val  =  CFNumberGetValue((val as! CFNumber), .longType, &self.height) as CFTypeRef
                         }
                        if val != nil {
                                ///???
                              val = CFDictionaryGetValue(properties, Unmanaged.passRetained(kCGImagePropertyPixelWidth).autorelease().toOpaque()) as CFTypeRef?
                        }
                                
                        if val != nil {
                            /// ???
                           val  =  CFNumberGetValue((val as! CFNumber), .longType, &self.width) as CFTypeRef
                        }
                        
                        if val != nil {
                            
                            val = CFDictionaryGetValue(properties, Unmanaged.passRetained(kCGImagePropertyOrientation).autorelease().toOpaque()) as CFTypeRef?
                        }
                        
                        if val != nil {
                            
                            val = CFNumberGetValue((val as! CFNumber), .nsIntegerType, &orientationValue) as CFTypeRef
                        }
                                    
                        //CFRelease
                        // 当使用Graphics绘图时,会丢失图片定向信息
                        //
                        
                        self.orientation =  SDWebImageDownloaderOperation.orientationFromPropertyValue(orientationValue)
                    }
                    
                }
                
                if (self.width ?? 0)  + (self.height ?? 0) > 0 && Int64(totalSize ?? 0 ) < (self.expectedSize ?? 0) {
                    var partialImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
                   // #if TARGET_OS_IPHONE
                    if partialImageRef != nil {
                        let partialHeight = partialImageRef?.height
                        let colorSpace = CGColorSpaceCreateDeviceRGB()
                        let bmContext = CGContext.init(data: nil, width: self.width ?? 0, height: self.height ?? 0, bitsPerComponent: 8, bytesPerRow: (self.width ?? 0) * 4, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrderMask.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue )
                        if bmContext != nil {
                            bmContext?.draw(partialImageRef!, in: CGRect(x: 0, y: 0, width: self.width ?? 0, height: partialHeight ?? 0))
                            partialImageRef = bmContext?.makeImage()
                            
                        }else{
                            partialImageRef = nil
                        }
                        
                        
                    }
                    //#endif
                    
                    if partialImageRef != nil {
                        var image = UIImage.init(cgImage: partialImageRef!, scale: 1, orientation: self.orientation ?? UIImage.Orientation.up)
                        if self.request?.url != nil {
                            let key = SDWebImageManager.sharedManager.cacheKeyForURL((self.request?.url)!)
                            let scaledImage = SDScaledImageForKey(key, image)
                            if self.shouldDecompressImages ?? true {
                                image = SDWebImageDecoder.decodedImageWithImage(scaledImage) ?? image
                            }else{
                                image = scaledImage ?? image
                            }
                           // CGImageRelease
                            if Thread.isMainThread {
                                if (self.completedBlock != nil) {
                                    self.completedBlock!(image,nil,nil,false)
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    if (self.completedBlock != nil) {
                                        self.completedBlock!(image,nil,nil,false)
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }
                      
                        
                    }
                    
                }
            }
        
        }
        
        if self.progressBlock != nil {
            self.progressBlock!(self.imageData?.length ?? 0,self.expectedSize)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        // 如果这个方法被调用,意思没有读取缓存
        self.responseFromCached = false
        var cachedResponse:CachedURLResponse? = proposedResponse
        if self.request?.cachePolicy == NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData{
            cachedResponse = nil
        }
        
        //if completionHandler != nil {
            completionHandler(cachedResponse)
       // }
        
    }
    
    /// NSURLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        SDWebImageDownloaderOperation.synchronized(anyID: self) {
            self.thread = nil
            self.dataTask = nil
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SDWebImageDownloadStopNotification), object: self)
                if error == nil{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: SDWebImageDownloadFinishNotification), object: self)
                }
            }
            
        }
        
        if error != nil {
            if self.completedBlock != nil {
                self.completedBlock!(nil,nil,error,true)
            }
        }else{
            let completionBlock = self.completedBlock
            if completionBlock != nil {
                /// URLCache 存在一个闪退
                /// 仅在应忽略缓存响应的情况下才将调用限制为“cachedResponseForRequest:” 和图片响应responseFromCached为YES的情况(仅仅是无法缓存的情况)
                /// 注意esponseFromCached在“willCacheResponse:”内设置为NO。对于大型图像或身份验证后的图像，不会调用此方法
                if self.options == nil {
                    completionBlock!(nil,nil,NSError.init(domain: SDWebImageErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey:"Image data is nil"]),true)
                    return
                }
                
                // URLRequest.init(url: URL.init(fileURLWithPath: "")默认值default
                if (self.options!.rawValue & SDWebImageDownloaderOptions.SDWebImageDownloaderIgnoreCachedResponse.rawValue ) != 0 && self.responseFromCached ?? false && (URLCache.shared.cachedResponse(for: self.request ?? URLRequest.init(url: URL.init(fileURLWithPath: ""))) != nil) {
                    completionBlock!(nil,nil,nil,true)
                }else if(self.imageData != nil){
                    var image = UIImage.sd_imageWithData(self.imageData as Data?)
                    let key = SDWebImageManager.sharedManager.cacheKeyForURL(self.request?.url ??  URL.init(fileURLWithPath: ""))
                    image =  SDScaledImageForKey(key, image)
                    /// gif 不需要解码
                    if image?.images == nil {
                        if self.shouldDecompressImages ?? true {
                           image = SDWebImageDecoder.decodedImageWithImage(image)
                        }
                       
                    }
                    
                    if (image?.size ?? CGSize(width: 0, height: 0)).equalTo(CGSize.zero) {
                         completionBlock!(nil,nil,NSError.init(domain: SDWebImageErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey:"Downloaded image has 0 pixels"]),true)
                    }else{
                        completionBlock!(image,self.imageData as Data?,nil,true)
                    }
                    
                    
                }else{
                     completionBlock!(nil,nil,NSError.init(domain: SDWebImageErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey:"Image data is nil"]),true)
                }
               
            }
            
        }
        
        self.completedBlock = nil
        done()
        
    }
    
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//
//    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //performDefaultHandling:默认的质询处理，如果有提供凭据也会被忽略，如果没有实现 URLSessionDelegate 处理质询的方法则会使用这种方式
        var disposition = URLSession.AuthChallengeDisposition.performDefaultHandling
        var  credential:URLCredential? = nil
        // NSURLAuthenticationMethodServerTrust 服务器认证证书
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if self.options != nil {
                if (self.options!.rawValue & SDWebImageDownloaderOptions.SDWebImageDownloaderAllowInvalidSSLCertificates.rawValue) == 0 {
                    disposition = URLSession.AuthChallengeDisposition.performDefaultHandling
                }else{
                    if challenge.protectionSpace.serverTrust !=  nil {
                        credential =  URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                    }
                }
            }else{
                if challenge.protectionSpace.serverTrust !=  nil {
                     credential =  URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                }
               
            }
            
        }else{
            if challenge.previousFailureCount == 0 {
                if self.credential != nil {
                    credential = self.credential
                    /// useCredential:使用指定的的凭据
                    disposition = URLSession.AuthChallengeDisposition.useCredential
                }else{
                //cancelAuthenticationChallenge:拒绝质询，并且进行下一个认证质询，如果有提供凭据也会被忽略；大多数情况不会使用这种方式，无法为某个质询提供凭据，则通常应返回 performDefaultHandling
                    disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
                }
            }else{
                disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
            }
            
        }
        
        completionHandler(disposition,credential)
        
    }
    
    
    func shouldContinueWhenAppEntersBackground() -> Bool{
        return self.options != nil && SDWebImageDownloaderOptions.SDWebImageDownloaderContinueInBackground.rawValue == 16
    }
    
    
    public class func orientationFromPropertyValue(_ value:Int) -> UIImage.Orientation
    {
        switch value {
        case 1:
            return UIImage.Orientation.up
            
        case 3:
            return UIImage.Orientation.down
        case 8:
            return UIImage.Orientation.left
        case 6:
            return UIImage.Orientation.right
        case 2:
            return UIImage.Orientation.upMirrored
        case 4:
            return UIImage.Orientation.downMirrored
        case 5:
            return UIImage.Orientation.leftMirrored
        case 7:
            return UIImage.Orientation.rightMirrored;
            
        default:
            return UIImage.Orientation.up
        }
        
        
    }
    //@synchronized 互斥锁  ==== swift
   public class func synchronized(anyID: Any, block: ()->Void) {
       objc_sync_enter(anyID)
       defer {
           objc_sync_exit(anyID)
       }
       block()
   }
    
    
    
}
