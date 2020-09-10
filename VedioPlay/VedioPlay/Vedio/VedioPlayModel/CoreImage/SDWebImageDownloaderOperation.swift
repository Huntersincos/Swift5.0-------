//
//  SDWebImageDownloaderOperation.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/7.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
public var SDWebImageDownloadStartNotification = "SDWebImageDownloadStartNotification"
class SDWebImageDownloaderOperation: Operation,SDWebImageOperation,URLSessionDataDelegate,URLSessionTaskDelegate {
    
    /// request:操作任务的响应
    private(set) var request:URLRequest?
    
    /// 任务
    private(set) var dataTask:URLSessionTask?
    var shouldDecompressImages:Bool?
    
    /// 过期属性 __deprecated_msg swift
    @available(*, deprecated, message: "Property deprecated. Does nothing. Kept only for backwards compatibility 属性已经废弃,属性已弃用。什么都不做。仅为向后兼容而保留")
    var shouldUseCredentialStorage:Bool?
    
    var credential:URLCredential?
    private(set) var options:SDWebImageDownloaderOptions?
    /// 预测数据 expected大小
    var expectedSize:Int?
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
    var size_t:sig_t?
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
    
    func shouldContinueWhenAppEntersBackground() -> Bool{
        return self.options != nil && SDWebImageDownloaderOptions.SDWebImageDownloaderContinueInBackground.rawValue == 16
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
