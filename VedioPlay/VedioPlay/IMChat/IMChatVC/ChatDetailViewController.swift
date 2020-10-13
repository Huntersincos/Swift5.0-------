//
//  ChatDetailViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/1.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import RealmSwift

class ChatDetailViewController: UIViewController,InputViewDelegate {
    
    
    var  peerUserName:String?
    var  isFirstLoad:Bool?
    var  tableView:UITableView?
    var  messageList:Results<ChatMessageObject>?
    var  messageListToken:NotificationToken?
    var  currentCount:Int?
    
    convenience init(with peerUserName:String){
        self.init()
        self.peerUserName =  peerUserName
        title = peerUserName
        
        let chatListCoverstation = MessageDBHelper.getConversationPeerUserWith(peerUserName)
        if !SDWebImageManager.isBlankString(chatListCoverstation?.conversationTitleName) {
            title = chatListCoverstation?.conversationTitleName
        }else{
            if chatListCoverstation?.getAllMessages() == nil {
                return
            }
            for obj_c in (chatListCoverstation?.getAllMessages())! {
                title = obj_c.senderName
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        isFirstLoad = true
        
        view.addSubview(self.commentView)
        
        MessageManager.shareInstance.peerUserName = self.peerUserName
        
        getMessages()
        
    }
    
    override func viewDidLayoutSubviews() {
        //当在self.view上的子控件的高度或者宽度改变时，会先执行- (void)viewWillLayoutSubviews，- (void)viewDidLayoutSubviews，然后执行子控件中的- (void)layoutSubviews。最后调用 drawRect

     
    }
    
    lazy var commentView:InputView = {
        let inputView = InputView.init(frame: CGRect.zero)
        inputView.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        inputView.addObserver(self, forKeyPath: "center", options: .new, context: nil)
        inputView.delegate = self
        return inputView
    }()

     
    func getMessages(){
        messageList = MessageDBHelper.getMessagesWithNumber(self.peerUserName ?? "")
        messageListToken = messageList?.observe({ [weak self] (change:RealmCollectionChange<Results<ChatMessageObject>>?) in
             if let strongSelf = self{
                if change == nil {
                    strongSelf.messageFirstLoad()
                }else{
                    
                }
            }
        })
        
        
    }
    
    func messageFirstLoad(){
        
        var i = (messageList?.count ?? 0) - (currentCount ?? 0)
        if messageList != nil {
            for _ in messageList! {
                if i  < messageList!.count {
                    let message = messageList![i]
                    
                }
               
                i += 1
            }
        }
    
    }
    
    func shouldShowTime(_ message:ChatMessageObject) -> Bool{
        let index = messageList?.index(of: message)
        if index == nil {
            return true
        }
        if index == 0{
            return true
        }
        
        let currentTime = messageList?[index!].timestamp
        let previousTime = messageList?[index! - 1].timestamp
        
        return (currentTime?.longLongValue ?? 0) - (previousTime?.longLongValue ?? 0) > 180000 || (index ?? 0)%9 == 1
        
        
    }
    
    ///  InputViewDelegate
    func menuViewHide() {
        
    }
    
    func menuViewShow() {
        
    }
    
    func locationBtnClicked() {
        
    }
    
    func photoBtnClicked() {
        
    }
    
    func cameraBtnClicked() {
        
    }
    
    func otherFilesBtnClicked() {
        
    }
    
    func didAtMemberInGroupChat() {
        
    }
    
    func didBeginEditing() {
        
    }
    
    func sendMessage(_ message: String?) {
        
    }
    
    func didVoiceRecordBeginRecord(_ button: ChatVoiceRecordButton) {
        
    }
    
    func didVoiceRecordEndRecord(_ button: ChatVoiceRecordButton, _ duration: Int) {
        
    }
    
    func didVoiceRecordCancelRecord(_ button: ChatVoiceRecordButton) {
        
    }
    
    func didVoiceRecordContinueRecord(_ button: ChatVoiceRecordButton) {
        
    }
    
    func didVoiceRecordWillCancelRecord(_ button: ChatVoiceRecordButton) {
        
    }
    
    func didVoiceRecordRecordTimeSmall(_ button: ChatVoiceRecordButton) {
        
    }
    
    func didVoiceRecordRecordTimeBig(_ button: ChatVoiceRecordButton) {
        
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
