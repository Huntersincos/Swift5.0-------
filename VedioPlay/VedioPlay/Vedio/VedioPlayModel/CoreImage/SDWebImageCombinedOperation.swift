//
//  SDWebImageCombinedOperation.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/17.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class SDWebImageCombinedOperation: NSObject, SDWebImageOperation{
    func cancel() {
        
    }
    
    var cancelled:Bool?
    var cancelBlock:SDWebImageNoParamsBlock?
    var cacheOperation:Operation?
    
    

}
