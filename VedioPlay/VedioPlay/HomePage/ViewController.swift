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
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,JRCameraHelperDelegate,AudioPlayHelperDelegate,DisplayLocationViewControllerDelegate{

    
   
    let array = ["相册","相机","麦克风","定位","本地视频播放","URL视频播放"]
    @IBOutlet weak var dataTabView: UITableView!
    var recordProgressView:VoiceRecordProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .orange
        title = "采集"
        self.tabBarItem.title = "采集"
       // saveMediaToCameraRoll()
        recordProgressView = VoiceRecordProgressView.init(frame: CGRect(x: (UIScreen.main.bounds.width - 160)/2, y: (UIScreen.main.bounds.height - 160)/2, width: 160, height: 160))
        self.view .addSubview(recordProgressView)
        recordProgressView.isHidden = true
        
       
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
        }else if indexPath.row == 1  {
            
            // 相机采集相册和相机
            JRCameraHelper.sharedInstance.delegate = self
            JRCameraHelper.sharedInstance.showCameraViewControllerCameraType(.CameraTypeBoth, onViewController: self)
        
            
        }else if(indexPath.row == 2){
            //AudioPlayHelper.shareInstance.delegate = self;
            recordProgressView.setVoiceRecord()
            recordProgressView.show()
            
        }else if(indexPath.row == 3){
            let  locationVC = DisplayLocationViewController.init()
            locationVC.delegate = self
            locationVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(locationVC, animated: true)
        }else if(indexPath.row == 4 ){
            let vedioVC = MyVedioViewController.init()
            vedioVC.modalPresentationStyle = .fullScreen
            self.present(vedioVC, animated: true, completion: nil)
        }else if( indexPath.row == 5){
            let vedioURLVC = URLVedioViewController.init()
            vedioURLVC.modalPresentationStyle = .fullScreen
            self.present(vedioURLVC, animated: true, completion: nil)
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
//    MARK:viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//      TODO:试图消失时,阻止视频播放
        AudioPlayHelper.shareInstance.stopAudio()
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
        
        let imageData = image?.jpegData(compressionQuality: 0.8) as NSData?
           // (image ?? UIImage.init()).jpegData(compressionQuality: 0.8) as NSData?
        let  fileRelativePath = JRFileUtil.createFilePathWithFileName(JRFileUtil .getFileNameWithType("png") as NSString, "image", "15711111111")
       
        // 发送图片
        if imageData?.write(to: URL.init(fileURLWithPath: JRFileUtil .getAbsolutePathWithFileRelativePath(fileRelativePath)), atomically: true) ?? false {
            print("发送图片成功")
        }
         
    }
     
    func cameraPrintVideo(_ videoUrl: NSURL?) {
        JRFileUtil.convertVideoFormat(videoUrl?.path ?? "", peerUserName: "15711111111") { (code:String, fileRelativePath:String) in
            
            DispatchQueue.main.async {
                // 发送视频
                if code == "0"{
                    print("视频压缩成功")
                }
            }
            
        }
    }
    
      func audioPlayerDidBeginPlay(_ audioPlay: AVAudioPlayer) {
           
       }
       
       func audioPlayerDidStopPlay(_ audioPlay: AVAudioPlayer) {
           
       }
       
       func audioPlayerDidPausePlay(_ audioPlay: AVAudioPlayer) {
           
       }
    
    
    /// JRDisplayLocationViewControllerDelegate
    
    
    func didFinishLocationCompled(_ latitude: Double, _ longitude: Double, _ radius: Double, geoLocation: String) {
        
         print(latitude,longitude)
        
    }

}






