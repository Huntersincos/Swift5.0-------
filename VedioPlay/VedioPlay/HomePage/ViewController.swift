//
//  ViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

/**
 采集视频资源
   1 在相册中
   2 在相机中
*/
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,JRCameraHelperDelegate{

    let array = ["相册","相机"]
    @IBOutlet weak var dataTabView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .orange
        title = "采集"
        self.tabBarItem.title = "采集"
       // saveMediaToCameraRoll()
       
    }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return array.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           //HomePageTabveiwCellID
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePageTabveiwCellID", for: indexPath)
        let title = array[indexPath.row]
        cell.textLabel?.text = title
        return cell
          
        
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let  albumVie =  JRAlbumViewController.init()
            albumVie.hidesBottomBarWhenPushed = true;
            navigationController?.pushViewController(albumVie, animated: true)
        }else{
            
            // 相机采集相册和相机
            JRCameraHelper.sharedInstance.delegate = self
            JRCameraHelper.sharedInstance.showCameraViewControllerCameraType(.CameraTypeBoth, onViewController: self)
        
            
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    //  视频 导入相册
    func saveMediaToCameraRoll()  {
    //    let picArray:NSMutableArray? = NSMutableArray.init()
    //    let jpgFiles:NSArray? = Bundle.main.paths(forResourcesOfType: "jpg", inDirectory: nil)
    //    let pngArray:NSArray? = Bundle.main.paths(forResourcesOfType: "png", inDirectory: nil)
        guard let  viedioPahth = Bundle.main.path(forResource: "viedio", ofType: "MP4", inDirectory: nil) else { return }
        // 第一种保存方式
        let videoCompatible:Bool? = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(viedioPahth)
        if videoCompatible == true {
            UISaveVideoAtPathToSavedPhotosAlbum(viedioPahth,self , #selector(self.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        // 第二种方式
        // @available(iOS 13.0, *)
//        let iOSsystemVersion:Float? = Float(UIDevice.current.systemVersion)
//        if iOSsystemVersion! > 9.0 {
//
//        }
        
        if #available(iOS 9.0, *)  {
            PHPhotoLibrary.shared().performChanges({
                let options = PHAssetResourceCreationOptions.init()
                PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: NSURL.fileURL(withPath: viedioPahth), options: options)
                
            }) { (succeed:Bool?, error:Error?) in
                
            }
        }else{
            let libary = ALAssetsLibrary.init()
            libary.writeVideoAtPath(toSavedPhotosAlbum: NSURL.fileURL(withPath: viedioPahth), completionBlock: nil)
        }
        
    }

    @objc func video(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: AnyObject) {

           if error.code != 0{
               print("保存失败")
               print(error)
           }else{
               print("保存成功")
              
           }
       }

    //JRCameraHelperdelegate
    func cameraPrintImage(_ image: UIImage?) {
        
        let imageData:Data? = image?.jpegData(compressionQuality: 0.8) as Data?
           // (image ?? UIImage.init()).jpegData(compressionQuality: 0.8) as NSData?
        
        
        
        
    }
    
    func cameraPrintVideo(_ videoUrl: NSURL?) {
        
    }
    

}






