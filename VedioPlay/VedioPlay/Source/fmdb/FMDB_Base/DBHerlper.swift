//
//  DBHerlper.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/2.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

 typealias fm_Block = (_ db:FMDatabase) -> Void

 class DBHerlper: NSObject {
    /// 数据库名
   public static var baseName = "NEW_MESSAGEBASE.db"
   fileprivate static var instance = DBHerlper()
    /**
        FMDatabaseQueue:使用同步串行队列解决多线程访问同一个数据库损坏问题 但是并没有解决访问数据库UI卡顿问题
     */
   var bingingQueue:FMDatabaseQueue?
    //unowned 和 weak
   unowned var usingDB:FMDatabase?
   var dbPath:String?
    
   public static  var shareDBHelper:DBHerlper{
        get{
            return instance
        }
    }
//    override convenience init() {
//        //super.init()
//        self.init(withDBName:DBHerlper.baseName)
//    }
    convenience init(withDBName baseName:String){
         self.init()
         // 创建数据库
        let filePath =  JRFileUtil.getDirectoryForDocuments("fmdbBaseFiles") +  "/\(baseName)"
        //let  helper =
        self.setDBPath(filePath)
    }
    
    func setDBName(_ baseName:String)
    {
        let filePath =  JRFileUtil.getDirectoryForDocuments("fmdbBaseFiles") +  "/\(baseName)"
        self.setDBPath(filePath)
        
    }
    
    func setDBPath( _ filePath:String) {
        // 创建数据库目录
        if self.bingingQueue != nil && self.dbPath == filePath  {
            return
        }
        dbPath = filePath;
        bingingQueue?.close()
        bingingQueue = FMDatabaseQueue.init(path: filePath)
        self.execute { (db:FMDatabase) in
            CreatTableHelper.creatAllTable(db)
        }
        #if DEBUG
        bingingQueue?.inDatabase({ (db:FMDatabase?) in
            db?.logsErrors = true
        })

        #else
        

        #endif
        
        
        
        
    }
    
    func execute( block: @escaping fm_Block){
        bingingQueue?.inDatabase({ (db:FMDatabase?) in
            if self.usingDB != nil{
                block(self.usingDB!)
            }else{
                self.usingDB = db
                if db != nil{
                    block(db!)
                }
                self.usingDB = nil
            }
        })
        
    }
    
    
}

