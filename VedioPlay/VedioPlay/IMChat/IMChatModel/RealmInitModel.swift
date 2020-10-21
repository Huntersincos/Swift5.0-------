//
//  RealmInitModel.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/29.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import RealmSwift

class RealmInitModel: NSObject {
    static var configuration:RealmSwift.Realm.Configuration?
    static var  realmVersion = 1
    
    class func getRealmConfigBeyondCurrentUser()  -> Realm.Configuration? {
        if self.configuration == nil {
             var path = JRFileUtil.getDocumentPath() + "/db/IM"
             var pointer = ObjCBool.init(false);
             let exist =  FileManager.default.fileExists(atPath: path, isDirectory: &pointer)
             if exist == false && pointer.boolValue == false {
                try?FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
            
            path = path + "/imchat.realm"
           
            
            self.configuration = Realm.Configuration.init()
            self.configuration?.fileURL = URL.init(fileURLWithPath: path)
            self.configuration?.schemaVersion = UInt64(realmVersion)
            /// 如果需要迁移,是否需要 使用提供schemaVersion重新创建Realm文件
            /// 当存储的schema和设置的schema不同时, deleteRealmIfMigrationNeeded设置为ture时,将会删除realm文件
            self.configuration?.deleteRealmIfMigrationNeeded = false
            //self.configuration?.migrationBlock
            /// 注:如果开发中切换用户则需要将 需要在上次登录成功后将 self.configurations设置为 == nil 每个不同的用户fileURL是不一样的,在文件名后面加上用户名用来区分
            
            
               #if DEBUG
                print(path)
            
               // print(<#T##items: Any...##Any#>)

               #else
               

               #endif
        }
        
        return self.configuration!
        
        
    }
   
    class func getRealmInstance() -> Realm?{
       
        let realmConfiguration = RealmInitModel.getRealmConfigBeyondCurrentUser()
       
        var realm:Realm? = nil
        if realmConfiguration != nil {
       ///一个可选的调度队列，用于Realm领域。如果给定，这个Realm实例可以从内部使用 块调度到给定队列而不是当前线程
            //  单线程安全 详见 https://academy.realm.io/cn/posts/threading-deep-dive/
            // 不能再线程间传递数据 保证数据的一致性和隔离性
            
            //realm = try? Realm.init(configuration: realmConfiguration!,queue: DispatchQueue.init(label: "com.getRealmInstance"))
            realm = try? Realm.init(configuration: realmConfiguration!)
        
        }
        
        if !Thread.isMainThread {
            realm?.refresh()
        }
       
        return realm
    }
    
   
}
