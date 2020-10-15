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
    
    
    var  peerUserName:String = ""
    var  isFirstLoad = false
    //var  tableView:UITableView?
    var  messageList:Results<ChatMessageObject>?
    var  messageListToken:NotificationToken?
    var  currentCount = 1
    var  isDelectMessage = false
    
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
       // view.addSubview(self.tableView)
        
        MessageManager.shareInstance.peerUserName = self.peerUserName
        
        getMessages()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MessageDBHelper.readAllMessagesWithNumber(self.peerUserName)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        AudioPlayHelper.shareInstance.stopAudio()
    }
    
    
    override func viewDidLayoutSubviews() {
        //当在self.view上的子控件的高度或者宽度改变时，会先执行- (void)viewWillLayoutSubviews，- (void)viewDidLayoutSubviews，然后执行子控件中的- (void)layoutSubviews。最后调用 drawRect
        super.viewDidLayoutSubviews()

        if isFirstLoad {
            
            tableView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - InputHeadViewHeight)
            commentView.frame = CGRect(x: 0, y: tableView.frame.maxY, width: view.frame.size.width, height: InputHeadViewHeight+InputMenuViewHeight)
            isFirstLoad = false
        }
    }
    
   lazy var tableView:UITableView = {
        
    let chatDetailView = UITableView.init(frame: CGRect.zero, style: .plain)
    
        
    return chatDetailView
    }()
    
    lazy var commentView:InputView = {
        let inputView = InputView.init(frame: CGRect.zero)
        inputView.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        inputView.addObserver(self, forKeyPath: "center", options: .new, context: nil)
        inputView.delegate = self
        return inputView
    }()

     
    func getMessages(){
        messageList = MessageDBHelper.getMessagesWithNumber(self.peerUserName)

        messageListToken = messageList?.observe({ [weak self] (change:RealmCollectionChange<Results<ChatMessageObject>>?) in
             if let strongSelf = self{
                if change == nil {
                    strongSelf.messageFirstLoad()
                }else{
                    switch change {
                    case .initial:
                        break
///                        可以通过传递到通知模块当中的 RealmCollectionChange 参数来访问这些变更。该对象存放了受删除 (deletions)、插入 (insertions) 以及修改 (modifications) 所影响的索引信息
                    //case .update(_, deletions: [Int], insertions: [Int], modifications: [Int]):break
                    case .update(_, let deletions, let insertions, let modifications):
                        
                        if SDWebImageManager.IsArraySafe(modifications) {
                            //let changes = change.
                            var i = 0
                            var messageArray = [ChatMessageObject]()
                            for _ in modifications {
                                let message = strongSelf.messageList?[modifications[i]]
                                messageArray.append(message ?? ChatMessageObject() )
                                i += 1
                            }
                            strongSelf.messageUpdated(messageArray)
                        }
                        
                        if SDWebImageManager.IsArraySafe(insertions) {
                            
                            var i = 0
                            var messageArray = [ChatMessageObject]()
                            for _ in modifications {
                                let message = strongSelf.messageList?[insertions[i]]
                                messageArray.append(message ?? ChatMessageObject() )
                                i += 1
                            }
                            strongSelf.messageInserted(messageArray)
                        }
                        
                        if SDWebImageManager.IsArraySafe(deletions) {
                            strongSelf.messageDeleted(deletions.count)
                            
                        }else{
                            strongSelf.messageDeletedAll()
                        }
                        
                        break
                    default:
                        break
                    }

                    
                }
            }
        })
    
        currentCount = 10
        if currentCount > messageList?.count ?? 0 {
            currentCount = messageList?.count ?? 0
        }
    }
    
    func messageFirstLoad(){
        
        var i = (messageList?.count ?? 0) - (currentCount)
        if messageList != nil {
            for _ in messageList! {
                if i  < messageList!.count {
                    let message = messageList![i]
                    MessageLayoutManager.shareInstance.creatLayoutWithMessage(message, shouldShowTime(message))
                }
               
                i += 1
            }
        }
        
        tableView.reloadData()
        scrollToBottomWithAnimated(false)
    
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
    
    func scrollToBottomWithAnimated(_ animated:Bool){
        
        if currentCount > 0 {
            let indexPath = IndexPath.init(row: currentCount  - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
        
    }
    
    func messageUpdated(_ messages:[ChatMessageObject]){
        
        for item in messages {
            MessageLayoutManager.shareInstance.creatLayoutWithMessage(item, shouldShowTime(item))
        }
        
        tableView.reloadData()
        
    }
    
    func messageInserted(_ messages:[ChatMessageObject]){
        
        if isDelectMessage == false {
            currentCount += messages.count
            for item in messages {
                MessageLayoutManager.shareInstance.creatLayoutWithMessage(item, shouldShowTime(item))
            }
            tableView.reloadData()
            scrollToBottomWithAnimated(true)
        }
    }
    
    func messageDeletedAll(){
        currentCount = 0
        tableView.reloadData()
    }
    
    func messageDeleted(_ messageInt:Int){
        self.currentCount -= messageInt
        tableView.reloadData()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        MessageManager.shareInstance.peerUserName = nil
        MessageLayoutManager.shareInstance.layoutDic.removeAll()
        commentView.removeObserver(self, forKeyPath: "frame")
        commentView.removeObserver(self, forKeyPath: "center")
        commentView.delegate = nil
        messageListToken?.invalidate()
        
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
