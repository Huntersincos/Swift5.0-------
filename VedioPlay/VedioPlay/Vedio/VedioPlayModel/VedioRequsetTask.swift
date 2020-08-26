//
//  VedioRequsetTask.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/24.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AVFoundation

public var vidioFileName = "viedioPath.mp4"

@objc protocol VedioRequsetTaskDlegate{
    @objc optional func task(viedio task:VedioRequsetTask,didReceiveVideoLength ideoLength:Int, mimeType:String)
    @objc optional func didReceiveVideoDataTask(_ task:VedioRequsetTask)
    @objc optional  func didFinshedViedioDataTast(_ task:VedioRequsetTask)
    @objc optional func didFailureloadingTask(_ task:VedioRequsetTask, _ failError:(NSError))
    

}

extension VedioRequsetTask{
  // swift 当中的@interface 可以用extension模拟实现
   //Extensions must not contain stored properties swift不能直接添加存储属性 stored properties
   //var url:URL?
    private struct AssociatedKey{
        static var url:URL?
    }
    
    public var url:URL{
        get{
            return objc_getAssociatedObject(self, &AssociatedKey.url) as! URL
        }
        set{
            objc_setAssociatedObject(self,&AssociatedKey.url, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

class VedioRequsetTask: NSObject,URLSessionDelegate,URLSessionDownloadDelegate,AVAssetResourceLoaderDelegate {
    
   


    // swift定义只读属性
    private(set) var path_url:URL?
    private(set) var offset_ReadOnly:Int?
    private(set) var videoLength_ReadOnly:Int?
    private(set) var  downLoadingOffset_ReadOnly:Int?
    private(set) var  mimeType_ReadOnly:String?
    var isFinishLoad:Bool?
    weak var delegate:VedioRequsetTaskDlegate?
//    var offset:Int?
//    var videoLength:Int?
    // 媒体类型
   // var mineType:String?
    var sessionRequest:URLSession?
    var downViedoTask:URLSessionDownloadTask?
    var taskArray:NSMutableArray?
   // var downLoadingOffset:Int?
    var onceAgain:Bool?
    var fileHandle:FileHandle?
    var tempPath:String?
    
    override init() {
        super.init()
        taskArray = NSMutableArray.init()
        tempPath = JRFileUtil.getDocumentPath() + "/\(vidioFileName)"
        if  FileManager.default.fileExists(atPath: tempPath ?? "") {
            try?FileManager.default.removeItem(atPath: tempPath ?? "")
            FileManager.default.createFile(atPath: tempPath ?? "", contents: nil, attributes: nil)
        }else {
            FileManager.default.createFile(atPath: tempPath ?? "", contents: nil, attributes: nil)
        }
        
    }
    
    func videoURL(_ url:URL,_ offset:Int){
        self.path_url = url
        self.offset_ReadOnly = offset
        
        if self.taskArray != nil {
            ////如果建立第二次请求，先移除原来文件，再创建新的
            if self.taskArray?.count ?? 0 > 1 {
                try?FileManager.default.removeItem(atPath: tempPath ?? "")
                FileManager.default.createFile(atPath: tempPath ?? "", contents: nil, attributes: nil)
            }
        }
        
        self.downLoadingOffset_ReadOnly = 0
        
        self.downViedoTask?.cancel()
        let actualURLComponents = NSURLComponents.init(url: url, resolvingAgainstBaseURL: false)
        actualURLComponents?.scheme = "http"
        let sessiomConfiguration  = URLSessionConfiguration.default
        sessiomConfiguration.timeoutIntervalForRequest  = 20
        sessiomConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
      // 在HTTPAdditionalHeaders额外添加的头部字段与NSURLRequest中重复了，则优先使用NSURLRequest对象中的请求头部字段。

        sessiomConfiguration.httpAdditionalHeaders = ["Range":"bytes=\(offset)-\((self.videoLength_ReadOnly ?? 1) - 1)"]
        // 默认情况最大为4 设置范围1-20 可能系统版本不同 并发数不同
        //sessiomConfiguration.httpMaximumConnectionsPerHost = 20;
        //delegate 调用完成处理程序块；如果提供了自定义的 delegate，则不会调用完成处理程序块。
       // 可以将 session 配置为后台会话，以便在 app 处于非活跃状态时继续下载数据，下载完成后唤醒 app 并提供结果。
        //sessiomConfiguration.allowsCellularAccess 是否允许使用蜂窝网络
        //sessiomConfiguration.allowsExpensiveNetworkAccess  ios13 是否使用昂贵的网络 默认yes
        //sessiomConfiguration.allowsConstrainedNetworkAccess ios13 是否需要链接受限制的网络
       // sessiomConfiguration.waitsForConnectivity 是否登录网络 默认为no 这个属性为YES，那么发起请求时就不会立马返回网络连接失败的error，而是会等待网络可用时(比如连接上了WiFi)再执行网络请求，这种情况下设置的timeoutIntervalForRequest是不生效的，而timeoutIntervalForResource是有效的
        // 可以创建多个seesion
        self.sessionRequest  = URLSession.init(configuration: sessiomConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        //URLSessionDownloadTask extends URLSessionTask
//        self.downViedoTask = self.sessionRequest?.downloadTask(with: actualURLComponents?.url ?? url, completionHandler: { (temURL, response, error) in
//
//        })
        self.downViedoTask = self.sessionRequest?.downloadTask(with: actualURLComponents?.url ?? url)
        
        self.downViedoTask?.resume()
        
    }
    
    
    func cancelVedio(){
        
        self.downViedoTask?.cancel()
        
    }
    
 
    
    
    /// URLSessionDelegate: 处理证书认证和生命周期
    /// - Parameters:
    ///   - session: <#session description#>
    ///   - challenge: <#challenge description#>
    ///   - completionHandler: <#completionHandler description#>
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        //NSURLSeesion失效时候,改方法调用
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        // 当app退到后台,会执行这个方法
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // 认证
        
        
    }
    
    

    
    /// URLSessionDownloadDelegate:处理下载任务
    /// - Parameters:
    ///   - session: <#session description#>
    ///   - downloadTask: <#downloadTask description#>
    ///   - location: <#location description#>
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
           
        // 回调的时候 不会调用这个方法 downloadTask(with: actualURLComponents?.url ?? url, completionHandler: { (temURL, response, error) in})
        
    }
    
    
    ///  恢复暂停播放
    /// - Parameters:
    ///   - session: <#session description#>
    ///   - downloadTask:开始下载任务
    ///   - fileOffset: 如果文件的 cachePolicy 或 last modified 日期阻止重用现有内容，则该值为 0  否则，该值是当前已经下载 data 的偏移量，表示磁盘上不需要再次检索的字节数 在某些情况下，可以在文件中比先前传输结束的位置更早地恢复传输。
    ///   - expectedTotalBytes: 文件的预期长度，由 Content-Length 提供；如果没有提供，则值为 NSURLSessionTransferSizeUnknown  如果一个正在下载的任务被取消或者下载失败，可以在字典 userInfo 中通过 NSURLSessionDownloadTaskResumeData 键来获取 resumeData ；随后使用 resumeData 作为 -downloadTaskWithResumeData: 或 -downloadTaskWithResumeData:completionHandler: 的入参，重新开始下载任务；一旦任务开启，URLSession 会调用该方法表明下载任务重新开始！

 
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - session: <#session description#>
    ///   - downloadTask: <#downloadTask description#>
    ///   - bytesWritten: <#bytesWritten description#>
    ///   - totalBytesWritten: <#totalBytesWritten description#>
    ///   - totalBytesExpectedToWrite: <#totalBytesExpectedToWrite description#>
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
    }
    
    
   
    
}
