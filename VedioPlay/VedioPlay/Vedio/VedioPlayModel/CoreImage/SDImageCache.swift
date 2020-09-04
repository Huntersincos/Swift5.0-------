//
//  SDImageCache.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/25.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import CommonCrypto


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

typealias SDWebImageQueryCompletedBlock = (_ image:UIImage?,_ cacheType:SDImageCacheType) ->Void
typealias SDWebImageCheckCacheCompletionBlock = (_ isInCache:Bool) -> Void
typealias SDWebImageCalculateSizeBlock = (_ fileCount:Int, _ totalSize:Int) ->Void
typealias SDWebImageNoParamsBlock = () -> Void?
// oc ====> @interface ==== @implementation Swift 实现
//extension NSCache{
//
//    /// NSCache 1 线程安全 2 当内存缓存不足时,NSCache会自动释放 3 设置缓存缓存对象占用的内存大小,当超过会自动释放
//   @objc func recevieCacheWarning(){
//     NotificationCenter.default.addObserver(self, selector: #selector(removeAllObjects), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
//   }
//    // 无法调用
//    @objc func relase(){
//        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
//    }
//
//}

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
    var _maxMemoryCost:Int?
    
    /**
     内存中缓存对象总数
    */
    var _maxMemoryCountLimit:Int?
    
    /**
         缓存大小,单位字节
    */
    var maxCacheAge:Int?
    
    /**
      将图像保存在缓存中的最大时间长度
    */
    var maxCacheSize:Int?
    var memCache:AutoPurgeCache?
    var diskCachePath:String?
    
    /// 不可变array
    //var customPaths:[String]?
    
    /// 可变array
    var customPaths = [String]()
    
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
        
        memCache = AutoPurgeCache.init()
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
        
