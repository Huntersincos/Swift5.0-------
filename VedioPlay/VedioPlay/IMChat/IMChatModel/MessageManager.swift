//
//  MessageManager.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/10.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class MessageManager: NSObject {
    
     fileprivate static var  instance = MessageManager()
      var peerUserName:String?
      static public var shareInstance:MessageManager{
        get{
            return instance
        }
    }
}
