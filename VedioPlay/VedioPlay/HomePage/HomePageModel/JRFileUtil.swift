//
//  JRFileUtil.swift
//  VedioPlay
//
//  Created by wenze on 2020/7/9.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

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
        if FileManager.default.fileExists(atPath: folderAbsolutePath){
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
        if fileName.hasPrefix("jpg") || fileName.hasPrefix("jpeg") || fileName.hasPrefix("png")  || fileName.hasPrefix("bmp") || fileName.hasPrefix("gif") {
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
    
    

}
