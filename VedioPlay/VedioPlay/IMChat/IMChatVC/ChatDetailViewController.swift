//
//  ChatDetailViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/1.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import RealmSwift

public let TextCell = "TextCell"
public let LocationCell = "LocationCell"
public let AudioCell = "AudioCell"
public let ThumbImgCell = "ThumbImgCell"
public let  VCardCell = "VCardCell"
public let OtherFileCell = "OtherFileCell"
public let RevokeCell = "RevokeCell"
public var contetntKey = ""
class ChatDetailViewController: UIViewController,InputViewDelegate,UITableViewDelegate,UITableViewDataSource,BaseMessageCellTableViewCellDelegate,JRAlbumViewControllerDelegate {
    
    
    var  peerUserName:String = ""
    var  isFirstLoad = false
    //var  tableView:UITableView?
    var  messageList:Results<ChatMessageObject>?
    var  messageListToken:NotificationToken?
    var  currentCount = 0
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
        view.addSubview(self.tableView)
        
        MessageManager.shareInstance.peerUserName = self.peerUserName
        
        getMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keypadChanged), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keypadChanged), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
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
       chatDetailView.register(TextMessageTableViewCell.self, forCellReuseIdentifier: TextCell)
       chatDetailView.register(LoactionTableViewCell.self, forCellReuseIdentifier: LocationCell)
       chatDetailView.register(AudioMessageTableViewCell.self, forCellReuseIdentifier: AudioCell)
       chatDetailView.register(ThumbImageTableViewCell.self, forCellReuseIdentifier: ThumbImgCell)
       chatDetailView.register(VCardMessageTableViewCell.self, forCellReuseIdentifier: VCardCell)
      chatDetailView.register(OtherFiledMessageTableViewCell.self, forCellReuseIdentifier: OtherFileCell)
      chatDetailView.register(RevokeMessageTableViewCell.self, forCellReuseIdentifier: RevokeCell)
      chatDetailView.backgroundColor = RGBCOLOR(244, 244, 244, 1)
      chatDetailView.delegate = self
      chatDetailView.dataSource = self
      chatDetailView.estimatedRowHeight = 0
      chatDetailView.estimatedSectionFooterHeight = 0
      chatDetailView.estimatedSectionHeaderHeight = 0
      chatDetailView.separatorStyle = .none
      chatDetailView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap)))
        
      return chatDetailView
    }()
    
    lazy var commentView:InputView = {
        let inputView = InputView.init(frame: CGRect.zero)
        inputView.addObserver(self, forKeyPath: "frame", options: .new, context: &contetntKey)
        inputView.addObserver(self, forKeyPath: "center", options: .new, context: &contetntKey)
        inputView.backgroundColor = .clear
        inputView.delegate = self
        return inputView
    }()

     
    func getMessages(){
        messageList = MessageDBHelper.getMessagesWithNumber(self.peerUserName)?.sorted(byKeyPath: "timestamp", ascending: true)
       

        messageListToken = messageList?.observe({ [weak self] (change:RealmCollectionChange<Results<ChatMessageObject>>?) in
             if let strongSelf = self{
                if change == nil {
                    strongSelf.messageFirstLoad()
                }else{
                    switch change {
                    case .initial:
                        strongSelf.messageFirstLoad()
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
                            for _ in insertions {
                                let message = strongSelf.messageList?[insertions[i]]
                                messageArray.append(message ?? ChatMessageObject() )
                                i += 1
                            }
                            strongSelf.messageInserted(messageArray)
                        }

                        if SDWebImageManager.IsArraySafe(deletions) {
                            if strongSelf.messageList?.count != 0  {
                                strongSelf.messageDeleted(deletions.count)
                            }else{
                                strongSelf.messageDeletedAll()

                            }

                        }else{
                           // strongSelf.messageDeletedAll()
                        }

                        break
                    default:
                        break
                    }


                }
            }
        })
    
        // 不考虑下拉刷新
