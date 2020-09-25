//
//  SwiftLoadImageModel.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/24.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import ImageIO
/*
 参考SDWebImage OC 3.8.2版本 纯属学习该优秀框架 不能用于任何商业行为 不建议使用 可以参考学习
  稍稍改动说明:
   1 大量使用值类型,减少引用类型
   2 不考虑NSImage
   3 不考虑条件编译
   4 使用@escaping 可能会引起循环引用,去 weak弱引用下 在闭包区域 可能会导致nil 而crash
   5 使用了很多 as ! 性能折扣
   6 不支持webp格式图片
   7 对swift进行了指针操作,安全性降低
   8 只支持iOS 8以上版本
   9 把SDNetworkActivityIndicator不考虑添加
   10 自定义使用泛型
   11 不考虑 后台加载问题 beginBackgroundTaskWithExpirationHandler swift没找到performSelector代替方案
 */

public var loadOperationKey:CChar? = 0
public var imageURLKey:CChar? = 0
public var TAG_ACTIVITY_SHOW:CChar? = 0
public var TAG_ACTIVITY_INDICATOR:CChar? = 0
public var  TAG_ACTIVITY_STYLE:CChar? = 0


extension UIImageView{
    
    /// image的图片=== url  异步 缓存
    /// - Parameter url: <#url description#>
       func sd_setImageWithURL( _ url:URL?) {
        
        self.sd_setImageWithURL(url, placeholderImage: nil, options: SDWebImageOptions.SDWebImageRetryFailed, completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) -> Void? in
                return nil
                } ) { (receivedSize:Int, expectedSize:Int64?) -> Void? in
                 return nil
             }
       }
      

    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - placeholder: placeholder description 展位图
       func sd_setImageWithURL(_ url:URL?,placeholderImage placeholder:UIImage?){
        
           self.sd_setImageWithURL(url, placeholderImage: placeholder, options: SDWebImageOptions.SDWebImageRetryFailed, completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) -> Void? in
              return nil
            }) { (receivedSize:Int, expectedSize:Int64?) -> Void? in
               return nil
           }
           
       }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - placeholder: <#placeholder description#>
    ///   - options: <#options description#>
    func sd_setImageWithURL( _ url:URL?,placeholderImage placeholder:UIImage?,options:SDWebImageOptions){
        
        self.sd_setImageWithURL(url, placeholderImage: placeholder, options: options, completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) -> Void? in
             return nil
            } ) { (receivedSize:Int, expectedSize:Int64?) -> Void? in
              return nil
          }
        
    }
    
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - completedBlock: <#completedBlock description#>
    func sd_setImageWithURL(_ url:URL?,completed completedBlock:@escaping SDWebImageCompletionBlock){
        self.sd_setImageWithURL(url, placeholderImage: nil, options: SDWebImageOptions.SDWebImageRetryFailed, completed: completedBlock) { (receivedSize:Int, expectedSize:Int64?) -> Void? in
            return nil
        }
        
    }
    
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - placeholder: <#placeholder description#>
    ///   - completedBlock: <#completedBlock description#>
    func sd_setImageWithURL( _ url:URL?,placeholderImage placeholder:UIImage?,completedBlock:@escaping SDWebImageCompletionBlock){
        self.sd_setImageWithURL(url, placeholderImage: nil, options: SDWebImageOptions.SDWebImageRetryFailed, completed: completedBlock) { (receivedSize:Int, expectedSize:Int64?) -> Void? in
           return nil
        }
        
    }
    
    
    /// 获取图片 回调 completedBlock
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - placeholder: <#placeholder description#>
    ///   - options: <#options description#>
    ///   - completedBlock: <#completedBlock description#>
    func sd_setImageWithURL( _ url:URL?,placeholderImage placeholder:UIImage?,options:SDWebImageOptions, completed completedBlock:@escaping SDWebImageCompletionBlock){
        
        self.sd_setImageWithURL(url, placeholderImage: placeholder, options: options, completed: completedBlock) { (receivedSize:Int, expectedSize:Int64?) -> Void? in
              return nil
        }
        
    }
    
    
    
    ///  获取图片   回调 progressBlock  completedBlock
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - placeholder: <#placeholder description#>
    ///   - options: <#options description#>
    ///   - completedBlock: <#completedBlock description#>
    ///   - progressBlock: <#progressBlock description#>
    func sd_setImageWithURL( _ url:URL?,placeholderImage placeholder:UIImage?,options:SDWebImageOptions, completed completedBlock: @escaping SDWebImageCompletionBlock, progress progressBlock: @escaping SDWebImageDownloaderProgressBlock){
        
        self.sd_cancelCurrentImageLoad()
        objc_setAssociatedObject(self, &imageURLKey, url, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if options.rawValue & SDWebImageOptions.SDWebImageDelayPlaceholder.rawValue == 0 {
            if Thread.isMainThread {
                self.image = placeholder ?? UIImage.init()
            }else{
                DispatchQueue.main.async {
                    self.image = placeholder ?? UIImage.init()
                }
            }
        }
        
        if url != nil {
            if self.showActivityIndicatorView {
                addActivityIndicator()
            }
            
            weak var wself = self
            let operation:Optional<SDWebImageOperation> = SDWebImageManager.sharedManager.downloadImageWithURL(url!, options, progressBlock) { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?, finished:Bool) -> Void? in
                wself?.removeActivityIndicator()
                if wself != nil{
                    if image != nil && (options.rawValue & SDWebImageOptions.SDWebImageAvoidAutoSetImage.rawValue != 0 ) {
                        completedBlock(image,error,cacheType,url)
                        return nil
                    }else if image != nil{
                        wself?.image = image
                       // 一定会调用layoutSubviews方法（有延迟，在下一轮runloop结束前）
                        wself?.setNeedsLayout()
                    }else{
                        if options.rawValue & SDWebImageOptions.SDWebImageDelayPlaceholder.rawValue != 0 {
                            wself?.image = image
                             // 一定会调用layoutSubviews方法（有延迟，在下一轮runloop结束前）
                            wself?.setNeedsLayout()
                        }
                    }
                    
                    if finished {
                         completedBlock(image, error, cacheType, url)
                    }
                }
                
                
                return nil
            }
            
            self.sd_setImageLoadOperation(operation as! NSObject, forKey: "UIImageViewImageLoad")
        }else{
            if Thread.isMainThread {
                self.removeActivityIndicator()
                completedBlock(nil, NSError.init(domain: SDWebImageErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "Trying to load a nil url"]), SDImageCacheType.SDImageCacheTypeNone, url)
            }else{
                self.removeActivityIndicator()
                 completedBlock(nil, NSError.init(domain: SDWebImageErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "Trying to load a nil url"]), SDImageCacheType.SDImageCacheTypeNone, url)
            }
        }
        
    }
    
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - placeholder: <#placeholder description#>
    ///   - options: <#options description#>
    ///   - progress: <#progress description#>
    ///   - completedBlock: <#completedBlock description#>
    func sd_setImageWithPreviousCachedImageWithURL(_ url:URL,placeholderImage placeholder:UIImage?,_ options:SDWebImageOptions, progressBlock: @escaping SDWebImageDownloaderProgressBlock, completed completedBlock: @escaping SDWebImageCompletionBlock) {
        
        let key = SDWebImageManager.sharedManager.cacheKeyForURL(url)
        let lastPreviousCachedImage = SDImageCache.sharedImageCache.imageFromDiskCacheForKey(key)
        self.sd_setImageWithURL(url, placeholderImage: (lastPreviousCachedImage != nil) ?lastPreviousCachedImage: placeholder, options: options, completed: completedBlock, progress: progressBlock)
    }
    
    func sd_imageURL() -> URL{
        let sdimage_Url = objc_getAssociatedObject(self, &imageURLKey) as! URL
        return sdimage_Url
    }
    
    
    /// 下载图像数组并在动画循环中启动它们
    /// - Parameter arrayOfURLs: <#arrayOfURLs description#>
    func sd_setAnimationImagesWithURLs(_ arrayOfURLs:Array<URL>){
        sd_cancelCurrentAnimationImagesLoad()
        let operationsArray = NSMutableArray.init()
        for logoImageURL in arrayOfURLs {
            weak var wself = self
            let operation:Optional<SDWebImageOperation> = SDWebImageManager.sharedManager.downloadImageWithURL(logoImageURL, SDWebImageOptions.SDWebImageRetryFailed, { (a:Int, b:Int64?) -> Void? in
                return nil
            }) { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?, finished:Bool) -> Void? in
                
                if wself != nil{
                    if Thread.isMainThread {
                        wself?.stopAnimating()
                        if image != nil {
                            var currentImages:NSMutableArray? = wself?.animationImages as? NSMutableArray
                                  if currentImages != nil {
                                      currentImages = NSMutableArray.init()
                                  }
                                  currentImages?.add(image!)
                                  wself?.animationImages = currentImages as? [UIImage]
                                  wself?.setNeedsLayout()
                        }
                    }else{
                        DispatchQueue.main.async {
                            wself?.stopAnimating()
                            if image != nil {
                                var currentImages:NSMutableArray? = wself?.animationImages as? NSMutableArray
                                if currentImages != nil {
                                    currentImages = NSMutableArray.init()
                                }
                                currentImages?.add(image!)
                                wself?.animationImages = currentImages as? [UIImage]
                                wself?.setNeedsLayout()
                            }
                            
                        }
                    }
                }
                
                return nil
            }
            if operation != nil {
                operationsArray.add(operation!)
            }
            
        
        }
        self.sd_setImageLoadOperation(NSArray.init(array: operationsArray) as NSObject, forKey: "UIImageViewImageLoad")
    }
    
    
    /// 取消当前下载
    func sd_cancelCurrentImageLoad(){
        self.sd_cancelImageLoadOperationWithKey("UIImageViewImageLoad")
    }
    
    /// 取消当前动画加载
    func sd_cancelCurrentAnimationImagesLoad(){
        self.sd_cancelImageLoadOperationWithKey("UIImageViewAnimationImages")
    }
      
