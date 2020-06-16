//
//  BaseNavViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class BaseNavViewController: UINavigationController,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        interactivePopGestureRecognizer?.delegate = self;
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes  = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.barTintColor = UIColor.blue
    
    }
    
   func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
     return children.count > 1
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
