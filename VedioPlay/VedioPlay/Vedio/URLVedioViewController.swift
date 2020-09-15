//
//  URLVedioViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/7.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class URLVedioViewController: UIViewController {
    var playerView:AVVedioPlayView?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "URL视频播放"
       // URL(string: <#T##String#>)
        //http://v4ttyey-10001453.video.myqcloud.com/Microblog/288-4-1452304375video1466172731.mp4  // 播放不了 mts错误
        let  url =   URL(string: "http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4")
            

        self.playerView = AVVedioPlayView.init(frame:self.view.bounds)
        self.playerView?.playWithUrl(url,VeidoStoreType.URLANDLOCALVedio)
        self.view.addSubview(self.playerView ?? UIView.init())
        
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//
//    }
    override var prefersStatusBarHidden: Bool{
           
           return true
       }
       
       override func viewWillLayoutSubviews() {
           playerView?.frame = self.view.bounds
       }
    
    deinit {
        
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
