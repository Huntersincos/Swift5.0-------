//
//  LoadURLImageViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/23.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class LoadURLImageViewController: UIViewController {
    
    /// url图片
    @IBOutlet weak var UrlUIImageView: UIImageView!
    
    @IBOutlet weak var placeholderUrlImageView: UIImageView!
    
    @IBOutlet weak var noCashDishImageView: UIImageView!
    
    @IBOutlet weak var highPriorityImageView: UIImageView!
    
    @IBOutlet weak var progressiveDownloadImageView: UIImageView!
    
    @IBOutlet weak var autoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.UrlUIImageView.sd_setImageWithURL(URL.init(string: "https://www.gx.10086.cn/shop/staticpic/upload/attach//20200921/20203921171430.jpg"))
        //https://www.gx.10086.cn/shop/staticpic/upload/attach//20200909/2020379101531.png
        self.placeholderUrlImageView.sd_setImageWithURL(URL.init(string: "https://www.gx.10086.cn/shop/staticpic/upload/attach//20200909/2020379101531.png"), placeholderImage: UIImage.init(named: "ic_pic_choose"))
         self.noCashDishImageView.sd_setImageWithURL(URL.init(string: "https://www.gx.10086.cn/shop/staticpic/upload/attach//20200120/2020420162049.jpg"), placeholderImage: nil, options: SDWebImageOptions.SDWebImageCacheMemoryOnly)
         self.highPriorityImageView.sd_setImageWithURL(URL.init(string: "https://www.gx.10086.cn/shop/staticpic/upload/attach//20200120/202042016235.jpg"), placeholderImage: nil, options: SDWebImageOptions.SDWebImageHighPriority) { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, url:URL?) -> Void? in
             
            /// 绘制图片为灰色
            if image != nil{
                 self.highPriorityImageView.image = self.highPriorityImageView.grayImage(image!)
            }
           
            return nil
        }
       
        self.progressiveDownloadImageView.sd_setImageWithURL(URL.init(string: "https://www.gx.10086.cn/shop/release/pages/dayActivity/20208112102001/dayActivityHome/images/t1.png"), placeholderImage: nil, options: SDWebImageOptions.SDWebImageProgressiveDownload, completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, url:URL?) -> Void? in
             
            return nil
        }) { (receivedSize:Int,expectedSize :Int64?) -> Void? in
            
            return nil
        }
        
        self.autoImageView.sd_setImageWithURL(URL.init(string: "http://img.t.sinajs.cn/t35/style/images/common/face/ext/normal/7a/shenshou_thumb.gif"))
        
    
    }
    
    deinit {
        
        #if DEBUG
        print("LoadURLImageViewController 控制器释放")

        #else
               

        #endif
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
