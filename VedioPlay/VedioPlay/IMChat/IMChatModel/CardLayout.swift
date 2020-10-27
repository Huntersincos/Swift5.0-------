//
//  CardLayout.swift
//  VedioPlay
//
//  Created by wenze on 2020/10/13.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AddressBook
import ContactsUI
let VCardMargin:CGFloat = 5
var VIconSize:CGFloat = 40
var VLabelHeight:CGFloat = 20
class CardLayout: BaseBubbleLayout {
    var vIconImage:UIImage?
    var vIconFrame:CGRect?
    var vNumber:String?
    var vNumberLabelFrame:CGRect?
    var vName:String?
    var vNameLabelFrame:CGRect?

    
    override func configWithMessage(_ message: ChatMessageObject?, _ showTime: Bool, _ showName: Bool) {
        super.configWithMessage(message, showTime, showName)
        
        if SDWebImageManager .isBlankString(message?.filePath) == false {
            
            let contactArray = CardLayout.addressBookRecordsWithRelativePath(message?.filePath ?? "")
            if SDWebImageManager .IsArraySafe(contactArray) {
                if contactArray.count != 0 {
                    let record = contactArray[0]
                    if record.thumbnailImageData == nil {
                        vIconImage = UIImage.init(named: "img_blueman_nor")
                    }else{
                        vIconImage = UIImage.init(data: record.thumbnailImageData!)
                    }
                    if SDWebImageManager.IsArraySafe(record.phoneNumbers) {
                        let labeledValue:CNLabeledValue = record.phoneNumbers[0]
                        let phoneNumer = labeledValue.value
                        vNumber = phoneNumer.stringValue
                       
                    }
                    
                    vName = record.familyName + record.givenName
                    
                    
                }
            }
        }
        
        bubbleViewBackgroupColor = .clear
        vIconFrame = CGRect(x: VCardSize().width/2 - VIconSize/2, y: VCardMargin, width: VIconSize, height: VIconSize)
        vNameLabelFrame = CGRect(x: 0, y: vIconFrame?.maxY ?? 0 + VCardMargin, width: VCardSize().width, height: VLabelHeight)
        vNumberLabelFrame = CGRect(x: 0, y: vNameLabelFrame?.maxY ?? 0 + VCardMargin, width:VCardSize().width , height: VLabelHeight)
        
    }
    
    class func  addressBookRecordsWithRelativePath(_ path:String) -> [CNContact]{
        
        let absolutePath = JRFileUtil.getAbsolutePathWithFileRelativePath(path)
//        let addressBookError:CFErrorRef?
        //let people:CFArrayRef? = ABPersonCreatePeopleInSourceWithVCardRepresentation(ABRecord!, <#T##vCardData: CFData!##CFData!#>)
        
        // 使用 CNContactVCardSerialization ios9
        if URL.init(string: absolutePath) == nil {
            return []
        }
        
        return  try! CNContactVCardSerialization.contacts(with:Data.init(contentsOf: URL.init(string: absolutePath)!))
        
        
    }
    
}

