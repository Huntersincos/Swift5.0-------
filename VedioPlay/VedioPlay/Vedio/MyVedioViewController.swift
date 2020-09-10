//
//  MyVedioViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit


class MyVedioViewController: UIViewController {
   
    var playerView:AVVedioPlayView?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //view.backgroundColor = .red
        title = "本地视频播放"
        
        guard let filePath = Bundle.main.path(forResource: "v02004060000bq0sotqmac2oa0c1pftg", ofType: "mp4") else { return  }
        let fileURL:URL = URL.init(fileURLWithPath: filePath)
        self.playerView = AVVedioPlayView.init(frame:self.view.bounds)
        self.playerView?.playWith(fileURL)
        self.view.addSubview(self.playerView ?? UIView.init())
        
    }
    
    override var prefersStatusBarHidden: Bool{
        
        return true
    }
    
    override func viewWillLayoutSubviews() {
        playerView?.frame = self.view.bounds
    }
    
    //Overriding non-@objc declarations from extensions is not supported 在extends @objc
    override func base_SupportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    
         return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.landscapeLeft.rawValue | UIInterfaceOrientationMask.landscapeRight.rawValue | UIInterfaceOrientationMask.portrait.rawValue)
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