//    func setShowActivityIndicatorView(_ show:Bool)
//    {
//        objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, NSNumber.init(value: show), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//
//    }
//
//    func showActivityIndicatorView() ->Bool{
//        let showAIndicator:NSNumber? = objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) as? NSNumber
//        return showAIndicator?.boolValue ?? false
//    }
    
    var showActivityIndicatorView:Bool{
        set(newValue){
            objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, NSNumber.init(value: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
        get{
            let showAIndicator:NSNumber? = objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) as? NSNumber
            return showAIndicator?.boolValue ?? false
        }
    }
    
    
    var activityIndicator:UIActivityIndicatorView?{
        set(newValue){
             objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get{
            let activityIndicatorView:UIActivityIndicatorView? = objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR) as? UIActivityIndicatorView
                   
            return activityIndicatorView
            
        }
    }
    
    var  indicatorStyle:UIActivityIndicatorView.Style{
        
        set(newValue){
             objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
        get{
            let styleActvityView = objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) as! UIActivityIndicatorView.Style
            return styleActvityView
        }
    }
    

    
    func addActivityIndicator(){
        
        if (self.activityIndicator == nil) {
            //var activityIndicator = self.activityIndicator()
            self.activityIndicator = UIActivityIndicatorView.init(style: self.indicatorStyle)
             //Autoresizing Mask。在使用 Auto Layout 时，首先需要将视图的 setTranslatesAutoresizingMaskIntoConstraints属性设置为 NO。这个属性默认为 YES。当它为 YES 时，运行时系统会自动将 Autoresizing Mask 转换为 Auto Layout 的约束，这些约束很有可能会和我们自己添加的产生冲突。
            // 在xib中，如果我们勾选了use auto layout，则编译器会自动帮我们关闭Autoresizing Mask，如果是使用代码添加约束，则需要手动关闭Autoresizing Mask。 setTranslatesAutoresizingMaskIntoConstraints这个方法是交给被添加约束的视图来执行的，关闭该视图的Autoresizing Mask。在添加约束前，就应该关闭该属性

            self.activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
            if Thread.isMainThread {
                self.addSubview(activityIndicator ?? UIView.init())
                self.addConstraint(NSLayoutConstraint.init(item: activityIndicator ?? UIView.init(), attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0.0))
                
                self.addConstraint(NSLayoutConstraint.init(item: activityIndicator ?? UIView.init(), attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0))
                
                
            }else{
                DispatchQueue.main.async {
                    self.addSubview(self.activityIndicator ?? UIView.init())
                    
                    self.addConstraint(NSLayoutConstraint.init(item: self.activityIndicator ?? UIView.init(), attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0.0))
                    
                    self.addConstraint(NSLayoutConstraint.init(item: self.activityIndicator ?? UIView.init(), attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0))
                }
            }
        
        }
        
        if Thread.isMainThread {
            self.activityIndicator?.startAnimating()
        }else{
            DispatchQueue.main.async {
                self.activityIndicator?.startAnimating()
            }
        }
    }
    
    func removeActivityIndicator(){
        if self.activityIndicator != nil {
            self.activityIndicator?.removeFromSuperview()
            self.activityIndicator = nil
        }
    }
    
    
       
}


