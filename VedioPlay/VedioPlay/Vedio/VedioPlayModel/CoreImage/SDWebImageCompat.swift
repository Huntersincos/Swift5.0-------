//
//  SDWebImageCompat.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/31.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

/// 防止 @2x @3x图片被拉升
/// - Parameters:
///   - key: <#key description#>
///   - image: <#image description#>
@inline(__always) func SDScaledImageForKey(_ key:String,_ image:UIImage?) ->UIImage?{
    if image == nil {
        return nil
    }
    if image?.images?.count ?? 0 > 0 {
        var scaledImages = [UIImage]()
        for tempImage in image?.images ?? [UIImage.init()] {
            scaledImages.append(SDScaledImageForKey(key, tempImage) ?? UIImage.init())
        }
        return UIImage.animatedImage(with: scaledImages, duration: image?.duration ?? 0)
    }else{
        if UIScreen.main.responds(to: #selector(getter: UIScreen.main.scale)) {
            var scale:TimeInterval = 1
            if key.count >= 8 {
               // let range = key.range(of: "@2x.")
                if key.contains("@2x.") {
                    scale = 2.0
                }
                if key.contains("@3x.") {
                    scale = 3.0
                }
            }
            let scaledImage = UIImage.init(cgImage: (image?.cgImage)!, scale: CGFloat(scale), orientation: image?.imageOrientation ?? UIImage.Orientation.up)
            return scaledImage
            
        }
        return image
    }
    
}
 
let  SDWebImageErrorDomain  = "SDWebImageErrorDomain"

class SDWebImageCompat: NSObject {
   
}
