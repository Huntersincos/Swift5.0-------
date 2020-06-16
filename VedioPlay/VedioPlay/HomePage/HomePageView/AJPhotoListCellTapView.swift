//
//  AJPhotoListCellTapView.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class AJPhotoListCellTapView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var  selected:Bool?
    var  disabled:Bool?
    var  checkedIcon:UIImage?
    var  selectedColor:UIColor?
    var  disabledColor:UIColor?
    var  selectIcon:UIImageView?
    /**
         在swift4.0废弃了 initialize  load也抛用
     */
//    override class func initialize() {
//
//    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        checkedIcon = UIImage(named: "ic_pic_choose")
        selectedColor = UIColor(white: 1, alpha: 0.3)
        disabledColor = UIColor(white: 1, alpha: 0.8)
        backgroundColor = UIColor.clear
        clipsToBounds = true
        selectIcon = UIImageView.init(frame: CGRect(x: frame.size.width - checkedIcon!.size.width - 5, y: frame.size.height-checkedIcon!.size.height - 5, width: checkedIcon!.size.width, height: checkedIcon!.size.height))
        self.addSubview(selectIcon!)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    

}