//        currentCount = 10
//        if currentCount > messageList?.count ?? 0 {
//            currentCount = messageList?.count ?? 0
//        }
        
        currentCount = messageList?.count ?? 0
        
    }
    
    func messageFirstLoad(){
        
        var i = (messageList?.count ?? 0) - (currentCount)
        if messageList != nil {
            
            for _ in messageList! {
                if i  < messageList!.count {
                    let message = messageList![i]
                    MessageLayoutManager.shareInstance.creatLayoutWithMessage(message, shouldShowTime(message))
                }else{
                    break
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
        
        let currentTime = messageList?[index!].timestamp as NSString?
        let previousTime = messageList?[index! - 1].timestamp as NSString?
        
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
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object == nil {
            return
        }
        
        if context == &contetntKey && ( keyPath == "frame" || keyPath == "center") {
           
            layoutAndAnimateMessageInputTextView(object as! UIView)
        }
    }
    
    func layoutAndAnimateMessageInputTextView( _ textView:UIView){
        
        var frame = self.tableView.frame
        frame.size.height = textView.frame.origin.y
        tableView.frame = frame
        scrollToBottomWithAnimated(false)
    }
    
    @objc func keypadChanged( _ notification:Notification){
        
        let userInfo = notification.userInfo
        let value = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyBoardEndY = value.cgRectValue.origin.y
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let rectOfStatusbar = UIApplication.shared.statusBarFrame
        let rectOfNavigationbar = navigationController?.navigationBar.frame
        let height = rectOfStatusbar.size.height + (rectOfNavigationbar?.size.height ?? 0)
        
        UIView.animate(withDuration: duration.doubleValue) {
           
            UIView.setAnimationBeginsFromCurrentState(true)
            
            //self.tableView.center = CGPoint(x: self.commentView.frame.origin.x, y: keyBoardEndY + (self.commentView.headHeight + InputMenuViewHeight)/2 - self.commentView.headHeight - height) 无法编译卡主 编译器无法判断类型 opiton
//            let center_inputMenuViewHeight = (self.commentView.headHeight  + InputMenuViewHeight)/2
//
//            let centerY =  center_inputMenuViewHeight - self.commentView.headHeight - height
            
            self.commentView.center = CGPoint(x: self.commentView.center.x, y: keyBoardEndY+(self.commentView.headHeight+InputMenuViewHeight)/2-self.commentView.headHeight-height)
            
        }
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let index = (messageList?.count ?? 0) - currentCount + indexPath.row
        
        let index = indexPath.row
        
        if index >= (messageList?.count ?? 0) || index < 0 {
             return UITableViewCell.init()
        }
        
        let message = messageList?[index]
        
        if message?.state ==  .MessageItemStateRevoked {
            let cell:RevokeMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: RevokeCell, for: indexPath) as! RevokeMessageTableViewCell
            cell.configWithLayout(MessageLayoutManager.shareInstance.layoutDic[message?.imdnId ?? ""] as? RevokeLayout)
            
            return cell
        }else{
           // var cell:BaseMessageCellTableViewCell?
            switch message?.messageType {
            case .MessageItemTypeText:
               let cell = tableView.dequeueReusableCell(withIdentifier: TextCell, for: indexPath) as! TextMessageTableViewCell
               cell.configWithLayou(MessageLayoutManager.shareInstance.layoutDic[message?.imdnId ?? ""] as? TextLayout)
                cell.setDelegate(self, self.tableView)
                  return cell
              //  break
                
            case .MessageItemTypeImage:fallthrough
            case .MessageItemTypeVideo:
                let cell = tableView.dequeueReusableCell(withIdentifier: ThumbImgCell, for: indexPath) as! ThumbImageTableViewCell
                 cell.configWithLayou(MessageLayoutManager.shareInstance.layoutDic[message?.transId ?? ""] as? ThumbImageLayout)
                 cell.setDelegate(self, self.tableView)
                  return cell
                  //break
            case .MessageItemTypeAudio:
                let cell = tableView.dequeueReusableCell(withIdentifier: ThumbImgCell, for: indexPath) as! AudioMessageTableViewCell
               
               let layout = MessageLayoutManager.shareInstance.layoutDic[message?.transId ?? ""] as? AudioLayout
               cell.configWithLayou(layout)
               cell.setDelegate(self, self.tableView)
                    // 播放
                if AudioPlayHelper.shareInstance.filePath == JRFileUtil.getAbsolutePathWithFileRelativePath(layout?.message?.filePath ?? "") && AudioPlayHelper.shareInstance.isPlaying ?? false {
                    cell.startAniamtion()
                }else{
                    cell.stopAniamtion()
                }
                
                 return cell
                   // break
                
            case .MessageItemTypeVcard:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: VCardCell, for: indexPath) as! CardMessageTableViewCell
                cell.configWithLayou(MessageLayoutManager.shareInstance.layoutDic[message?.transId ?? ""] as? CardLayout)
                     cell.setDelegate(self, self.tableView)
                return cell
            case .MessageItemTypeGeo:
                
                 let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell, for: indexPath) as! LoactionTableViewCell
                 cell.configWithLayou(MessageLayoutManager.shareInstance.layoutDic[message?.transId ?? ""] as? LoactionLayout)
                    cell.setDelegate(self, self.tableView)
                return cell
                
            case .MessageItemTypeOtherFile:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: OtherFileCell, for: indexPath) as! OtherFiledMessageTableViewCell
                cell.configWithLayou(MessageLayoutManager.shareInstance.layoutDic[message?.transId ?? ""] as? OtherFileLayout)
                cell.setDelegate(self, self.tableView)
                return cell
                
                  
            default:
                break
            }
        }
        
        
        
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let index = (messageList?.count ?? 0) - currentCount + indexPath.row
        let index = indexPath.row
        if index >= (messageList?.count ?? 0) || index < 0 {
             return 0
        }
        
        let message = messageList?[index]
        
        if message?.state ==  .MessageItemStateRevoked  {
             let layout = MessageLayoutManager.shareInstance.layoutDic[message?.imdnId ?? ""] as? RevokeLayout
            return layout?.calculateCellHeight() ?? 0
        }
        
        if message?.messageType == .MessageItemTypeText {
            let layout = MessageLayoutManager.shareInstance.layoutDic[message?.imdnId ?? ""] as? TextLayout
            return layout?.calculateCellHeight() ?? 0
        }else{
            let layout = MessageLayoutManager.shareInstance.layoutDic[message?.transId ?? ""] as? BaseBubbleLayout
             return layout?.calculateCellHeight() ?? 0
            
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tap(nil)
        
    }
    
    
    /// MessageCell Delegate
    
    func tableView(_ tableView: UITableView?, tapMessageCellContent message: ChatMessageObject?) {
        
        isDelectMessage = false
        
        if message?.messageType == .MessageItemTypeVideo || message?.messageType == .MessageItemTypeImage || message?.messageType == .MessageItemTypeOtherFile {
            // 视频播放
        }
        
    }
    
    func tableView(_ tableView: UITableView?, tapMessageCellState message: ChatMessageObject?) {
        
    }
    
    func tableView(_ tableView: UITableView?, tapMessageCellAvator message: ChatMessageObject?) {
        
        isDelectMessage = true
    }
    
    
    func tableView(_ tableView: UITableView?, revokeMessage message: ChatMessageObject?) {
        
    }
    
    
    func tableView(_ tableView: UITableView?, complainMessage message: ChatMessageObject?) {
        
    }
    
    
    func tableView(_ tableView: UITableView?, acceptExchangeVCard message: ChatMessageObject?) {
        
    }
    
    func tableView(_ tableView: UITableView?, deletSMS message: ChatMessageObject?) {
        
        // 删除消息
        if message == nil {
            return
        }
        isDelectMessage = true
        
        MessageManager.shareInstance.deleteMessage(message!)
    }
    
    ///  InputViewDelegate
    func menuViewHide() {
        
        if self.commentView.isMenuViewShow {
                
              UIView.animate(withDuration: 0.3, animations: {
                  
                  UIView.setAnimationBeginsFromCurrentState(true)
                  
                self.commentView.center = CGPoint(x:self.commentView.center.x, y:self.view.frame.size.height + (self.commentView.headHeight + InputMenuViewHeight)/2 - self.commentView.headHeight)
                  
              }) { (finished:Bool) in
                  
                  self.commentView.isMenuViewShow = false
              }
              
              
        }
        
    }
    
    func menuViewShow() {
        
        if self.commentView.isMenuViewShow == false {
          
            UIView.animate(withDuration: 0.3, animations: {
                
                UIView.setAnimationBeginsFromCurrentState(true)
                
                self.commentView.center = CGPoint(x: self.commentView.center.x, y: self.view.frame.size.height - self.commentView.bounds.size.height/2.0)
                
            }) { (finished:Bool) in
                
                self.commentView.isMenuViewShow = true
            }
            
            
        }
        
        
    }
    
    func locationBtnClicked() {
        
    }
    
    func photoBtnClicked() {
        
        let photoVC = JRAlbumViewController.init()
        photoVC.delegate = self
        navigationController?.pushViewController(photoVC, animated: true)
    }
    
    func cameraBtnClicked() {
        
    }
    
    func otherFilesBtnClicked() {
        
    }
    
    func didAtMemberInGroupChat() {
        
    }
    
    func didBeginEditing() {
        scrollToBottomWithAnimated(false)
    }
    
    func sendMessage(_ message: String?) {
        
        if MessageManager.shareInstance.sendTextMessage(message, "小明") == false {
            #if DEBUG
               print("消息文本发送失败")

               #else
               

               #endif
            
            
        }else{
            #if DEBUG
            
            print("消息文本发送成功")

            #else
                  

         #endif
            
        }
        
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
    
    func fileSelected(_ dataArray: [Dictionary<String, Any>]) {
        
        if SDWebImageManager.IsArraySafe(dataArray) {
            
            for videoDataDic in dataArray {
                
                let isVideo:Bool = videoDataDic["isVideo"] as! Bool
                
                if isVideo {
                    let fileRelativePath = JRFileUtil.createFilePathWithFileName(JRFileUtil.getFileNameWithType("mp4") as NSString, "video", self.peerUserName)
                    let ns_videoData:NSData = videoDataDic["blumData"] as! NSData
                    if ns_videoData.write(toFile: JRFileUtil.getAbsolutePathWithFileRelativePath(fileRelativePath), atomically: true) {
                        
                        if MessageManager.shareInstance.sendFile(fileRelativePath, JRFileUtil.getThumbPathWithFilePath(fileRelativePath, peerUserName: self.peerUserName), "video/mp4", self.peerUserName){
                            
                            #if DEBUG
                               print("视频发送成功")

                               #else

                               #endif
                        }
                    }
                    
                }else{
                    
                    let fileRelativePath = JRFileUtil.createFilePathWithFileName(JRFileUtil.getFileNameWithType("png") as NSString, "image", self.peerUserName)
                    
                    let ns_imageData:NSData =  videoDataDic["blumData"] as! NSData
                    
                    if ns_imageData.write(toFile: JRFileUtil.getAbsolutePathWithFileRelativePath(fileRelativePath), atomically: true) {
                        
                        if MessageManager.shareInstance.sendFile(fileRelativePath, JRFileUtil.getThumbPathWithFilePath(fileRelativePath, peerUserName: self.peerUserName), "image/png", self.peerUserName){
                            
                            #if DEBUG
                               print("图片发送成功")

                               #else

                               #endif
                        }
                    }
                    
                }
            }
            
//            if isVideo {
//                for videoData in dataArray {
//                    let fileRelativePath = JRFileUtil.createFilePathWithFileName(JRFileUtil.getFileNameWithType("mp4") as NSString, "video", self.peerUserName)
//                    let ns_videoData:NSData = videoData as NSData
//                    if ns_videoData.write(toFile: JRFileUtil.getAbsolutePathWithFileRelativePath(fileRelativePath), atomically: true) {
//
//                        if MessageManager.shareInstance.sendFile(fileRelativePath, JRFileUtil.getThumbPathWithFilePath(fileRelativePath, peerUserName: self.peerUserName), "video/mp4", self.peerUserName){
//
//                            #if DEBUG
//                               print("视频发送成功")
//
//                               #else
//
//                               #endif
//                        }
//                    }
//
//                }
//
//            }else{
//
//                for imageData in dataArray {
//
//                    let fileRelativePath = JRFileUtil.createFilePathWithFileName(JRFileUtil.getFileNameWithType("png") as NSString, "image", self.peerUserName)
//
//                    let ns_imageData:NSData = imageData as NSData
//
//                    if ns_imageData.write(toFile: JRFileUtil.getAbsolutePathWithFileRelativePath(fileRelativePath), atomically: true) {
//
//                        if MessageManager.shareInstance.sendFile(fileRelativePath, JRFileUtil.getThumbPathWithFilePath(fileRelativePath, peerUserName: self.peerUserName), "image/png", self.peerUserName){
//
//                            #if DEBUG
//                               print("视频发送成功")
//
//                               #else
//
//                               #endif
//                        }
//                    }
//
//                }
//
//
//            }
        }
        
    }
    
    
    
    @objc func tap(_ getTap:UITapGestureRecognizer?){
        
        view.endEditing(true)
        menuViewHide()
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
