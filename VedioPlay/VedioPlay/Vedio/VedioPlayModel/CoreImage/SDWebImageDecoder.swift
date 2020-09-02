//
//  SDWebImageDecoder.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/1.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

/// 图片解码
/// 图片解码:当图片不解码时,系统默认在主线程中解码,会引起卡顿等问题
/// jpge:有损压缩,没有透明信息 适合存储相机图片
/// png:无损压缩,有透明效果,比较适合矢量图和几何体(矢量图最大的特点是缩放,图像其实一些绘图指令,这些指令独立于图片尺寸的)
/// bitMap:位图 gif图
/// 矢量图:svg

class SDWebImageDecoder: UIImage {
    
    //@discardableResult
    class func decodedImageWithImage(_ image:UIImage?) -> UIImage?{
        //批量下载图片时候,@autoreleasepool会释放bitmaps上下文,用到的变量会释放
        // 有些图片不适合解码 1 为空的  2 动态图不适合 3 带有透明因素的图像不适合
        if image == nil {
            return nil
         }
       // autoreleasepool{ () -> UIImage in
      if ((image?.images) != nil) {
         return image ?? UIImage.init()
        }
       let imageRef = image?.cgImage
       let alpha =  imageRef?.alphaInfo
       let anyAlpha = (alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast )
       if anyAlpha {
        return image
       }
       
       /// 获取当前空间颜色
        var colorspaceRef = imageRef?.colorSpace
           //CGColorSpaceModel()
       let imageColorSpaceModel = colorspaceRef?.model
       let unsupportedColorSpace = (imageColorSpaceModel == .unknown || imageColorSpaceModel == .monochrome  || imageColorSpaceModel == .cmyk || imageColorSpaceModel == .indexed )
        if unsupportedColorSpace {
            colorspaceRef = CGColorSpaceCreateDeviceRGB()
        }
        // 获取图片数据
        let width = imageRef?.width ?? 0
        let height = imageRef?.height ?? 0
        // 每个像素占用4个字节
        let bytesPerPixel = 4
        // 每行的像素数
        let bytesPerRow = bytesPerPixel * width
        // 每个组件占多少位
        let bitsPerComponent = 8
        // CGBitmapContextCreate 不支持kCGImageAlphaNone
        // 原始图像没有alpha信息，使用kCGImageAlphaNoneSkipLast
        // 创建没有透明透明因素,在UI渲染的时候,实际上是把多个图层按像素叠加计算的过程，需要对每一个像素进行 RGBA 的叠加计算。当某个 layer 的是不透明的，也就是 opaque 为 YES 时，GPU 可以直接忽略掉其下方的图层，这就减少了很多工作量。这也是调用 CGBitmapContextCreate 时 bitmapInfo 参数设置为忽略掉 alpha 通道的原因。
        let context = CGContext.init(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorspaceRef ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue | CGImageAlphaInfo.none.rawValue )
        if imageRef != nil {
            // 绘制
             context?.draw(imageRef!, in: CGRect(x: 0, y: 0, width: width, height: height))
           // if context != nil {
            let imageRefWithoutAlpha = context?.makeImage()
            if imageRefWithoutAlpha != nil {
                let imageWithoutAlpha =  UIImage.init(cgImage: imageRefWithoutAlpha!, scale: image?.scale ?? 0, orientation: image?.imageOrientation ?? UIImage.Orientation.up)
                if unsupportedColorSpace {
                    //CGColorSpaceRelease
                }
                
                return imageWithoutAlpha
                
            }
            
                
            //}
             
        }
        

               
                    
       // }
       
        return nil
        
    }
    
}
