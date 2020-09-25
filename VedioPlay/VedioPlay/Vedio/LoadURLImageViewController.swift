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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.UrlUIImageView.sd_setImageWithURL(URL.init(string: "https://www.gx.10086.cn/shop/staticpic/upload/attach//20200921/20203921171430.jpg"))
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
