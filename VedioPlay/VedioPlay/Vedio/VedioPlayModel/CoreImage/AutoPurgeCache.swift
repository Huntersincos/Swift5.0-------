//
//  AutoPurgeCache.swift
//  VedioPlay
//
//  Created by wenze on 2020/8/27.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class AutoPurgeCache: NSCache<AnyObject, AnyObject> {
    
    override init() {
        super.init()
         NotificationCenter.default.addObserver(self, selector: #selector(removeAllObjects), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    deinit {
         NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

}
