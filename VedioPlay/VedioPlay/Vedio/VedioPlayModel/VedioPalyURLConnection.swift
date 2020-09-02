//
//  VedioPalyTastkDown.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/24.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AVFoundation
//为所有应用提供基础服务,此框架定义底层UTIs使用类型
import MobileCoreServices
@objc protocol VedioPalyTastkDownDelegate{
    func didFinishLoadingWithTask(_ task:VedioPalyURLConnection)
    func didFailLoadingWithTask(_ task:VedioPalyURLConnection ,errorCode:Int)
}

class VedioPalyURLConnection: URLSession,AVAssetResourceLoaderDelegate,VedioRequsetTaskDlegate {
    var task:VedioRequsetTask?
    weak var downDelegate:VedioPalyTastkDownDelegate?
    var pendingRequests = [AVAssetResourceLoadingRequest]()
    var videoPath:String?
    
    override init() {
        super.init()
        videoPath = JRFileUtil.getDocumentPath() + "/\(vidioFileName)"
        
    }
    
    func fillInContentInformation(_ contentInformationRequest:AVAssetResourceLoadingContentInformationRequest?) {
        let mimeType = self.task?.mimeType_ReadOnly
        
        /// 把扩展名转化为UTL字符串 string-CFString  注意空的情况
        //CFGetTypeID
        if mimeType != nil {
           let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType! as CFString, nil)
            /// 是否对资源的任意字节范围进行随机访问,这种支持还允许一部分资源被多次请求
            /// 论述:当加载完成VAssetResourceLoading之前 如果contentInformationRequest不为空,     如果要对任意arbitary资源随机访问则应该把这个属性设置为true,如果不设置,则会出现加载失败情况,这样资源报考任何多媒体数据
            contentInformationRequest?.isByteRangeAccessSupported = true
            /// 请求资源包含的任意数据    Unmanaged<CFString>-- string takeUnretainedValue
            contentInformationRequest?.contentType = contentType?.takeUnretainedValue() as String?
            //Cannot assign value of type 'Int?' to type 'Int64'
            contentInformationRequest?.contentLength  =  self.task?.videoLength_ReadOnly ?? 0
            
            
        }
        
    }
    
    func processPendingRequests(){
        var requestsCompleted = [AVAssetResourceLoadingRequest]()
        for loadingRequest in pendingRequests {
            fillInContentInformation(loadingRequest.contentInformationRequest)
            //let didRespondCompletely =
        }
        
        
    }
    
    func respondWithDataForRequest(_ dataRequest:AVAssetResourceLoadingDataRequest) -> Bool{
        var startOffset = dataRequest.requestedOffset
        if dataRequest.currentOffset != 0 {
            startOffset = dataRequest.currentOffset
        }
        if (self.task?.offset_ReadOnly ?? 0) + (self.task?.downLoadingOffset_ReadOnly ?? 0) < startOffset {
            return false
        }
        // Int + > Int64
        if  (self.task?.offset_ReadOnly ?? 0) +  0 > startOffset {
            return false
        }
        //mappedIfSafe 在内存满情况 安全问题
        let filedata = try?Data.init(contentsOf: URL.init(fileURLWithPath: videoPath ?? ""), options: .mappedIfSafe)
        let downLoadingOffset:Int64 = Int64(self.task?.downLoadingOffset_ReadOnly ?? 0)
        let offsetOnly:Int64 = Int64(self.task?.offset_ReadOnly ?? 0)
        let unreadBytes:Int64 = downLoadingOffset - startOffset - offsetOnly
        let numberOfBytesToRespondWith = min(dataRequest.requestedLength, Int(unreadBytes))
        dataRequest.respond(with: filedata?.subdata(in: Range.init(NSRange.init(location: Int(startOffset) - (self.task?.offset_ReadOnly ?? 0), length: numberOfBytesToRespondWith)) ?? Range.init(NSRange.init())!) ?? Data.init())
        let endOffset:Int64 = startOffset + Int64(dataRequest.requestedLength)
        let didRespondFully = (offsetOnly + downLoadingOffset) >= endOffset
        return didRespondFully
    }
    
}