//        #if TARGET_OS_IOS
//        NotificationCenter.default.addObserver(self, selector: #selector(clearMemory), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
//        // 程序终止/终止
//        NotificationCenter.default.addObserver(self, selector: #selector(cleanDisk), name: UIApplication.willTerminateNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(backgroundCleanDisk), name: UIApplication.didEnterBackgroundNotification, object: nil)
//        #else
        
         NotificationCenter.default.addObserver(self, selector: #selector(clearMemory), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
         // 程序终止/终止
         NotificationCenter.default.addObserver(self, selector: #selector(cleanDisk), name: UIApplication.willTerminateNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(backgroundCleanDisk), name: UIApplication.didEnterBackgroundNotification, object: nil)
       // #endif
        
    }
    
    
    /// 添加只读缓存路径以搜索由SimigaCache预缓存的图像  如果app和预加载图象捆绑在一起这个方法非常有用
    /// - Parameter path: 只读缓存路径
    func addReadOnlyCachePath(_ path:String){
        
        if  self.customPaths.contains(path) {
            self.customPaths.append(path)
        }
        
    }
    
    /// 获取特定秘钥的缓存路径 (需要缓存路径的根文件夹)
    /// - Parameters:
    ///   - key: <#key description#>
    ///   - path: <#path description#>
    func cachePathForKey(_ key:String,_ path:String) ->String
    {
        return "\(path)/" + cachedFileNameForKey(key)
    }
    
    /// 获取某个秘钥的缓存路径
    /// - Parameter key: <#key description#>
    func defaultCachePathForKey(_ key:String) ->String
    {
        return cachePathForKey(key, self.diskCachePath ?? "")
    }
    
    
    /// 将图片存储内存中,或者在给定的键处选择磁盘缓存
    /// - Parameters:
    ///   - image: <#image description#>
    ///   - recalculate: 是否使用imageData 或者使用uiimage构造数据
    ///   - imageData: 服务端返回的图像数据  这个用于磁盘存储
    ///   - key: 唯一key,通常是图片ur的absolute
    ///   - toDisk: 值为ture:图片存储在磁盘中
    func storeImage(_ image:UIImage?,recalculateFromImage recalculate:Bool,imageData:Data?,forKey key:String?,toDisk:Bool){
        if image == nil && key == nil{
           return
        }
        if self.shouldCacheImagesInMemory ?? false{
            let cost = SDCacheCostForImage(image ?? UIImage.init())
            // as
            self.memCache?.setObject(image ?? UIImage.init(), forKey: key! as NSString, cost: cost)
        }
        
        if toDisk{
            ioQueue?.async {
                if image != nil && (recalculate || imageData == nil){
                    // 确认是png jpeg
                    // png特征唯一,容易检测出
                    // png图片文件包括8个字节的十进制:137 80 78 71 13 10 26 10
                    // 如果imageData为空 也就是如果尝试直接保存UIImage或在下载时对图像进行了转换
                    // 而且图像有一个alpha通道，会考虑它的png以避免失去透明度
                   // #if TARGET_OS_IPHONE
                    // iphone
                    var data = imageData
                    let alphaInfo = image?.cgImage?.alphaInfo
                    var hasAlpha = !(alphaInfo == CGImageAlphaInfo.none || alphaInfo == CGImageAlphaInfo.noneSkipLast || alphaInfo ==  CGImageAlphaInfo.noneSkipFirst)
                    //Binary operator '>=' cannot be applied to two 'Int?' operands
                    // ?????
                    if Int(imageData?.count ?? 0 ) >= Int(kPNGSignatureData?.count ?? 0){
                        hasAlpha = ImageDataHasPNGPreffix(imageData ?? Data.init())
                    }
                    if hasAlpha {
                        data = image?.pngData()
                    }else{
                        data = image?.jpegData(compressionQuality: 1.0)
                    }
                   // #else
                       // mac
                    //data = NSBitmapImageRep.
                    
                    self.storeImageDataToDisk(data, forKey: key ?? "")
                   // #endif
                }
            }
        }
        
        
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - image: <#image description#>
    ///   - key: <#key description#>
    func storeImage(_ image:UIImage,forkey key:String){
        storeImage(image, recalculateFromImage: true, imageData: nil, forKey: key, toDisk: true)
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - image: <#image description#>
    ///   - key: <#key description#>
    ///   - toDisk: <#toDisk description#>
    func storeImage(_ image:UIImage,forkey key:String, toDisk:Bool){
        storeImage(image, recalculateFromImage: true, imageData: nil, forKey: key, toDisk: toDisk)
    }
    
    
    /// 将Image的Data 存储到指定密钥的磁盘缓存中
    /// - Parameters:
    ///   - imageData: <#imageData description#>
    ///   - key: <#key description#>
    func storeImageDataToDisk(_ imageData:Data?,forKey key:String){
        
        if imageData == nil{
            return
        }
        if fileManager?.fileExists(atPath: diskCachePath ?? "") == false {
            try?fileManager?.createDirectory(atPath: diskCachePath ?? "", withIntermediateDirectories: true, attributes: nil)
        }
        
        // 获取图片秘钥缓存路径
        let cachePathForKey = defaultCachePathForKey(key)
        let fileURL = NSURL.init(fileURLWithPath: cachePathForKey)
        fileManager?.createFile(atPath: cachePathForKey, contents: imageData, attributes: nil)
        if self.shouldDisableiCloud ?? false {
            //NSURLIsExcludedFromBackupKey 不需要iCloud备份
            try?fileURL.setResourceValue(NSNumber.init(value: true), forKey: .isExcludedFromBackupKey)
            
        }
        
    }
    
    
    /// 检查磁盘缓存中是否已存在image（不加载image）
    /// - Parameter key: url
    /// -- return  if true  存在图片秘钥key
    func diskImageExistsWithKey(_ key:String) -> Bool {
        
        var exists = false
        // 在ioQueue之外的另一个队列上访问filemanager是一个例外，但是我们使用的是共享实例
        // 通过Appl对FileManager描述: 可以通过多个线程分享调用FileManager对象是安全的
        exists = FileManager.default.fileExists(atPath: defaultCachePathForKey(key))
        // 因为https://github.com/rs/SDWebImage/pull/976将扩展名添加到磁盘文件名
        // 检查key带不带扩展文件名
        if exists == false {
            // stringByDeletingPathExtension 删除路径中最后一部分 ?????
            let stringByDeleting:NSString =  defaultCachePathForKey(key) as NSString
            exists =  FileManager.default.fileExists(atPath: stringByDeleting.deletingPathExtension)
        }
        
        
        return exists
        
        
    }
    
    
    /// 异步检查图片是否已经缓存到磁盘中
    /// - Parameters:
    ///   - key: <#key description#>
    ///   - completionBlock: <#completionBlock description#>
    func diskImageExistsWithKey(_ key:String, completion completionBlock: @escaping SDWebImageCheckCacheCompletionBlock){
        //Escaping closure captures non-escaping parameter 'completionBlock'
        //新版的Swift闭包做参数默认是@noescaping，不再是@escaping。如果函数里执行该闭包，要添加@escaping。
        //escaping生命周期 1 escaping的生命周期长于函数  2 escaping引用仍被其他对象持有,不会在函数结束后释放 会引起循环引用
        // noescaping :函数结束前被调用 生命周期在函数内 不会引起循环引用 开发中使用noescaping 有助于性能优化
        ioQueue?.async {
            var exists = self.fileManager?.fileExists(atPath: self.defaultCachePathForKey(key))
            if exists == false{
                let stringByDeleting:NSString =  self.defaultCachePathForKey(key) as NSString
                exists =  self.fileManager?.fileExists(atPath: stringByDeleting.deletingPathExtension)
            }
            DispatchQueue.main.async {
                completionBlock(exists ?? false)
            }
           
        }
    }
    
    
    /// 同步内存缓存队列
    /// - Parameter key: <#key description#> return 返回内存缓存的图片
    func imageFromMemoryCacheForKey(_ key:String) ->UIImage?{
        
        return self.memCache?.object(forKey: key as NSString) as? UIImage
    }
    
    
    /// 检测内存内存缓存后在同步检测磁盘缓存
    /// - Parameter key: <#key description#>
    func imageFromDiskCacheForKey(_ key:String) ->UIImage{
        var image = imageFromMemoryCacheForKey(key)
        if image != nil {
            return image ?? UIImage.init();
        }
        image = diskImageForKey(key)
        if image != nil && self.shouldCacheImagesInMemory ?? false {
            let  cost = SDCacheCostForImage(image ?? UIImage.init())
            self.memCache?.setObject(image ?? UIImage.init(), forKey: key as NSString, cost: cost)
        }
        return image ?? UIImage.init()
    }
    
    
    //磁盘缓存获取图片
    func  diskImageForKey(_ key:String) -> UIImage?{
        let data = diskImageDataBySearchingAllPathsForKey(key)
        if data != nil {
            var image = UIImage.sd_imageWithData(data)
            image = scaledImageForKey(key, image ?? UIImage.init())
            if shouldDecompressImages ?? true {
                image = SDWebImageDecoder.decodedImageWithImage(image)
            }
            return image
        }
        return nil
    }
    
    private func scaledImageForKey(_ key:String,_ image:UIImage) -> UIImage{
        return SDScaledImageForKey(key, image) ?? UIImage.init()
    }
    
    func diskImageDataBySearchingAllPathsForKey(_ key:String) -> Data?{
        let defaultPath = defaultCachePathForKey(key)
        ///
        let data = defaultPath.data(using: .utf8)
        if data != nil {
            return data
        }
        for path in self.customPaths {
            let filePath = cachePathForKey(key, path)
            var imageData = filePath.data(using: .utf8)
            if (imageData != nil) {
                return imageData
            }
            let ns_filePath = filePath as NSString
            imageData = ns_filePath.deletingPathExtension.data(using: .utf8)
            if imageData != nil {
                return imageData
            }
        }
        
        return nil
    }
    
    
    /// 查询query磁盘缓存同步
    /// - Parameters:
    ///   - key: <#key description#>
    ///   - doneBlock: <#doneBlock description#>
    func queryDiskCacheForKey(key:String?, doneBlock:@escaping SDWebImageQueryCompletedBlock) -> Operation?{
//        if (doneBlock == nil) {
//            return nil
//        }
//
        if key ==  nil {
            doneBlock(nil,SDImageCacheType.SDImageCacheTypeNone)
            return nil
        }
        
        let image = imageFromMemoryCacheForKey(key ?? "")
        if (image != nil) {
            doneBlock(image,SDImageCacheType.SDImageCacheTypeMemory)
            return nil
        }
        
        let operation = Operation.init()
        ioQueue?.async {
            if operation.isCancelled{
                return
            }
            //@autoreleasepool
            let diskImage = self.diskImageForKey(key ?? "")
            if diskImage != nil && self.shouldCacheImagesInMemory ?? false{
                let cost = SDCacheCostForImage(diskImage ?? UIImage.init())
                if key != nil {
                     self.memCache?.setObject(diskImage ?? UIImage.init(), forKey: key! as NSString , cost: cost)
                }
            }
            
            DispatchQueue.main.async {
                doneBlock(diskImage,SDImageCacheType.SDImageCacheTypeDisk)
            }
        
        }
        
        
        return operation

    }
    
    
    /// 移除同步图片的磁盘和内存缓存
    /// - Parameter key: <#key description#>
    func removeImageForKey(_ key:String){
        removeImageForKey(key) { () -> Void? in
            return nil
        }
    }
    
    
    /// 移除同步图片的磁盘和内存缓存
    /// - Parameters:
    ///   - key:
    ///   - completion:执行块 可选
    func removeImageForKey(_ key:String , withCompletion completion:@escaping SDWebImageNoParamsBlock){
        removeImageForKey(key, fromDisk: true) { () -> Void? in
            return completion()
        }
        
    }
    
    
    /// 移除图片内存缓存和磁盘缓存(可选的)
    /// - Parameters:
    ///   - key: <#key description#>
    ///   - fromDisk: <#fromDisk description#>
    func removeImageForKey(_ key:String,fromDisk:Bool){
        removeImageForKey(key, fromDisk: fromDisk) { () -> Void? in
            return nil
        }
    }
    func removeImageForKey(_ key:String?,fromDisk:Bool, withCompletion  completion: @escaping SDWebImageNoParamsBlock){
        if key == nil {
            return
        }
        if shouldCacheImagesInMemory ?? true {
            self.memCache?.removeObject(forKey: key! as NSString)
        }
        if fromDisk {
            ioQueue?.async {
                try?self.fileManager?.removeItem(atPath: self.defaultCachePathForKey(key ?? ""))
               // if completion != nil{
                    DispatchQueue.main.async {
                        completion()
                    }
               // }
                
            }
        
        }else{
           // if completion != nil{
                DispatchQueue.main.async {
                    completion()
                }
            //}
        }
    }
    
    var maxMemoryCost:Int{
        set{
            _maxMemoryCost = newValue
        }
        get{
            /// totalCostLimit 内存大小 全局缓存实例时如果设置了totalCostLimit必然存储缓存的方法调用必然带上了cost，否则
            return self.memCache?.totalCostLimit ?? 0
        }
    }
    
    var  maxMemoryCountLimit:Int{
        set{
            _maxMemoryCountLimit = newValue
        }
        get{
            return self.memCache?.countLimit ?? 0
        }
    }
    
    
    func makeDiskCachePath(fullNamespace:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return paths[0] + "/\(fullNamespace)"
    }
    
    @objc func clearMemory()  {
        self.memCache?.removeAllObjects()
    }
    
     /// 移除磁盘过期的缓存 expired
    @objc func cleanDisk(){
        cleanDiskWithCompletionBlock { () -> Void? in
            return nil
        }
    }
    
    
    /// 移除磁盘过期的缓存 expired
    /// - Parameter completion: <#completion description#>
    func cleanDiskWithCompletionBlock(_ completion: @escaping SDWebImageNoParamsBlock ){
         ioQueue?.async {
            let diskCacheURL = URL.init(fileURLWithPath: self.diskCachePath ?? "", isDirectory: true)
            let resourceKeys = [URLResourceKey.isDirectoryKey,URLResourceKey.contentModificationDateKey,URLResourceKey.totalFileAllocatedSizeKey]
            //Ambiguous reference to member 'fileManager'
           
            let fileEnumerator = self.fileManager?.enumerator(at: diskCacheURL, includingPropertiesForKeys: resourceKeys, options: .skipsHiddenFiles, errorHandler: nil)
            //timeIntervalSinceNow
            let expirationDate = Date.init(timeIntervalSinceNow:-TimeInterval(self.maxCacheAge ?? 0))
            var currentCacheSize = 0
            let cacheFiles = NSMutableDictionary.init()
            // 1  移除所有过去文件
            // 2 存储删除的过期文件
            var urlsToDelete = [NSURL]()
            
            if fileEnumerator == nil{
                return
            }
            for fileURL in fileEnumerator! {
                let  fileURL_ResourceValues = fileURL as! NSURL
                let  resourceValues = try? fileURL_ResourceValues.resourceValues(forKeys: resourceKeys)
                if ((resourceValues?[URLResourceKey.isDirectoryKey]) != nil) {
                    let isKey:NSNumber = resourceValues?[URLResourceKey.isDirectoryKey] as! NSNumber
                    if isKey.boolValue {
                        continue
                    }
                }
                
                let  modificationDate:NSDate = resourceValues?[URLResourceKey.contentModificationDateKey] as! NSDate
                if modificationDate.laterDate(expirationDate) == expirationDate {
                    urlsToDelete.append(fileURL_ResourceValues)
                    continue
                }
                
                let totalAllocatedSize:NSNumber = resourceValues?[URLResourceKey.totalFileAllocatedSizeKey] as! NSNumber
                currentCacheSize += Int(totalAllocatedSize.uintValue)
                if (resourceValues != nil) {
                     cacheFiles.setObject(resourceValues!, forKey: fileURL_ResourceValues)
                }
            }
            
            for fileURL in urlsToDelete{
               try?self.fileManager?.removeItem(at: fileURL as URL)
            }
            
            // 如果剩余磁盘缓存超过配置大小,请执行第二次
            // 基于大小的清理过程,我们先删除最旧的文件
            if self.maxCacheSize ?? 0 > 0 && currentCacheSize > self.maxCacheSize ?? 0{
                // 清理缓存大小一半
                let desiredCacheSize = (self.maxCacheSize ?? 0)/2
                // 按最早修改的文件,对剩余的缓存文件进行排序
                //   首先concurrent，是“并发的，一致的，同时发生的”，stable，是“稳定的”。
                let sortedFiles = cacheFiles.keysSortedByValue(options: NSSortOptions.concurrent) { (obj1:Any, obj2:Any) -> ComparisonResult in
                    let objOne = obj1 as! [URLResourceKey:Any]
                    let objTwo = obj2 as! [URLResourceKey:Any]
                    let objOneDate = objOne[URLResourceKey.contentModificationDateKey] as! NSDate
                    let objTwoDate = objTwo[URLResourceKey.contentModificationDateKey] as! NSDate
                    return objOneDate.compare(objTwoDate as Date)
                }
                // 删除文件只到低于所需缓存的大小
                for fileURL in sortedFiles {
                    if((try?self.fileManager?.removeItem(at: fileURL as! URL)) != nil) {
                       let resourceValues = cacheFiles[fileURL] as! [URLResourceKey:Any]
                        let totalAllocatedSize = resourceValues[URLResourceKey.fileAllocatedSizeKey] as! NSNumber
                        currentCacheSize -= Int(totalAllocatedSize.uintValue)
                        if currentCacheSize < desiredCacheSize {
                            break
                        }
                    }
                }
                
               
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
        
    }
    
    
    /// 异步清理磁盘缓存
    /// - Parameter completion: 非阻塞方法 立刻返回
    func clearDiskOnCompletion(_ completion:@escaping SDWebImageNoParamsBlock){
        self.ioQueue?.async {
            try?self.fileManager?.removeItem(atPath: self.diskCachePath ?? "")
            try?self.fileManager?.createDirectory(atPath: self.diskCachePath ?? "", withIntermediateDirectories: true, attributes: nil)
           // if completion != nil{
            DispatchQueue.main.async {
                completion()
            }
           // }
        }
    }
    
    func clearDisk(){
        clearDiskOnCompletion { () -> Void? in
          return nil
        }
    }
    
    @objc func backgroundCleanDisk(){
        let applicationClass = NSClassFromString("UIApplication") as! UIApplication.Type
        if  !applicationClass.responds(to: #selector(getter: UIApplication.shared)) {
            return
        }
        _ = UIApplication.perform(#selector(getter: UIApplication.shared))
        var bgTask = UIApplication.shared.beginBackgroundTask {
            //Variable used within its own initial value
//            UIApplication.shared.endBackgroundTask(bgTask)
//            bgTask = UIBackgroundTaskInvalid
        }
        cleanDiskWithCompletionBlock { () -> Void? in
            UIApplication.shared.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskIdentifier.invalid
            return nil
        }
        
    }
    
    
    /// 获取已经使用的磁盘缓存大小
    func getSize() -> UInt64{
        var size:UInt64 = 0
        ioQueue?.async {
            let fileEnumerator = self.fileManager?.enumerator(atPath: self.diskCachePath ?? "")
            if fileEnumerator == nil{
                return
            }
            for fileName in fileEnumerator!{
                let  filePath = (self.diskCachePath ?? "") + "\(fileName)"
                let  attrs = try?FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
                if attrs != nil {
                     size += attrs!.fileSize()
                }
               
            }
            
        }
        return size
    }
    
    
    /// 获取磁盘图片大小
    func getDiskCount() -> Int{
      var count:Int = 0
        ioQueue?.async {
           let fileEnumerator = self.fileManager?.enumerator(atPath: self.diskCachePath ?? "")
           if fileEnumerator == nil{
               return
           }
            count += fileEnumerator?.allObjects.count ?? 0
        }
        
        return count
    }
    
    
    /// 异步计算磁盘大小
    /// - Parameter completionBlock: <#completionBlock description#>
    func calculateSizeWithCompletionBlock(_ completionBlock: @escaping SDWebImageCalculateSizeBlock){
        let diskCacheURL =  URL.init(fileURLWithPath: self.diskCachePath ?? "", isDirectory: true)
        ioQueue?.async {
            var fileCount = 0
            var totalSize = 0
            let fileEnumerator = self.fileManager?.enumerator(at: diskCacheURL, includingPropertiesForKeys: [URLResourceKey.fileSizeKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles, errorHandler: nil)
            if fileEnumerator == nil{
                return
            }
            for fileURL in fileEnumerator!{
                var fileSize:NSNumber? = nil ;
                let fileURLS = fileURL as! NSURL
                // ?????????????????
                //let sizeUtablePointer = AutoreleasingUnsafeMutablePointer<NSNumber?>.init(bitPattern: 4)
                //fileURLS.getResourceValue(&fileSize, forKey: URLResourceKey.fileSizeKey)
               // fileURLS.getResourceValue( AutoreleasingUnsafeMutablePointer<AnyObject?>, forKey: URLResourceKey.fileSizeKey)
                totalSize += fileSize?.intValue ?? 0
                fileCount += 1
                
            }
        
            DispatchQueue.main.async {
                completionBlock(fileCount,totalSize)
            }
            
            
        }
        
    }
    func takesAnAutoreleasingPointer(_ p: AutoreleasingUnsafeMutablePointer<NSNumber?>) {
        // ...
    }
    
    
    /// private
    /// - Parameter key:
    private func cachedFileNameForKey(_ key:String) ->String{
        // char -- [CCChar]
        let str = key.cString(using: String.Encoding.utf8)
        //CUnsignedInt -- CC_LONG
        let strLen = CUnsignedInt(key.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        // 延迟释放
        result.deinitialize(count: digestLen)
        return String(format: hash as String)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
