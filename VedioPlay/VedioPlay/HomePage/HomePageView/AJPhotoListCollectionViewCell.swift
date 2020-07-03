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
            // 获取图片的缩列图 aspectRatioThumbnail hread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
            //UIImage.init(cgImage: <#T##CGImage#>)
           // self.imageView?.image = UIImage.init(cgImage: asset?.aspectRatioThumbnail() as! CGImage)
            self.imageView?.image = UIImage(cgImage: (asset?.thumbnail()?.takeUnretainedValue())!)
            //Binary operator '==' cannot be applied to operands of type 'Any?' and 'String' 在swif中只有类才可以用== 值类型是不行的 asset?.value(forProperty:ALAssetPropertyType) == ALAssetTypeVideo 不对 == 必须类型对应
            let propertyType:String? =  asset?.value(forProperty:ALAssetPropertyType) as? String
            if propertyType == ALAssetTypeVideo {
                if self.gradientView == nil{
                    gradientView = AJGradientView.init(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
                    let  colors = [UIColor.clear.withAlphaComponent(0.0).cgColor,UIColor.init(red: 23/255.0, green: 22/255.0, blue: 22/255.0, alpha: 1/0)] as [Any]
                    let locations = [NSNumber(0.8),NSNumber(1.0)]
                    self.contentView.insertSubview(gradientView!, aboveSubview: self.imageView!)
                    gradientView?.setupCAGradientLayer(colors, locations)
                    
                    let videoIcon:UIImageView? = UIImageView.init(frame: CGRect(x: 5, y: self.bounds.size.height - 15, width: 15, height: 8))
                    videoIcon?.image = UIImage.init(named: "AssetsPickerVideo")
                    gradientView?.addSubview(videoIcon!)
                    
                    let duration = UILabel.init(frame: CGRect(x: (videoIcon?.frame.maxX)!, y: self.bounds.size.height-17, width: self.bounds.size.width - (videoIcon?.frame.maxX)! - 5, height: 12))
                    duration.font = UIFont.systemFont(ofSize: 12)
                    duration.textColor = .white
                    duration.textAlignment = .center
                    duration.autoresizingMask = .flexibleWidth
                    gradientView?.addSubview(duration)
                    // 强转字符串不对
                    let valueNumber:Any? = asset?.value(forProperty: ALAssetPropertyDuration)
                    if  valueNumber != nil{
                        let value:Double? = (valueNumber as AnyObject).doubleValue
                        if value != nil {
                             duration.text = self.timeFormatted(value!)
                        }
                
                    }
                   
                    
                }
            }
        }
        
        tapAssetView?.disabled = selectionFilter?.evaluate(with: asset)
        tapAssetView?.selected = isSelected
        
    }
    
    func is_Selected(_ isSelected:Bool) {
        tapAssetView?.selected = isSelected
    }
    
    func timeFormatted(_ totalSeconds:Double) -> String {
        let timeInterval:TimeInterval? = totalSeconds
        //四舍五入
        let seconds:Int = lroundf(Float(timeInterval!))
        var hour:Int = 0
        var minute:Int = seconds/Int(60.0)
        let second:Int = seconds%60
        if minute > 59 {
            hour = minute/Int(60.0)
            minute = minute % 60;
            return NSString.init(format: "%02d:%02d:%02d"  ,hour,minute,second) as String
        }
        
        return NSString.init(format: "%02d:%02d",minute,seconds) as String
        
        
    }
    
    
    
}