extension UIView {
    
    
    func operationDictionary() -> NSMutableDictionary?{
        
        /// objc_getAssociatedObject
        var  operations:NSMutableDictionary? = objc_getAssociatedObject(self, &loadOperationKey) as? NSMutableDictionary
        if operations != nil {
            return operations
        }
        
        operations = NSMutableDictionary.init()
        objc_setAssociatedObject(self, &loadOperationKey, operations, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return operations
    }
    
    
    /// 获取UIimageView 加载图片操作
    /// - Parameters:
    ///   - operation: <#operation description#>
    ///   - key: <#key description#>
    func sd_setImageLoadOperation(_ operation:NSObject, forKey key:NSString){
        self.sd_cancelImageLoadOperationWithKey(key)
        let operationDictionary = self.operationDictionary()
        operationDictionary?.setObject(operation, forKey: key)
    }
    
    
    /// 删除当前所有view的操作
    /// - Parameter key: <#key description#>
    func sd_cancelImageLoadOperationWithKey(_ key:NSString){
        let operationDictionary = self.operationDictionary()
        let operations:NSObject? = operationDictionary?.object(forKey: key) as! NSObject?
        if operations != nil {
            if operations?.isKind(of: NSArray.self) ?? false {
                let array_operations:NSArray? = operations as? NSArray
                for item in array_operations ?? NSArray.init() {
                    let operation:Optional<SDWebImageOperation> =  item as? SDWebImageOperation
                    if operation != nil {
                        operation?.cancel()
                    }
                    
                }
                
            }else if(/**operations?.conforms(to:protocol(SDWebImageOperation)) ?? **/ false){
                 let operation:Optional<SDWebImageOperation> =  operations as? SDWebImageOperation
                if operation != nil {
                    operation?.cancel()
                }
                
            }
            
            operationDictionary?.removeObject(forKey: key)
        }
        
    }
    
    
    
    /// 只需删除与当前UIView和key对应的操作，而不取消它们
    /// - Parameter key: <#key description#>
    func sd_removeImageLoadOperationWithKey(_ key:String){
        let operationDictionary = self.operationDictionary()
        operationDictionary?.removeObject(forKey: key)
    }
    
    
}

//extension String:CustomStringConvertible
//{
//    public var description: String {
//
//    }
//
//
//}

extension String{
    /// 将任一字符串转换为英文字母字符串
       func toLetters() -> String {

           let mutableString = NSMutableString(string: self)
           // 应用 kCFStringTransformToLatin 变换将所有非英文文本转换为拉丁字母表示。
           CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
           // 应用 kCFStringTransformStripCombiningMarks 变换来去除变音符和重音。
           CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)

