//
//  SocketIOViewController.swift
//  VedioPlay
//
//  Created by wenze on 2021/3/15.
//  Copyright © 2021 wenze. All rights reserved.
//

import UIKit
import SocketIO

/**
 
 SocketManager:线程不安全,使用时候要强引用,确保socket被连接 管理一个 SocketEngineSpec
 */


class SocketIOViewController: UIViewController {

    var socket: SocketIOClient?

    //发送内容
    var mySendString = ""
    //发送方
    var myLoginName = ""
    //接收方
    var receiverName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
    

        // Do any additional setup after loading the view.

        
        connectSocket()
    }
    
    /**
     连接Socket-io
     */
    private func connectSocket() {
        guard let url = URL(string: "http://192.168.3.16") else { return }
        //config 某些配置在重新socket连接成功之后生效
        let manager = SocketManager(socketURL: url, config: ["log": true, "compress": true])
        
        // 最新时长
        manager.reconnectWait =  10;
        // 重新链接最大时长默认30s
        manager.reconnectWaitMax = 60;
        // 0 -1 之间默认为0.5随机化因子 ?????
        manager.randomizationFactor = 0.6
        // 默认是主队列 串行队列 不支持并发队列
        manager.handleQueue = DispatchQueue.main;
        
        //let socket: SocketIOClient? = manager.defaultSocket == 等价的
        let socket:SocketIOClient? = manager.socket(forNamespace: "/")
        
        //监听连接Socket连接是否成功
        socket?.on("connection", callback: {(_ data: [Any]?, _ ack: SocketAckEmitter?) -> Void in
            print("socket connected==\(data)")
        })
        //chat message2 为 监听接收消息 的方法名(为举例)  与后台协定方法名
    //    socket?.on("chat message2", callback: {(_ data: [Any]?, _ ack: SocketAckEmitter?) -> Void in
    //        self.receiveMessage(data)
    //        print("接收到了:\(data)")
    //    })
        self.socket = socket
        socket?.connect()
        
        debugPrint("manager.status === \(manager.status)")
    }

    /**
     发送消息
     @param text 发送内容http://localhost:80/socket.io/?transport=polling&b64=1
     {"code":5,"message":"Unsupported protocol version"}
     */
    private func sendMessage(_ text: String?) {
        print("发送消息")
            //发送消息，包括发送方、接收方、发送内容
            //例如：
        let cur = "\(receiverName)?%%?%%\(text ?? "")*%%*%%\(myLoginName)"
        mySendString = cur
        //发送消息socket
        //chat message 为发送消息给后台的方法名 (为举例)  与后台协定方法名
        socket?.emit("chat message", with: [cur])
    }

    /**
     接收到消息
     @param data 消息内容
     */
//    private func receiveMessage(_ data: [Any]?) {
//        let receiveStr = data?[0] as? String
//        if !(mySendString == receiveStr) {
//            let str = data?[0] as? String
//            let array = str?.components(separatedBy: "?%?%")
//            let str1 = array![1]
//            let array1 = str1.components(separatedBy: "*%*%")
//            if (array[0] == loginName) {
//                //消息添加并展示
//            }
//            print("内容内容:\(array1[0])")
//        } else {
//            print("自己发送的消息，不用处理")
//        }
//        print("全部内容:\(data[0]), \(data ?? "")")
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
 
}



