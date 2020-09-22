//
//  SDWebImageCombinedOperation.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/17.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class SDWebImageCombinedOperation: NSObject, SDWebImageOperation{

    var cancelled:Bool?
    var cancelBlock:SDWebImageNoParamsBlock?
    var cacheOperation:Operation?
    var  isCancelled:Bool?
    
    func setCancelBlock(_ cancelBlock:@escaping SDWebImageNoParamsBlock){
        if self.cancelled ?? false {
            cancelBlock()
             self.cancelBlock = nil
        }else{
            self.cancelBlock = cancelBlock
        }
       
    }
    
    func cancel() {
        self.isCancelled = true
        if (self.cacheOperation != nil) {
            self.cacheOperation?.cancel()
            self.cacheOperation = nil
        }
        
        if self.cancelBlock != nil {
            self.cancelBlock!()
            self.cancelBlock = nil
        }
    }
    
    

}