           // 使用CFStringLowercase缩减文本的大小，并使用CFStringTokenizer将文本拆分为标记，以用作文本的索引。
           let tokenizer = CFStringTokenizerCreate(nil, mutableString, CFRangeMake(0, CFStringGetLength(mutableString)), 0, CFLocaleCopyCurrent())

           var mutableTokens: [String] = []
           var type: CFStringTokenizerTokenType
           repeat {
               type = CFStringTokenizerAdvanceToNextToken(tokenizer)
               let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
               let token = CFStringCreateWithSubstring(nil, mutableString, range) as NSString
               mutableTokens.append(token as String)
           } while type != []

           //生成最终字符串
           let joined = mutableTokens.joined()

           return joined

       }
    
}

 

extension UIImage{
    
  class func sd_imageWithData(_ data:Data?) -> UIImage?{
    if data == nil {
        return nil
    }
    var image:UIImage? = nil
    let imageContentType =  Data.sd_contentTypeForImageData(data! as NSData)
    if imageContentType == "image/gif" {
        image = UIImage.sd_animatedGIFWithData(data)
   // #ifdef SD_WEBP
    }else if imageContentType == "image/webp"{
        //image = UIImage.sd_imageWithWebPData
    }else{
        image = UIImage.init(data: data!)
        let orientation = sd_imageOrientationFromImageData(data ?? Data.init())
        if orientation != UIImage.Orientation.up {
            if image != nil {
                image = UIImage.init(cgImage: (image?.cgImage)!, scale: image?.scale ?? 0, orientation: orientation)
            }
           
        }
        
    }
     return image
  }
    
