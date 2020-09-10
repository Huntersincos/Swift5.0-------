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

public enum SDWebImageOptions:Int{
    //Raw value for enum case must be a literal
    /**
      默认情况下,当一个URL下载失败的时候,这个URL列入黑名单列表,下载再有这个url,就会停止请求
     */
    case SDWebImageRetryFailed = 1
    
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

typealias SDWebImageCompletionBlock = (_ image:UIImage,_ error:NSError,_ cacheType:SDWebImageOptions,_ imageURL:URL) ->Void
typealias SDWebImageCompletionWithFinishedBlock = (_ image:UIImage,_ error:NSError,_ cacheType:SDWebImageOptions,_ imageURL:URL,_ finished:Bool) ->Void
typealias SDWebImageCacheKeyFilterBlock = (_ url:URL) ->Void

@objc protocol SDWebImageManagerDelegate{
    @objc optional
    /**
      * 找不到图片,控制下载图片
        parma imageURL:当前图片链接
        return  false:       true
     */
    func imageManager(_ imageManager:SDWebImageManager, shouldDownloadImageForURL imageURL:URL) -> Bool
    /**
     
       
     */
    func imageManager(_ imageManager:SDWebImageManager,transformDownloadedImage image:UIImage,withURL imageURL:URL) ->UIImage
    
}

class SDWebImageManager: NSObject {
    weak var delegate:SDWebImageManagerDelegate?
    private(set) var imageCache: SDImageCache?
    
    override init() {
        super.init()
    }
     
    
//    convenience override init(_ cache:SDImageCache?) {
//        
//    }
}
