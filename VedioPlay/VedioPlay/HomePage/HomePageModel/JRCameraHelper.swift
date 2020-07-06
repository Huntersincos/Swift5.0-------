//
//  JRCameraHelper.swift
//  VedioPlay
//
//  Created by wenze on 2020/7/3.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
// 这个框架为应用程序提供基础服务,特性
// 1 块对象   2 GCD  3 内购  4 定位  5 sqlite 6 定位  7 xml 8 addressbook 9 cfnnetwork 等
import CoreServices

public enum CameraType:NSInteger{
    case CameraTypePhoto
    case CameraTypeVideo
    case  CameraTypeBoth
}

class JRCameraHelper: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    fileprivate static var instacne = JRCameraHelper()
    var imagePickerController:UIImagePickerController!
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
                //
                break
    
            default:
                break
            }
            
        }
        imagePickerController.modalPresentationStyle = .fullScreen
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    
}
