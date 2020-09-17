//
//  CreatTableHelper.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/3.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
// 消息详情
public var tableAllMessage = "TableAllMessageBase"
// 会话列表 == 单聊
public var ConversationsMessageTable = "ConversationsMessageTable"
// 接收消息更新状态
public var  RecipientStatusTable =  "ConversationsRecipientStatusTable"

public var  Rms_favorite  = "Rms_favoriteTable"

//聊天详情页View
public var MsgDetailView = "MsgDetailView"

class CreatTableHelper: NSObject {
   
    class func creatAllTable(_ db:FMDatabase)
    {
         let succeed = true
         db.beginTransaction()
         db.executeStatements(self.creatSql_tableAllMessage())
         db.executeStatements(self.creatSqlWithRmsImdnStatusTable())
         db.executeStatements(self.creataWithConversationsTable())
         db.executeStatements(self.sqlWithRmsFavoriteTable())
         db.executeStatements(self.chatTriggerUpadateMsgRead())
         db.executeStatements(self.insertTriggerUpdataMsg())
         db.executeStatements(self.imdn_deleteTigger())
         db.executeStatements(self.sqlWithConversationsTigger())
         
    
    }
    
    
   class func creatSql_tableAllMessage() -> String{
        
    return "CREATE TABLE IF NOT EXISTS \(tableAllMessage) ( _id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,  conv_id INTEGER, sender_number TEXT, peer_numbers TEXT, receiver_numbers TEXT,date INTEGER,timestamp INTEGER,is_read INTEGER,is_black INTEGER,status INTEGER,box_type INTEGER,content TEXT,message_type INTEGER,error_code INTEGER,conversation_id TEXT,contribution_id TEXT,file_name TEXT,file_type TEXT,file_path INTEGER, file_expire_date INTEGER, file_thumb_path TEXT, file_trans_id TEXT, file_media_duration INTEGER, file_size INTEGER, file_trans_size INTEGER, file_download_url TEXT, geo_latitude TEXT, geo_longitude TEXT, geo_radius TEXT, geo_free_text TEXT, imdn_msg_id TEXT, imdn_type INTEGER, is_burn_after_reading INTEGER, is_silence, is_direct, is_carbon_copy, is_at_msg );"
    }
    
    class func creataWithConversationsTable() -> String{
        return "CREATE TABLE IF NOT EXISTS \(ConversationsMessageTable) (_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, create_date INTEGER, update_date INTEGER, type INTEGER, recipient_numbers TEXT, recipient_number_ids TEXT, unread_message_count INTEGER, priority INTEGER, is_notification INTEGER, is_black INTEGER, latest_rms_id INTEGER, is_delete INTEGER  is_stick INTEGER stick_time INTEGER );"
        
    }
    
    class func creatSqlWithRmsImdnStatusTable() ->String{
        return "CREATE TABLE IF NOT EXISTS \(RecipientStatusTable) (_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, rms_id INTEGER, recipient_number TEXT, status INTEGER );";
        
    }
    
    
    class func sqlWithRmsFavoriteTable() -> String{
        return "CREATE TABLE IF NOT EXISTS \(Rms_favorite)(_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,rms_id INTEGER,sender_number TEXT,date INTEGER,timestamp INTEGER,favourite_date INTEGER,status INTEGER,content TEXT,message_type INTEGER,conversation_id TEXT,contribution_id TEXT,file_name TEXT,file_type TEXT,file_path INTEGER,file_thumb_path TEXT,file_media_duration INTEGER,file_size INTEGER,geo_latitude TEXT,geo_longitude TEXT,geo_radius TEXT,geo_free_text TEXT);";
        
    }
    
    // trigger 创建 触发器
    
    /// 触发器名rms_update_conversation_read_on_update
    /// AFTER  + 触发事件:UPDATE OF is_read
    ///  ON:表名
    /// 多条语句的触发器   new 新的数据  old 删除的数据
    /// begin  执行语句 end
    /// 查看触发器信息 SHOW TRIGGER
    class func chatTriggerUpadateMsgRead() ->String{
        
        return "CREATE TRIGGER IF NOT EXISTS rms_update_conversation_read_on_update AFTER UPDATE OF is_read ON \(tableAllMessage) BEGIN UPDATE \(ConversationsMessageTable) SET unread_message_count = (SELECT count(*) FROM \(tableAllMessage) WHERE is_read = 0 AND \(tableAllMessage).conv_id = NEW.conv_id) WHERE \(ConversationsMessageTable)._id = NEW.conv_id;END;";
    
    }
    
    class func insertTriggerUpdataMsg() ->String {
        return "CREATE TRIGGER IF NOT EXISTS rms_update_conversation_on_insert AFTER INSERT ON \(tableAllMessage) BEGIN UPDATE \(ConversationsMessageTable) SET latest_rms_id = NEW._id, unread_message_count = (SELECT count(*) FROM \(tableAllMessage) WHERE is_read = 0 AND \(tableAllMessage).conv_id = NEW.conv_id) , update_date = NEW.timestamp WHERE \(ConversationsMessageTable)._id = NEW.conv_id; END;";
    }
    
    class func imdn_deleteTigger() -> String{
        return "CREATE TRIGGER IF NOT EXISTS rms_update_conversation_and_imdn_status_on_delete AFTER DELETE ON \(tableAllMessage) BEGIN UPDATE \(ConversationsMessageTable) SET latest_rms_id = (SELECT _id FROM \(tableAllMessage) WHERE \(tableAllMessage).conv_id = OLD.conv_id ORDER BY date DESC, \(tableAllMessage)._id DESC LIMIT 1), unread_message_count = (SELECT count(*) FROM \(tableAllMessage) WHERE is_read = 0 AND \(tableAllMessage).conv_id = OLD.conv_id) WHERE \(ConversationsMessageTable)._id = OLD.conv_id; UPDATE \(ConversationsMessageTable) SET update_date = (SELECT date FROM \(tableAllMessage) WHERE \(tableAllMessage).conv_id = OLD.conv_id ORDER BY date DESC, \(tableAllMessage)._id DESC LIMIT 1) WHERE \(ConversationsMessageTable)._id = OLD.conv_id  AND EXISTS(SELECT _id FROM \(tableAllMessage) WHERE \(tableAllMessage).conv_id = OLD.conv_id); DELETE FROM \(RecipientStatusTable) WHERE \(RecipientStatusTable).rms_id = OLD._id; END;";
    }
    
    class func sqlWithConversationsTigger() ->String{
        return "CREATE TRIGGER IF NOT EXISTS conversations_delete_rms_on_delete BEGIN DELETE FROM \(tableAllMessage) WHERE \(tableAllMessage).conv_id = OLD._id END;"
    }
    
    class func sqlMsgDetailView() ->String
    {
        return "CREATE VIEW IF NOT EXISTS \(MsgDetailView) AS SELTCT "
    }
    
    
    
    
    
    
    
    
    
}
