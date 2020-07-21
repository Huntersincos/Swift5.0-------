//
//  JRFileUtil.swift
//  VedioPlay
//
//  Created by wenze on 2020/7/9.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AVFoundation
//Escaping closure captures non-escaping parameter '
// open func exportAsynchronously(completionHandler handler: @escaping () -> Void)
//typealias CompletionHandler = @escaping(Error,String) -> Void

class JRFileUtil: NSObject {
   
    class func getDocumentPath() ->String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        return paths[0]
        
    }
    
    class func getDirectoryForDocuments(_ dir:String) ->String{
        
        let dirPath:String = self.getDocumentPath() + "/\(dir)"
        //let isDir:Bool = false =====  'UnsafeMutablePointer<ObjCBool>?.T
        var pointer = ObjCBool.init(false);
        let isCreated:Bool = FileManager.default.fileExists(atPath: dir, isDirectory: &pointer)
        if !isCreated && !pointer.boolValue{
            try?FileManager.default.createDirectory(at: URL.init(fileURLWithPath: dirPath, isDirectory: true), withIntermediateDirectories: true, attributes: nil)
            
            
        }
        
        return dirPath
    }
    
    /**
        创建文件路径
     */
    
    class func createFilePathWithFileName(_ fileName:NSString , _ folderName:String , _ peerUserName :String ) -> String{
        
        let rootPath:String? = self.getDirectoryForDocuments("username")
        let folderAbsolutePath = (rootPath ?? "") + "/\(peerUserName)" + "/\(folderName)"
        let folderRelativePath = "username" + "/\(peerUserName)" + "/\(folderName)"
        if !FileManager.default.fileExists(atPath: folderAbsolutePath){
          try? FileManager.default.createDirectory(atPath: folderAbsolutePath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileAbsolutePath = folderAbsolutePath + "/\(fileName)"
        var fileRelativePath = folderRelativePath + "/\(fileName)"
        if FileManager.default.fileExists(atPath: fileAbsolutePath){
           // var pathExtension:NSString? = (fileName as NSString)
            //从路径中最后一个组成部分中提取扩展名
            let  pathExtension = fileName.pathExtension
            //以文件最后一部分 删除删除扩展名
            let fileNameDeleteEx = fileName.deletingPathExtension
            let uuidString = NSUUID.init().uuidString
            fileRelativePath  = folderRelativePath + "/\(fileNameDeleteEx)" + "_\(uuidString)" + ".\(pathExtension)"
        
        }
        
        return fileRelativePath
        
    }
    /**
           根据相对路径获取绝对路径
     */
    class func getAbsolutePathWithFileRelativePath(_ fileRelativePath:String) -> String{

        return self.getDocumentPath() + "/\(fileRelativePath)"
       
    }
    
    /**
       根据绝对路径获取相对路径
     */
    
    class func getRelativePathWithFileAbsolutePath(_ fileAbsolutePath:String ) -> String{
        return fileAbsolutePath.replacingOccurrences(of: self.getDocumentPath(), with: "")
    }
    
    /**
          获取相对路径获取图片
     */
    class func getImageWithFileRelativePath(_ fileRelativePath:String)  -> UIImage? {
        let absolutePath  = self.getAbsolutePathWithFileRelativePath(fileRelativePath)
        return UIImage.init(contentsOfFile: absolutePath)
    }
    
    /**
          根据文件后缀生成唯一文件名
     */
    
    class func getFileNameWithType(_ type:String) -> String{
        
        let currentDate = Date.init()
        let formate = DateFormatter.init()
        formate.dateFormat = "yyyy-MM-dd_HH-mm-ss-SSS"
        return formate.string(from: currentDate) + ".\(type)"
    }
    
    /**
         根据路径生成缩略图，支持图片和视频
     */
    class func getThumbPathWithFilePath(_ filePath:String, peerUserName number:String) -> String{
        
        let absolutePath = self.getAbsolutePathWithFileRelativePath(filePath)
        let fileName = filePath.lowercased()
        if fileName.hasSuffix("jpg") || fileName.hasSuffix("jpeg") || fileName.hasSuffix("png")  || fileName.hasSuffix("bmp") || fileName.hasSuffix("gif") {
            let image = UIImage.init(contentsOfFile: absolutePath)
            // 压缩图片
            if image != nil{
                let imageData:Data  = self.imageDataWithImage(image ?? UIImage.init(), maxDataSize: 6)
                let fileRelativePath = self.createFilePathWithFileName(self.getFileNameWithType("png") as NSString, "thumb", number)
                let absolutePath = self.getAbsolutePathWithFileRelativePath(fileRelativePath)
                // 数据写入本地 使用NSData
                let ns_imageData:NSData = imageData as NSData
                ns_imageData.write(toFile: absolutePath, atomically: true)
                return fileRelativePath
                
            }
        }else if fileName.hasSuffix("3gp") || fileName.hasSuffix("mp4") || fileName.hasSuffix("mov"){
            let url:URL  =  URL.init(fileURLWithPath:self.getAbsolutePathWithFileRelativePath(filePath))
            // AVURLAssets视频管理器
            let asset:AVURLAsset? = AVURLAsset.init(url: url, options: nil)
            if asset != nil {
                 let gen:AVAssetImageGenerator? = AVAssetImageGenerator.init(asset: asset!)
                // 正确的方向截图
                gen?.appliesPreferredTrackTransform = true
                // value:表示视频的帧数  timescale 每秒的帧数 帧率
                let time:CMTime? = CMTimeMake(value: 0, timescale: 10)
                
                //CMTime 对于视频的时长 用double型是有问题 因为视频需要切分 不能用浮点型计算  CMTime定义是一个C语言的结构体，CMTime是以分数的形式表示时间，value表示分子，timescale表示分母，flags是位掩码，表示时间的指定状态。 这里value,timescale是分别以64位和32位整数来存储的
                //timescale又是什么？ 它表示每秒分割的“切片”数。CMTime的整体精度就是受到这个限制的 timescale只是为了保证时间精度而设置的帧率，并不一定是视频最后实际的播放帧率
                if time != nil {
                    
                    //Cannot convert value of type 'UnsafeMutablePointer<CMTime>?.Type' to expected argument type 'UnsafeMutablePointer<CMTime>?'
                    
                    //let isDir:Bool = false =====  'UnsafeMutablePointer<ObjCBool>?.T
                    //var pointer = ObjCBool.init(false);
                    var actualTime =  CMTime.init()
                    // 没测试
                    let image:CGImage = try!(gen?.copyCGImage(at: time!, actualTime: &actualTime))!
                    // 转化成uiimage
                    let thumb:UIImage = UIImage.init(cgImage: image)
                    let  fileRelativePath:String = self.createFilePathWithFileName(self .getFileNameWithType("png") as NSString, "thumb", number)
                    //self.imageDataWithImage(thumb, maxDataSize: 6)
                    let ns_thumb:NSData =  self.imageDataWithImage(thumb, maxDataSize: 6) as NSData
                    ns_thumb.write(toFile: absolutePath, atomically: true)
                    return fileRelativePath
                }
            
                
                
            }
           
            
        }
        
       return ""
        
    }
    
    /**
        图片压缩
     */
    
    class func imageDataWithImage(_ image:UIImage ,maxDataSize size:NSInteger) -> Data{
        
        // 质量压缩
        let maxLength = size * 1024
        var compression = 1
        var data:Data = image.jpegData(compressionQuality: CGFloat(compression)) ?? Data.init()
        if data.count < maxLength { return data}
        
        var max:CGFloat = 1;
        var min:CGFloat = 0;
        for _ in 1...6 {
            compression  = Int((max + min)/2)
            data = image.jpegData(compressionQuality: CGFloat(compression)) ?? Data.init()
            if data.count <  maxLength  {
                min = CGFloat(compression)
            }else if data.count > maxLength{
                max = CGFloat(compression)
            }else{
                break
            }
            
        }
        // 大小压缩
        var resultImage = UIImage.init(data: data)
        if data.count < maxLength { return data}
        var lastDataLength = 0
        while data.count > maxLength &&  data.count != lastDataLength {
            lastDataLength = data.count
            let ratio:CGFloat =  CGFloat(maxLength/data.count)
            let size:CGSize = CGSize(width: (resultImage?.size.width ?? 0) * sqrt(ratio), height: (resultImage?.size.height ?? 0) * sqrt(ratio))
            UIGraphicsBeginImageContext(size)
            resultImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            data = resultImage?.jpegData(compressionQuality: CGFloat(compression)) ?? Data.init()
            
        }
        
        return data
        
    }
    
    
    /**
        删除路径下的文件
     */
    class func deleteFilesWithNumber(_ number: String) ->Bool{
        
        var rootPath = self.getDirectoryForDocuments("username")
        rootPath = rootPath + "/\(number)"
        if  FileManager.default.fileExists(atPath: rootPath) {
           try? FileManager.default.removeItem(atPath: rootPath)
        }
        return true
    }
    
    /**
       视频转码
     */
    
    class func convertVideoFormat(_ path:String,peerUserName number:String,completion:@escaping(String,String) -> Void){
        
        let url = URL.init(fileURLWithPath: path)
       // if url != nil {
            let avAsset = AVURLAsset.init(url: url, options: nil)
            // 压缩视频 presetName压缩分辨率
            let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPreset640x480)
            let outputRelativePath = self.createFilePathWithFileName(self.getFileNameWithType("mp4") as NSString, "video", number)
            let outputFilePath = self.getAbsolutePathWithFileRelativePath(outputRelativePath)
            exportSession?.outputURL = URL.init(fileURLWithPath: outputFilePath)
            //设置这个属性 压缩效果会更好
            exportSession?.shouldOptimizeForNetworkUse = true
            //AVFileTypeMPEG4 写成AVFileType.mp4
            exportSession?.outputFileType = AVFileType.mp4
            //Escaping closure captures non-escaping parameter 'completionHandler'
            /**
               Error Domain=AVFoundationErrorDomain Code=-11800 "The operation could not be completed" UserInfo={NSLocalizedFailureReason=An unknown error occurred (-17508), NSLocalizedDescription=The operation could not be completed, NSUnderlyingError=0x28241bba0 {Error Domain=NSOSStatusErrorDomain Code=-17508 "(null)"}}  这种问题是视频路径没有创建
             */
            exportSession?.exportAsynchronously(completionHandler: {
                switch exportSession?.status{
                  case .failed:
                    if exportSession?.error != nil {
                        // !用要谨慎
                         completion("200" ,outputRelativePath)
                    }
                    break
                  case .cancelled:
                    break
                case.completed:
                  // if exportSession?.error != nil {
                    // code 为 0为成功
                    completion( "0" ,outputRelativePath)
                  // }
                    break
                default:
                    break
                    
                }
                if FileManager.default.fileExists(atPath: path){
                   try?FileManager.default.removeItem(atPath: path)
                }
                
            });
        
        }
        
        
    //}
    
    
    

}