    class func sd_animatedGIFWithData(_ data:Data?) -> UIImage?{
        guard let source = CGImageSourceCreateWithData(data! as CFData, nil) else { return  UIImage.init() }
        let count = CGImageSourceGetCount(source)
        var animatedImage:UIImage? = nil
        if count <= 1 {
            animatedImage = UIImage.init(data: data ?? Data.init())
        }else{
            var images = [UIImage]()
            var duration:TimeInterval = 0.0
            var i = 0
            for _  in 0..<count {
                let image = CGImageSourceCreateImageAtIndex(source, i, nil)
                if image == nil {
                    continue
                }
                duration += TimeInterval(sd_frameDurationAtIndex(i, source))
                images.append(UIImage.init(cgImage: image! , scale: UIScreen.main.scale, orientation: UIImage.Orientation.up))
                i += 1
                //'CGImageRelease' is unavailable: Core Foundation objects are automatically memory managed
              //  CGImageRelease(image!)
        
            }
            
            if duration == 0.0 {
                duration = TimeInterval(count/10)
            }
            
            animatedImage = UIImage.animatedImage(with: images, duration: duration)
        }
        
        return animatedImage
        
    }
    
    class func sd_frameDurationAtIndex(_ index:Int ,_ source:CGImageSource) -> Float{
        var frameDuration:Float = 0.1
        // 获取图片字典
        let cfFrameProperties:CFDictionary = CGImageSourceCopyProperties(source, nil)!
        let frameProperties =  cfFrameProperties as Dictionary
        //
        let gifProperties = frameProperties[kCGImagePropertyGIFDictionary]
        //
        let delayTimeUnclampedProp:NSNumber? = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber
        if (delayTimeUnclampedProp != nil) {
            frameDuration = delayTimeUnclampedProp?.floatValue ?? 0.1
            
        }else{
            let delayTimeProp:NSNumber? = gifProperties?[kCGImagePropertyGIFDelayTime] as? NSNumber
            if (delayTimeProp != nil) {
                frameDuration = delayTimeProp?.floatValue ?? 0.1
            }
        }
        // 有些广告图片设置duration为0 会出现闪烁
        // 遵循Firefox的性能,使用duration==100ms的任何框架
        if frameDuration < 0.011 {
            frameDuration = 0.1
        }
        
