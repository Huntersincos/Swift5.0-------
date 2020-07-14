//
//  JRCameraHelper.swift
//  VedioPlay
//
//  Created by wenze on 2020/7/3.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
//import CoreFoundation
// 这个框架为应用程序提供基础服务,特性
// 1 块对象   2 GCD  3 内购  4 定位  5 sqlite 6 定位  7 xml 8 addressbook 9 cfnnetwork 等

//swift中 String和NString区别
// String:是结构体 值类型 存储在栈中,系统管理类存,进行值拷贝,存储速度快
//NString:类 引用类型 存储在堆中,值不会被拷贝,速度慢

import CoreServices

public enum CameraType:NSInteger{
    case CameraTypePhoto
    case CameraTypeVideo
    case  CameraTypeBoth
}

@objc protocol JRCameraHelperDelegate{
    // 图片
    func cameraPrintImage( _ image:UIImage?)
    
    // 视频
    func cameraPrintVideo( _ videoUrl:NSURL?)
    
}

class JRCameraHelper: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //fileprivate  能在当前文件内访问到 如果子类跟父类不再同一个文件下是不能够使用fileprivate修饰的方法或属性的；
    fileprivate static var instacne = JRCameraHelper()
    var imagePickerController:UIImagePickerController!
    // 不适用 NSDictionary 使用 Dictionary 可以相互转换as
    //var editInfo:NSDictionary!
    var editInfo:Dictionary<UIImagePickerController.InfoKey,Any>!
    weak var delegate:JRCameraHelperDelegate?
    public static  var sharedInstance:JRCameraHelper{
        get{
            return instacne
        }
    }
    
    func showCameraViewControllerCameraType(_ type:CameraType, onViewController viewController:UIViewController) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            return
        }
        
        if imagePickerController == nil{
            imagePickerController = UIImagePickerController.init()
            imagePickerController.isEditing = true
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            switch type {
            case .CameraTypePhoto:
                //kUTTypeImage 在CoreServices里面
                imagePickerController.mediaTypes = [kUTTypeImage as String]
                break
                
            case .CameraTypeVideo:
                imagePickerController.mediaTypes = [kUTTypeMovie as String]
                imagePickerController.videoMaximumDuration = 60
                break
                
            case .CameraTypeBoth:
                imagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
                imagePickerController.videoMaximumDuration = 60
                break
    
            default:
                break
            }
            
        }
        imagePickerController.modalPresentationStyle = .fullScreen
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    //- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo 废弃掉了
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //callDelegate(info as NSDictionary) 尽量不要使用
         callDelegate(info)
         dismissPickerViewController(picker)
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissPickerViewController(picker)
    }
    
    func dismissPickerViewController( _ picker:UIImagePickerController?) {
        if editInfo != nil {
            editInfo = nil
        }
        
        if imagePickerController != nil {
            imagePickerController = nil
        }
        
        picker?.dismiss(animated: true, completion: nil)
    }
    
    func callDelegate( _ info:Dictionary<UIImagePickerController.InfoKey,Any>?)  {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            // 字符串
            let mediaType:CFString = info?[UIImagePickerController.InfoKey.mediaType] as! CFString
            //kCFCompareEqualTo
            if CFStringCompare (mediaType, kUTTypeMovie,[]) == .compareEqualTo{
                let fileUrl:NSURL? = info?[UIImagePickerController.InfoKey.mediaURL] as? NSURL
                UISaveVideoAtPathToSavedPhotosAlbum(fileUrl?.path ?? "", nil, nil, nil)
                DispatchQueue.main.async {
                    self.delegate?.cameraPrintVideo(fileUrl)
                }
                
            }else{
                let image:UIImage? = info?[UIImagePickerController.InfoKey.originalImage] as? UIImage
                UIImageWriteToSavedPhotosAlbum(image ?? UIImage.init(), nil, nil, nil)
                DispatchQueue.main.async {
                    self.delegate?.cameraPrintImage(image)
                }
            }
        }
    }
    
}
