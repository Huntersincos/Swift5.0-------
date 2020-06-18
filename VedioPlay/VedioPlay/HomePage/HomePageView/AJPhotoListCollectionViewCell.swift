//
//  AJPhotoListCollectionViewCell.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AssetsLibrary

class AJPhotoListCollectionViewCell: UICollectionViewCell {
    var imageView:UIImageView?
    var asset:ALAsset?
    var tapAssetView:AJPhotoListCellTapView?
    var gradientView:AJGradientView?
    func bind(_ asset:ALAsset? ,_ selectionFilter:NSPredicate?,isSelected:Bool) {
        self.asset = asset
        if self.imageView == nil {
            self.imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            self.contentView.addSubview(self.imageView!)
            self.imageView?.layer.cornerRadius = 5
            self.imageView?.contentMode = .scaleAspectFill
            self.imageView?.clipsToBounds = true
            self.imageView?.backgroundColor = .white
        }
        if self.tapAssetView == nil {
            self.tapAssetView = AJPhotoListCellTapView.init(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            self.contentView .addSubview(self.tapAssetView!)
            
        }
        
        if (asset?.isKind(of: UIImage.self))! {
            self.imageView?.image = asset as? UIImage
        }else{
            // 获取图片的缩列图 aspectRatioThumbnail
            self.imageView?.image = UIImage.init(cgImage: asset?.aspectRatioThumbnail() as! CGImage)
            
        }
    }
    
    
    
}