       // CFRelease(cfFrameProperties)
       return frameDuration
    }
    
    class func sd_imageOrientationFromImageData(_ imageData:Data) -> UIImage.Orientation{
        var result = UIImage.Orientation.up
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)
        if (imageSource != nil) {
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)
            if (properties != nil) {
                //let val:CFTypeRef
                var exifOrientation:Int?
                ///
                let key = Unmanaged.passRetained(kCGImagePropertyOrientation).autorelease().toOpaque()
                let val = CFDictionaryGetValue(properties, key)
                if (val != nil) {
                    //kCFNumberIntType
                    CFNumberGetValue((val as! CFNumber), CFNumberType.intType, &exifOrientation)
                    result = sd_exifOrientationToiOSOrientation(exifOrientation ?? 1)
                }
                
            }
        }
         return  result
    }

    
    /// 将EXIF图像方向转换为iOS图像方向。
    /// - Parameter exifOrientation: <#exifOrientation description#>
    class func sd_exifOrientationToiOSOrientation(_ exifOrientation:Int) -> UIImage.Orientation{
        var orientation = UIImage.Orientation.up
        switch exifOrientation {
        case 1:
            orientation = UIImage.Orientation.up
            break
        case 3:
            orientation = UIImage.Orientation.down
            break
        case 8:
            orientation = UIImage.Orientation.left
            break
        case 6:
            orientation = UIImage.Orientation.right
            break
        case 2:
            orientation = UIImage.Orientation.upMirrored
            break
        case 4:
            orientation = UIImage.Orientation.downMirrored
            break
        case 5:
            orientation = UIImage.Orientation.leftMirrored
            break
        case 7:
            orientation = UIImage.Orientation.rightMirrored
            break
        default:
            break
        }
        
        return orientation
    }
    
   
}

extension Data{
    
    static func sd_contentTypeForImageData(_ data:NSData) ->String?{
        //   swift ===> unsigned char === CUnsignedChar === UInt8 在这里都可以的
        //var c_byte:UInt8?
        var c_byte:CUnsignedChar?
        
        /**
          检测内存:MemoryLayout<T>
             1 T size 内存实际大小
             2  alignment 内存对齐大小
             3  stride  T实际占有的内存大小
          UnsafePointer:一旦操作了内存,编译器不会对这种操作进行操作,需要对自己行为承担责任
         */
//        let stride = MemoryLayout<UInt8>.stride
//        let aligment = MemoryLayout<UInt8>.alignment
//        let byteCount = stride * Int(c_byte)
        //data.getBytes(UnsafeMutableRawPointer.allocate(byteCount: <#T##Int#>, alignment: <#T##Int#>)
        //data.getBytes(UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: aligment), length: 1)
        //let imgeData:NSData? = data
        data.getBytes(&c_byte, length: 1)
       // imgeData?.getBytes(&c_byte, length: 1)
        /**
          switch c_byte {
              case 0xFF:
              break
              default: break
         
         */
        if c_byte == 0xFF {
            return "image/jpeg"
        }else if c_byte == 0x89{
            return "image/png"
        }else if c_byte == 0x47{
            return "image/gif"
        }else if c_byte == 0x49 || c_byte == 0x4D{
            return "image/tiff"
        }else if c_byte == 0x52{
            if data.length < 12 {
                return nil
            }
            let testString = NSString.init(data: data.subdata(with: NSRange.init(location: 0, length: 12)), encoding:String.Encoding.ascii.rawValue)
            if  testString?.hasPrefix("RIFF") ?? false || testString?.hasPrefix("WEBP") ?? false {
                return "image/webp"
            }
            
        }
        return nil
    }
    
    
    
    
}





class SwiftLoadImageModel: NSObject {
    //Declaration is only valid at file scope
   

    

    
}



